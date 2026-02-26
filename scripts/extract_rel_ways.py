#!/usr/bin/env python3
import osmium
import psycopg2
from psycopg2.extras import execute_values

DB = dict(host="127.0.0.1", dbname="hikingtest", user="hiking", password="hiking")
BATCH = 20000
PBF = "/root/hiking-test/austria-latest.osm.pbf"

class RelWayExtractor(osmium.SimpleHandler):
    def __init__(self, rel_ids, conn):
        super().__init__()
        self.rel_ids = rel_ids
        self.conn = conn
        self.buf = []
        self.total = 0

    def flush(self):
        if not self.buf:
            return
        with self.conn.cursor() as cur:
            execute_values(
                cur,
                "INSERT INTO hiking_rel_way (rel_id, way_id, role) VALUES %s",
                self.buf,
                page_size=5000
            )
        self.conn.commit()
        self.total += len(self.buf)
        print(f"  inserted {self.total:,} relation-way links", flush=True)
        self.buf.clear()

    def relation(self, r):
        if r.id not in self.rel_ids:
            return
        for m in r.members:
            if m.type == 'w':
                self.buf.append((r.id, m.ref, m.role or None))
                if len(self.buf) >= BATCH:
                    self.flush()

def main():
    print("Loading hiking relation ids from DB...")
    conn = psycopg2.connect(**DB)
    conn.autocommit = False
    with conn.cursor() as cur:
        cur.execute("SELECT osm_id FROM hiking_rel;")
        rel_ids = {row[0] for row in cur.fetchall()}
    print(f"  loaded {len(rel_ids):,} relation ids")

    h = RelWayExtractor(rel_ids, conn)
    print("Reading PBF and extracting way members...")
    h.apply_file(PBF, locations=False)
    h.flush()
    conn.close()
    print("Done.")

if __name__ == "__main__":
    main()

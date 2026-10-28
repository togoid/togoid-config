"""Retrieve all entries of the given type from DDBJ Search API and print them as JSON Lines.

Usage: python bin/ddbj_search_entries.py <type>   (e.g. jga-study)

See https://ddbj.nig.ac.jp/search/api/ for the API.
"""
import json
import sys
import urllib.parse
import urllib.request

API_URL = "https://ddbj.nig.ac.jp/search/api/entries"
# perPage: max 100, dbXrefsLimit: max 1000 per related type (default 100)
PARAMS = {"perPage": 100, "dbXrefsLimit": 1000}


def fetch(url):
    with urllib.request.urlopen(url, timeout=300) as res:
        return json.load(res)


def is_truncated(item):
    """Return True when dbXrefs is truncated by dbXrefsLimit"""
    counts = {}
    for xref in item.get("dbXrefs") or []:
        counts[xref["type"]] = counts.get(xref["type"], 0) + 1
    return any(counts.get(t, 0) < n for t, n in (item.get("dbXrefsCount") or {}).items())


def main():
    if len(sys.argv) != 2:
        sys.exit(f"Usage: {sys.argv[0]} <type>")
    entry_type = sys.argv[1]

    params = dict(PARAMS)
    # The API may return the same entry more than once (e.g. JGAS000561 as of 2026-10)
    seen = set()
    while True:
        url = f"{API_URL}/{entry_type}/?{urllib.parse.urlencode(params)}"
        data = fetch(url)
        for item in data["items"]:
            if item["identifier"] in seen:
                continue
            seen.add(item["identifier"])
            if is_truncated(item):
                # Retrieve all dbXrefs of the entry (e.g. E-GEAD-759 has more than 1000 BioSamples)
                url = f"{API_URL}/{entry_type}/{urllib.parse.quote(item['identifier'])}/dbxrefs.json"
                item["dbXrefs"] = fetch(url)["dbXrefs"]
            print(json.dumps(item, ensure_ascii=False))
        if not data["pagination"]["hasNext"]:
            break
        params["cursor"] = data["pagination"]["nextCursor"]

    print(f"# Retrieved {len(seen)} {entry_type} entries from DDBJ Search API", file=sys.stderr)


if __name__ == "__main__":
    main()

import csv
import json
import sys
import urllib.request
import urllib.parse
# import requests


def get_gtcids(motif, wurcs, api, redend):
    encoded_wurcs = urllib.parse.quote(wurcs, safe='')
    if motif in ["G18625KA", "G54733XO","G99524KA"]:
        # print("======= Skip: ", motif)
        # print(api + "partialmatch?wurcs=" + encoded_wurcs + "&rootnode=true")
        gtcids = [motif]
    else:
        # print(api + "partialmatch?wurcs=" + encoded_wurcs + "&rootnode=true")
        if "TRUE" == redend:
        # if motif == "G59126YU":
            # print("###", motif, "Reducing end ","###")
            url = api + "partialmatch?wurcs=" + encoded_wurcs + "&rootnode=true"
        else:
            url = api + "partialmatch?wurcs=" + encoded_wurcs

        try:
            # r = requests.get(url)
            # res_json = r.json()
            r = urllib.request.urlopen(url)
            res_json = json.loads(r.read())
            gtcids = list(map(lambda h: h["id"], res_json))
        except Exception as e:
            print(f'Error: {e}: {url} {motif}', file=sys.stderr)
            sys.exit(1)
            # gtcids = []

    return gtcids


def make_dict(api, motif_list_filepath):
    motif_dict = {}
    with open(motif_list_filepath, newline='') as f:
        reader = csv.reader(f)
        for i, row in enumerate(reader):
            motif = row[0]
            wurcs = row[1]
            redend = row[3]
            # print("#", i + 1, motif, wurcs, redend)
            gtcids = get_gtcids(motif, wurcs, api, redend)
            # print(gtcids)
            motif_dict[motif] = gtcids

    return motif_dict


if __name__ == '__main__':
    api = sys.argv[1]
    motif_list_filepath = sys.argv[2]

    motif_dict = make_dict(api, motif_list_filepath)

    for motif in motif_dict:
        for glycan in motif_dict[motif]:
            print(motif, glycan, sep="\t")

#
# load votes per candidate per county, from Associated Press, and save to CSV in long format
#

import urllib.request
import json
from pprint import pprint
import csv

#
# Load candidates and list of states
#

# get metadata.json

metadata = "https://interactives.ap.org/elections/live-data/production/2020-11-03/president/metadata.json"
with urllib.request.urlopen(metadata) as url:
    data = json.loads(url.read().decode())

# candidates
candidate = data['candidates']

# states/races
race = {}

for key in data['races'].keys():
    race[key[0:2]] = data['races'][key]

# print data examples
#pprint(candidate['AK6638'])
#pprint(race['TX'])

#
# Load vote counts per state; store per subunit, per candidate
#

votecount = []

for state in race.keys():
    print(state+"... ", end="")
    cumvotes = 0

    # load json
    metadata = "https://interactives.ap.org/elections/live-data/production/2020-11-03/president/"+state+".json"
    with urllib.request.urlopen(metadata) as url:
        data = json.loads(url.read().decode())
    
    # get results
    data = data['results'][0]['results']

    # store in long format
    for subunit in data.values():
        for subunitResult in subunit['results']:
            votecount.append({"state": state, "subunitID": subunit['ruid'], "candidateID": subunitResult['candidateID'], "candidateName": candidate[subunitResult['candidateID']]['last'], "voteCount": subunitResult['voteCount']})
            cumvotes += subunitResult['voteCount']
            
    # print total votes
    print(str(cumvotes)+" votes")

#
# export as CSV
#
print("writing CSV...")

with open('US2020.csv', mode='w') as export_file:
    
    votecount_writer = csv.DictWriter(export_file, ["state","subunitID","candidateID","candidateName","voteCount"], delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    
    votecount_writer.writeheader()

    votecount_writer.writerows(votecount)
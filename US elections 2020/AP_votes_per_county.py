#
# load votes per candidate per county, from Associated Press, and save to CSV in long format
#
# candidates and states: https://interactives.ap.org/elections/live-data/production/2020-11-03/president/metadata.json
# state & county names:  https://interactives.ap.org/elections-2020/main.js
# votes per county (eg): https://interactives.ap.org/elections/live-data/production/2020-11-03/president/WA.json


import urllib.request
import json, csv, re, sys
from pprint import pprint

def partyalias(arg):
    sw = { "GOP": "republican", "Dem": "democrat", "Grn": "green", "Lib": "liberal"}
    return sw.get(arg, "")

def statename(arg):
    
    if(arg not in name_states.keys()):
    
        m = re.search("name:\"([^\"]+?)\"[^\}]+?abbr:\""+arg+"\"", nameblob)
        if(m):
            name_states[arg] = m.group(1)
        else:
            name_states[arg] = ""
        
    return name_states[arg]
    
def countyname(arg):
    if(arg not in name_counties.keys()):
        
        m = re.search("\"?"+arg+"\"?:\{name:\"([^\"]+?)( County| Parish| city)?\"", nameblob)
        if(m):
            name_counties[arg] = m.group(1)
        else:
            name_counties[arg] = ""

    return name_counties[arg]

#
# MAIN
#
if(len(sys.argv) > 1):
    outfile = str(sys.argv[1])
else:
    outfile = 'AP_US2020.csv'
    
print("Saving to "+outfile+"\n")

#
# Load candidates and list of states
#

# get metadata.json

ap_url = "https://interactives.ap.org/elections/live-data/production/2020-11-03/president/metadata.json"
with urllib.request.urlopen(ap_url) as url:
    data = json.loads(url.read().decode())

# candidates
candidates = data['candidates']

# states/races
states = {}

for key in data['races'].keys():
    states[key[0:2]] = data['races'][key]

# print data examples
print("Loaded "+str(len(candidates))+" candidates.\n\nExample: candidates['AK6638']:")
pprint(candidates['AK6638'])
print()

print("Loaded "+str(len(states))+" states.\n\nExample: states['TX']:")
pprint(states['TX'])
print()

#
# Load stupid JS file with state and county names
#
ap_url = "https://interactives.ap.org/elections-2020/main.js"

with urllib.request.urlopen(ap_url) as url:
    nameblob = url.read().decode()

# try to crop to the important bits
m = re.search("return a.DATA.*?\"use strict\"", nameblob)
if m:
    statenameblob = m.group(0)
else:
    statenameblob = nameblob

m = re.search("10:\[\"01\"\].*?\"use strict\"", nameblob)
if m:
    countynameblob = m.group(0)
else:
    countynameblob = nameblob

# cache placheholder
name_states = {}
name_counties = {}

#
# Load vote counts per state; store per subunit, per candidate
#

votecount = []
cumVotesUS = 0

for state in states.keys():
    print(state+"... ", end="")
    cumVotesState = 0

    # load json
    ap_url = "https://interactives.ap.org/elections/live-data/production/2020-11-03/president/"+state+".json"
    with urllib.request.urlopen(ap_url) as url:
        data = json.loads(url.read().decode())
    
    # get results
    data = data['results'][0]['results']

    # walk through counties
    for subunit in data.values():
        
        # get total votes
        cumVotesSubunit = 0
        for subunitResult in subunit['results']:
            cumVotesSubunit += subunitResult['voteCount']
        cumVotesState += cumVotesSubunit
        
        # walk through candidates
        for subunitResult in subunit['results']:
            votecount.append({
                "state": statename(state),
                "state_po": state,
                "county": countyname(subunit['ruid']),
                "FIPS": int(subunit['ruid']),
                "candidate": candidates[subunitResult['candidateID']]['fullName'],
                "party": partyalias(candidates[subunitResult['candidateID']]['party']),
                "candidatevotes": subunitResult['voteCount'],
                "totalvotes": cumVotesSubunit,
                "subunitID": subunit['ruid'],
                "candidateID": subunitResult['candidateID']
            })
            
    # print total votes
    print(str(cumVotesState)+" votes")
    cumVotesUS += cumVotesState

print("Total: "+str(cumVotesUS)+" votes\n")

#
# export as CSV
#
print("Writing CSV...")

with open(outfile, mode='w') as export_file:
    
    votecount_writer = csv.DictWriter(export_file, ["state", "state_po", "county", "FIPS", "candidate", "party", "candidatevotes", "totalvotes", "subunitID", "candidateID"], delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    
    votecount_writer.writeheader()

    votecount_writer.writerows(votecount)

print("done!\n")
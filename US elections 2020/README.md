# US (2020) presidential elections

You can find the following things here:

## 1) 2020 votes per county, per candidate (Associated Press)

Since the MIT Election Data-dataset doesn't contain the results from the 2020 election yet, I created a Python script to fetch this data from the various files on the AP webserver, and convert them into a CSV file in long format (one line per unique set of county-candidate).

* script: [AP_votes_per_county.py](https://github.com/cwverhey/random/blob/main/US%20elections%202020/AP_votes_per_county.py) (python3)
* output snapshot: [AP_US2020.csv](https://github.com/cwverhey/random/blob/main/US%20elections%202020/AP_US2020.csv)

Contrary to the MIT dataset, Alaska consists of just one county instead of multiple districts. The rest of the counties seem to correlate well and are easily matched to other data by FIPS county codes.

## 2) County Compliance with National Voting Outcomes 2000-2020
In hindsight, how many counties voted for the winner? Or for the loser?

Raw results can be found in [county_comply.csv](https://github.com/cwverhey/random/blob/main/US%20elections%202020/county_comply.csv). I have used the [MIT Election Data](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ) and Associated Press (AP) live results, analysed with [bellwether.R](https://github.com/cwverhey/random/blob/main/US%20elections%202020/bellwether.R)


#### How many counties voted identical to the national election results?

> Between 2000 and 2020: 7
> * Excluding 2020: 58
> * Excluding 2016: 73
> * Excluding 2012: 20
> * Excluding 2008: 9
> * Excluding 2004: 11
> * Excluding 2000: 8
> 
> There are only 7 counties that 100% followed the national outcome from 2000 to 2020.
> 
> If we *don't* look at the 2020 elections, there were 58 counties that followed the national outcome from 2000 to 2016.
>
> Something outrageous? No; if we include the 2020 tallies, but this time don't include the 2016 elections: there were 73 counties that correctly 'predicted' 2000-2012 + 2020.

## 3) Benford's Law: US counties and Chicago precincts

People love applying statistical methods to cherry-picked data, while violating all assumptions.

You'll find plots of the first tally digit in each county<sup>1</sup> for:
* [each candidate, all states](https://github.com/cwverhey/random/tree/main/US%20elections%202020/chicago2020/Benford_Candidates);
* [each state, all candidates](https://github.com/cwverhey/random/tree/main/US%20elections%202020/chicago2020/Benford_States);
* [each state, Trump v Biden](https://github.com/cwverhey/random/tree/main/US%20elections%202020/chicago2020/Benford_Trump_v_Biden);
* [all states, all candidates](https://github.com/cwverhey/random/blob/main/US%20elections%202020/chicago2020/Benford_all.png).

For Chicago<sup>2</sup>, you'll find:
* [first tally digit for each precinct, per candidate](https://github.com/cwverhey/random/blob/main/US%20elections%202020/chicago2020/chicago_benford.png)
* [number of votes per precinct, per candidate](https://github.com/cwverhey/random/blob/main/US%20elections%202020/chicago2020/chicago_hist.png) (histograms);
* [number of votes per precinct, total](https://github.com/cwverhey/random/blob/main/US%20elections%202020/chicago2020/chicago_precincts.png) (histogram).


I wrote the text below on social media, as a reply to some plots from an anonymous source linking deviation from Benford's Law in voting tallies to voter fraud.

> Benford's Law predicts the distribution of first digits in naturalistic data consisting of random random values above 0. The absent upper bound can be pretty important; if samples are random between 1 and 999 for instance, a uniform distribution is expected instead. However if samples are random between 1 and 1999, we'd expect more numbers starting with 1: 1 + 1x (10 options) + 1xx (100 options) + 1xxx (1000 options) = 1111 numbers that start with 1, versus only 9 + 9x + 9xx = 111 that start with 9. The larger the upper bound, the more the distribution will follow Benford's Law.
>
> Another underlying principle is that measurements from natural data tend to follow a logaritmic distribution.
>
> Benford's Law can still be used in voting fraud questions even despite the non-infinite amount of voters (a fixed upper bound), when
>
> 1. the upper bound per state/county/ward differs a lot, and/or
>
> 2. there is large variation in the vote proportion per sample (i.e. candidate A might get close to the upper bound in some voting districts, but it's unlikely they do in all sampled districts).
>
> I've only looked at the Chicago example. For Chicago, first consider the number of votes per precinct. We'd expect them not to vary very much: the precincts are not a natural phenomenon but instead they are man-made to include roughly similar amounts of voters. That breaks condition (1) above. I don't know the population of Chicago well enough to estimate how homogenous they vote, but since this is a city, I would expect that Biden gets a majority of the votes in a majority of the precincts, breaking condition (2) for Biden. Trump might be less popular here, but I wouldn't be surprised to see a majority vote for him in a minority of the precincts as well. For the other candidates, I expect condition (2) to hold up.
>
> The graphs made by OP are correct, though I have displayed them on a logaritmic scale instead. A distribution following Benford's Law should descend linearly on a log-scale; that's a lot easier to see with the naked eye than something that's decending logaritmically, and it's easier to spot deviations. We can see this holds true for La Riva, Carroll, and Jorgensen. Hawkins is a little off, but of course Biden and Trump are failing Benford's Law the most.
>
> In the histogram of votes per precinct, we can see how limited the precincts are in voter range: we see a very leptokurtic normal distribution, with a mean around 490 votes per precinct, strengthening the expectation that condition 1 doesn't hold.
> 
> In the histograms of Hawkins, La Riva, Carroll and Jorgensen we can see they probably obey condition 2: neither of them gets even near 100 votes per precinct. 
> 
> For Biden and Trump's histograms, it's clear that they both violate condition 2. An interesting difference is that Biden received quite some votes everywhere, but it is following a normal distribution (and my expectations for a city). Both of them, though especially Biden, clearly run into the upper bounds.

1. Associated Press<br>
2. https://chicagoelections.gov/en/election-results-specifics.asp

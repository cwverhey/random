# get county votes 2000-2016
# load CSV from https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ
votes2000 <- read.csv("countypres_2000-2016.csv")

# get county votes 2020
# from Associated Press to CSV with accompanying Python script
votes2020 <- read.csv("AP_US2020.csv")
votes2020$year <- 2020
votes2020$office <- "President"
votes2020$version <- 1
votes2020[,c("subunitID","candidateID")] <- NULL

# merge datasets 2000-2016 and 2020
votes <- rbind(votes2000, votes2020)
votes$county_long <- paste(votes$county, votes$state_po)
rm(votes2000, votes2020)

# delete records without FIPS county ID
votes <- subset(votes,!is.na(votes$FIPS))

# calculate winner per county per year
county_winner <- data.frame(FIPS=unique(votes$FIPS))
years <- unique(votes$year)

for(FIP in county_winner$FIPS) {
  county <- votes$county_long[votes$FIPS==FIP][1]
  county_winner$county[county_winner$FIPS==FIP] <- county
  
  for(year in years) {
    tally <- votes[votes$FIPS==FIP & votes$year==year, c("party","candidatevotes")]
    won <- which.max(tally$candidatevotes)
    
    # ties or missing data
    if(length(won) != 1) {
      cat(FIP, "(", county, ")", year, length(won),"winners\n")
      
    # store winner
    } else {
      county_winner[county_winner$FIPS==FIP,as.character(year)] <- switch(tally$party[won], "democrat" = "D", "republican" = "R")
    }
    
  }
}

rm(county, year, tally, won)

# get real winning parties
winner <- list("1952" = "R", "1956" = "R", "1960" = "D",	"1964" = "D",	"1968" = "R",	"1972" = "R",	"1976" = "D",	"1980" = "R",	"1984" = "R",	"1988" = "R",	"1992" = "D",	"1996" = "D",	"2000" = "R",	"2004" = "R",	"2008" = "D",	"2012" = "D",	"2016" = "R",	"2020" = "D")

# check if counties followed national results
county_comply <- data.frame(FIPS=county_winner$FIPS,county=county_winner$county)
for(year in as.character(years)) {
  county_comply[,year] <- county_winner[,year] == winner[year]
}

# calculate compliance percentage
allYears <- as.character(years)
no2000 <- allYears[allYears!="2000"]
no2004 <- allYears[allYears!="2004"]
no2008 <- allYears[allYears!="2008"]
no2012 <- allYears[allYears!="2012"]
no2016 <- allYears[allYears!="2016"]
no2020 <- allYears[allYears!="2020"]

for(i in 1:nrow(county_comply)) {
  county_comply[i,"perc_all"] <- sum(as.numeric(county_comply[i,allYears])) / length(allYears)
  county_comply[i,"perc_no2000"] <- sum(as.numeric(county_comply[i,no2000])) / length(no2000)
  county_comply[i,"perc_no2004"] <- sum(as.numeric(county_comply[i,no2004])) / length(no2004)
  county_comply[i,"perc_no2008"] <- sum(as.numeric(county_comply[i,no2008])) / length(no2008)
  county_comply[i,"perc_no2012"] <- sum(as.numeric(county_comply[i,no2012])) / length(no2012)
  county_comply[i,"perc_no2016"] <- sum(as.numeric(county_comply[i,no2016])) / length(no2016)
  county_comply[i,"perc_no2020"] <- sum(as.numeric(county_comply[i,no2020])) / length(no2020)
  
}; rm(i)

# remove counties with missing data
county_comply <- subset(county_comply,!is.na(county_comply$perc_all))

# How well did states predict the elections between 2000 and 2020?
hist(county_comply$perc_all*100, main="How did counties follow National Election Results?\n\nFrom 2000 to 2020", xlab="identical outcomes [%]", ylab="# of counties", right = T, breaks=c(seq(0,100,100/7)))
hist(county_comply$perc_no2020*100, main="How did counties follow National Election Results?\n\nFrom 2000 to 2016", xlab="identical outcomes [%]", ylab="# of counties", right = T, breaks=c(seq(0,100,100/6)))
hist(county_comply$perc_no2016*100, main="How did counties follow National Election Results?\n\nFrom 2000 to 2020, excl. 2016", xlab="identical outcomes [%]", ylab="# of counties", right = T, breaks=c(seq(0,100,100/6)))
hist(county_comply$perc_no2012*100, main="How did counties follow National Election Results?\n\nFrom 2000 to 2020, excl. 2014", xlab="identical outcomes [%]", ylab="# of counties", right = T, breaks=c(seq(0,100,100/6)))
hist(county_comply$perc_no2008*100, main="How did counties follow National Election Results?\n\nFrom 2000 to 2020, excl. 2012", xlab="identical outcomes [%]", ylab="# of counties", right = T, breaks=c(seq(0,100,100/6)))
hist(county_comply$perc_no2004*100, main="How did counties follow National Election Results?\n\nFrom 2000 to 2020, excl. 2008", xlab="identical outcomes [%]", ylab="# of counties", right = T, breaks=c(seq(0,100,100/6)))
hist(county_comply$perc_no2000*100, main="How did counties follow National Election Results?\n\nFrom 2004 to 2020", xlab="identical outcomes [%]", ylab="# of counties", right = T, breaks=c(seq(0,100,100/6)))

# How many states voted identical to the national election results?
# 
#  Between 2000 and 2020: 7
#  Excluding 2020: 58
#  Excluding 2016: 73
#  Excluding 2012: 20
#  Excluding 2008: 9
#  Excluding 2004: 11
#  Excluding 2000: 8
sum(county_comply$perc_all==1)
sum(county_comply$perc_no2020==1)
sum(county_comply$perc_no2016==1)
sum(county_comply$perc_no2012==1)
sum(county_comply$perc_no2008==1)
sum(county_comply$perc_no2004==1)
sum(county_comply$perc_no2000==1)

# There are only 7 states that 100% followed the national outcome from 2000 to 2020.
#
# If we don't look at the 2020 elections, there were 58 states that followed the national outcome from 2000 to 2016.
# Something special?
#
# No; if we include the 2020 tallies, but this time don't include the 2016 elections: there were 73 states that
# correctly predicted 2000-2012 + 2020

# save CSV
write.csv(county_comply,"county_comply.csv")
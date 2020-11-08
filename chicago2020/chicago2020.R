# Chicago 2020 Elections per precinct
#
# https://chicagoelections.gov/en/election-results-specifics.asp
#
# Election Results / 2020 General Election - 11/3/2020

# load CSV
chicago2020 <- read.csv("chicago2020.csv")

# fill missing wards
ward = 0
for(i in 1:nrow(chicago2020)) {
  if(is.na(chicago2020$ward[i])) {
    chicago2020$ward[i] = ward
  } else {
    ward = chicago2020$ward[i]
  }
}

# get list of candidates
candidates <- colnames(chicago2020)[4:ncol(chicago2020)]

# set plot layout
par(mfrow=c(3,2), mar = c(3, 3, 3, 3), mgp = c(1.8,.7,0))

# bar plot of first digits per candidate
for(candidate in candidates) {
  
  print(candidate)
  votes <- chicago2020[,candidate]
  prec  <- sum(chicago2020[,candidate] != 0)
  
  firstDigits <- factor(substr(votes,1,1), levels = 1:9)
  fTable <- table(firstDigits)
  fTable[fTable==0] <- NA
  print(fTable)
  
  barplot(fTable, log="y", ylim = c(1,max(fTable,na.rm=T)), main=paste0(candidate,", Chicago (",sum(fTable, na.rm=T)," precincts)"), xlab="# of votes per precinct, first digit", ylab="frequency")

}

# histogram per candidate
for(candidate in candidates) {
  print(candidate)
  prec <- sum(chicago2020[,candidate] != 0)
  
  hist(chicago2020[,candidate],main=paste0(candidate,", Chicago (",prec," precincts)"), xlab="# of votes per precinct", ylab="frequency")
}

# histogram Chicago
par(mfrow=c(1,1))
hist(chicago2020$votes,main="Chicago, votes per precinct",xlab="votes",ylab="frequency")
  

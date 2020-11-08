# load CSV
us2020 <- read.csv("US2020.csv")

# remove zero votes
us2020 <- subset(us2020, voteCount > 0)

# get metadata
us2020$firstDigit <- factor(substr(us2020$voteCount,1,1), levels = 1:9)
states            <- unique(us2020$state)
candidates        <- unique(us2020$candidateName)

# all vote counts
par(mfrow=c(1,1), mar = c(3, 3, 3, 3), mgp = c(1.8,.7,0)) # set plot layout
png(file=paste0("Benford_all.png"), height=400, width=600)
name <- "all candidates, all subdivisions"
data <- table(us2020$firstDigit)
barplot(data, log="y", ylim = c(1,max(data)), main=paste0(name," (n=",sum(data),")"), xlab="# of votes by first digit", ylab="frequency")
dev.off()

# by candidate, all states
par(mfrow=c(3,2), mar = c(3, 3, 3, 3), mgp = c(1.8,.7,0)) # set plot layout
for(candidate in candidates) {
  png(file=paste0("Benford_Candidates/",candidate,".png"), height=400, width=600)
  name <- candidate
  data <- table(us2020$firstDigit[us2020$candidateName==candidate])
  data[data==0] <- NA
  barplot(data, log="y", ylim = c(1,max(data,na.rm=T)), main=paste0(name," (",sum(data,na.rm=T)," subdivisions)"), xlab="# of votes, first digit", ylab="frequency")
  dev.off()
}

# by state, all candidates
par(mfrow=c(3,2), mar = c(3, 3, 3, 3), mgp = c(1.8,.7,0)) # set plot layout
for(state in states) {
  png(file=paste0("Benford_States/",state,".png"), height=400, width=600)
  name <- state
  data <- table(us2020$firstDigit[us2020$state==state])
  data[data==0] <- NA
  barplot(data, log="y", ylim = c(1,max(data,na.rm=T)), main=paste0(name," (",sum(data,na.rm=T)," subdivisions)"), xlab="# of votes, first digit", ylab="frequency")
  dev.off()
}

# by state, Trump v Biden (>10 subdivisions only)
par(mfrow=c(3,2), mar = c(3, 3, 3, 3), mgp = c(1.8,.7,0))  # set plot layout
for(state in states) {

  if( length(unique(us2020$subunitID[us2020$state==state])) >= 10) {
  
    png(file=paste0("Benford_Trump_v_Biden/",state,".png"), height=400, width=600)
    
    name <- state
    
    Trump <- table(us2020$firstDigit[us2020$state==state & us2020$candidateName=="Trump"])
    Trump[Trump==0] <- NA
    
    Biden <- table(us2020$firstDigit[us2020$state==state & us2020$candidateName=="Biden"])
    Biden[Biden==0] <- NA
    
    barplot(cbind(Trump,Biden), beside=T, col=c("#D31924","#D31924","#D31924","#D31924","#D31924","#D31924","#D31924","#D31924","#D31924","#0091D2","#0091D2","#0091D2","#0091D2","#0091D2","#0091D2","#0091D2","#0091D2","#0091D2"), log="y", ylim = c(1,max(Biden,Trump,na.rm=T)), main=paste0("Trump v Biden, ",name," (",max(sum(Trump,na.rm=T),sum(Biden,na.rm=T))," subdivisions)"), xlab="# of votes, first digit", ylab="frequency")

    dev.off()
    
  }
}

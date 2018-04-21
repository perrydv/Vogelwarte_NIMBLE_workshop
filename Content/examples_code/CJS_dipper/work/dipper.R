load('dipperData.RData')

last <- apply(y, 1, function(hist) max(which(hist==1)))
nSightings <- apply(y, 1, function(hist) sum(hist, na.rm=TRUE))
yDHMM <- 2 - y ## integer states: seen, no seen
## dipperCJS (y[i] ~ dCJS(...) for nimble only)
code <- quote({
    phi ~ dunif(0, 1)
    p ~ dunif(0, 1)
    ##for (i in 1:nind) {
    ##    y[i, first[i]:k] ~ dCJS(length=k-first[i]+1, last=last[i]-first[i]+1, phi=phi, p=p)
    ##}
    chi[k] <- 1
    for(j in 1:(k-1))
        chi[k-j] <- (1-phi) + phi * (1-p) * chi[k-j+1]
    for(j in 1:k)
        logChi[j] <- log(chi[j])
    for(i in 1:nind)
        onesVector[i] ~ dCJS(first=first[i], last=last[i], nSightings=nSightings[i], phi=phi, p=p, logChi=logChi[1:k])
})
constants <- list(k=k, nind=nind, first=first, last=last, nSightings=nSightings)
data      <- list(onesVector=rep(1,nind))
inits     <- list(phi=0.6, p=0.9)
dipperCJS <- list(code=code, constants=constants, data=data, inits=inits)


## maximally efficient NIMBLE implementation for Dipper model
## dipperCJS2 (y[i] ~ dCJS2(...) for nimble only)
code <- quote({
    phi ~ dunif(0, 1)
    p ~ dunif(0, 1)
    chi[k] <- 1
    for(j in 1:(k-1))
        chi[k-j] <- (1-phi) + phi * (1-p) * chi[k-j+1]
    for(j in 1:k)
        logChi[j] <- log(chi[j])
    for(i in 1:nind)
        zerosVector[i] ~ dCJS2(length=length[i], nSightingsMinus1=nSightingsMinus1[i], nNonSightings=nNonSightings[i], log_phi=log(phi), log_pp=log(p), log_1minusP=log(1-p), logChi=logChi[last[i]])
})
constants  <- list(k=k, nind=nind, length=last-first, nSightingsMinus1=nSightings-1, nNonSightings=last-first-nSightings+1, last=last)
data       <- list(zerosVector=rep(0,nind))
inits      <- list(phi=0.6, p=0.9)
dipperCJS2 <- list(code=code, constants=constants, data=data, inits=inits)



## dipperChiJAGSfunction (using chi trick, runs jags only)
dipperChiJAGSfunction <- function(niter = 100000) {
    sink('dipperChi.jags')
    cat('
model {
    phi ~ dunif(0, 1)
    p ~ dunif(0, 1)
    for(i in 1:nind) {
        for(j in (first[i]+1):last[i]) {
            y[i,j] ~ dbin(p, 1)
            onesMatrix[i,j] ~ dbin(phi, 1)
        }
        onesVector[i] ~ dbin(chi[last[i]], 1)
    }
    chi[k] <- 1
    for(j in 1:(k-1)) {
        chi[k-j] <- (1-phi) + phi * (1-p) * chi[k-j+1]
    }
}
',fill=TRUE) 
    sink()
    load('~/github/userDistMCMC/dipperData.RData')
    ## optionally truncate data:
    last <- apply(y, 1, function(hist) max(which(hist==1)))
    yDHMM <- 2 - y
    onesMatrix = matrix(1,nind,k)  ## 'ones' matrix for survival
    onesVector = rep(1,nind)       ## 'ones' vector for chi
    if(trunc) { ind <- 1:3;   nind<-length(ind);   first<-first[ind];   last<-last[ind];   y<-y[ind,,drop=FALSE];   yDHMM<-yDHMM[ind,,drop=FALSE];   x_init<-x_init[ind,,drop=FALSE];   onesMatrix<-onesMatrix[ind,,drop=FALSE];   onesVector<-onesVector[ind] }
    jags_data <- list(y=y, onesMatrix=onesMatrix, onesVector=onesVector, k=k, nind=nind, first=first, last=last)
    initFunction <- function() list(phi=0.6, p=0.9)
    parameters <- c('p', 'phi')
    library(R2WinBUGS) 
    library(R2jags) 
    t <- system.time({ls <- jags(jags_data, initFunction, parameters, "dipperChi.jags", n.chains = 1, n.thin = 1, n.iter = niter, n.burnin = 2000, working.directory = getwd())})
    unlink('dipperChi.jags')
    ar <- ls$BUGSoutput$sims.array    ## using sims.array is consistent with MCMCsuite
    ar <- ar[,1,]     ## drop middle index
    ar <- ar[, dimnames(ar)[[2]] != 'deviance']    ## drop deviance
    summaryStats <- c('mean', 'median', 'sd', 'CI95_low', 'CI95_upp', 'effectiveSize')
    library(coda)
    CI95_low <- function(x) quantile(x, probs = 0.025)
    CI95_upp <- function(x) quantile(x, probs = 0.975)
    nSummaryStats <- length(summaryStats)
    nMonitorNodes <- dim(ar)[2]
    summaryArray <- array(NA, c(nSummaryStats, nMonitorNodes))
    dimnames(summaryArray) <- list(summaryStats, dimnames(ar)[[2]])
    summaryStatFunctions <- lapply(summaryStats, function(txt) eval(parse(text=txt)[[1]]))
    for(iStat in seq_along(summaryStats)) {
        summaryArray[iStat, ] <- apply(ar, 2, summaryStatFunctions[[iStat]])
    }
    message('APPLYING effectiveSize() TO ', dim(ar)[1], ' JAGS SAMPLES')
    theTime <- as.numeric(t[3])    ## this is consistent with MCMCsuite (now in seconds!)
    list(theTime=theTime, summary=summaryArray)
}



## dipperPoissonJAGSfunction (using chi trick, runs jags only)
dipperPoissonJAGSfunction <- function(niter = 100000) {
    sink('dipperPoisson.jags')
    cat('
model {
    phi ~ dunif(0, 1)
    p ~ dunif(0, 1)
    chi[k] <- 1
    for(j in 1:(k-1)) {
        chi[k-j] <- (1-phi) + phi * (1-p) * chi[k-j+1]
    }
    for(j in 1:k) {
        logChi[j] <- log(chi[j])
    }
    for(i in 1:nind) {
        logL[i] <- -1*length[i]*log(phi) - nSightingsMinus1[i]*log(p) - nNonSightings[i]*log(1-p) - logChi[last[i]]
        zerosVector[i] ~ dpois(logL[i])
    }
}
',fill=TRUE) 
    sink()
    load('~/github/userDistMCMC/dipperData.RData')
    ## optionally truncate data:
    last <- apply(y, 1, function(hist) max(which(hist==1)))
    nSightings <- apply(y, 1, function(hist) sum(hist, na.rm=TRUE))
    zerosVector <- rep(0,nind)
    if(trunc) { ind <- 1:3;   nind<-length(ind);   first<-first[ind];   last<-last[ind];   y<-y[ind,,drop=FALSE];   nSightings<-nSightings[ind];   zerosVector<-zerosVector[ind] }
    jags_data <- list(zerosVector=zerosVector, k=k, nind=nind, length=last-first, nSightingsMinus1=nSightings-1, nNonSightings=last-first-nSightings+1, last=last)
    initFunction <- function() list(phi=0.6, p=0.9)
    parameters <- c('p', 'phi')
    library(R2WinBUGS) 
    library(R2jags) 
    t <- system.time({ls <- jags(jags_data, initFunction, parameters, "dipperPoisson.jags", n.chains = 1, n.thin = 1, n.iter = niter, n.burnin = 2000, working.directory = getwd())})
    unlink('dipperPoisson.jags')
    ar <- ls$BUGSoutput$sims.array    ## using sims.array is consistent with MCMCsuite
    ar <- ar[,1,]     ## drop middle index
    ar <- ar[, dimnames(ar)[[2]] != 'deviance']    ## drop deviance
    summaryStats <- c('mean', 'median', 'sd', 'CI95_low', 'CI95_upp', 'effectiveSize')
    library(coda)
    CI95_low <- function(x) quantile(x, probs = 0.025)
    CI95_upp <- function(x) quantile(x, probs = 0.975)
    nSummaryStats <- length(summaryStats)
    nMonitorNodes <- dim(ar)[2]
    summaryArray <- array(NA, c(nSummaryStats, nMonitorNodes))
    dimnames(summaryArray) <- list(summaryStats, dimnames(ar)[[2]])
    summaryStatFunctions <- lapply(summaryStats, function(txt) eval(parse(text=txt)[[1]]))
    for(iStat in seq_along(summaryStats)) {
        summaryArray[iStat, ] <- apply(ar, 2, summaryStatFunctions[[iStat]])
    }
    message('APPLYING effectiveSize() TO ', dim(ar)[1], ' JAGS SAMPLES')
    theTime <- as.numeric(t[3])    ## this is consistent with MCMCsuite (now in seconds!)
    list(theTime=theTime, summary=summaryArray)
}

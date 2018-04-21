## TO-DO: Rewrite the dCJS to be a little more general.
## Skip dCJS2
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

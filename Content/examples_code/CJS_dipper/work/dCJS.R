

dCJS <- nimbleFunction(
    run = function(x = double(),
                   first = double(),
                   last = double(),
                   nSightings = double(),
                   phi = double(),
                   p = double(),
                   logChi = double(1),
                   log.p = double()) {
        logL <- (last-first)*log(phi) +
            (nSightings-1)*log(p) +
            (last-first-nSightings+1)*log(1-p) +
            logChi[last]
        returnType(double())
        if(log.p)
            return(logL)
        else
            return(exp(logL))
    }
)

rCJS <- nimbleFunction(
    run = function(n = integer(),
        ##length = double(), last = double(), phi = double(), p = double())
        first = double(), last = double(), nSightings = double(), phi = double(), p = double(), logChi = double(1)) {
        if(n != 1) print('should only specify n=1 in rCJS() distribution')
        print('STILL NEED TO WRITE THE rCJS() METHOD!')
        returnType(double())
        return(1)
    }
)


## maximally efficient NIMBLE implementation for Dipper model
dCJS2 <- nimbleFunction(
    run = function(x = double(),
                   length = double(),
                   nSightingsMinus1 = double(),
                   nNonSightings = double(),
                   log_phi = double(),
                   log_pp = double(),
                   log_1minusP = double(),
                   logChi = double(),
                   log.p = double()) {
        logL <- length*log_phi + nSightingsMinus1*log_pp + nNonSightings*log_1minusP + logChi
        returnType(double())
        return(logL)
    }
)

rCJS2 <- nimbleFunction(
    run = function(n = integer(),
        ##length = double(), last = double(), phi = double(), p = double())
        ##first = double(), last = double(), nSightings = double(), phi = double(), p = double(), logChi = double(1)) {
        length = double(), nSightingsMinus1 = double(), nNonSightings = double(), log_phi = double(), log_pp = double(), log_1minusP = double(), logChi = double()) {
        if(n != 1) print('should only specify n=1 in rCJS2() distribution')
        print('STILL NEED TO WRITE THE rCJS2() METHOD!')
        returnType(double())
        return(1)
    }
)

## maximally efficient NIMBLE DHMM implementation for Orchid model
dDHMMorchid <- nimbleFunction(
    run = function(x = double(1),
        length = double(), prior = double(1),
        Z = double(2),
        T = double(3),
        log.p = double()) {
        pi <- prior
        logL <- 0
        for(t in 1:length) {
            Zpi <- Z[x[t], ] * pi
            sumZpi <- sum(Zpi)
            logL <- logL + log(sumZpi)
            if(t != length)   pi <- (T[,,t] %*% asCol(Zpi) / sumZpi)[ ,1]
        }
        returnType(double())
        ##if(log.p) return(logL) else return(exp(logL))
        return(logL)
    }
)

rDHMMorchid <- nimbleFunction(
    run = function(n = integer(),
        length = double(), prior = double(1),
        Z = double(2),
        T = double(3)) {
        if(n != 1) print('should only specify n=1 in rDHMM() distribution')
        print('STILL NEED TO WRITE THE rDHMM() METHOD!')
        returnType(double(1))
        return(nimVector(1, length))
    }
)

## Adapted from code of Turek et al. (2016)
dDHMMorchid <- nimbleFunction(
    run = function(x = double(1),    ## Observed capture (state) history
                   length = double(),## length of x (needed as a separate param for rDHMM)
                   prior = double(1),## 
                   Z = double(2),
                   T = double(3),
                   log = integer(0, default = 0)) {
        pi <- prior
        logL <- 0
        for(t in 1:length) {
            Zpi <- Z[x[t], ] * pi
            sumZpi <- sum(Zpi)
            logL <- logL + log(sumZpi)
            if(t != length)   pi <- (T[,,t] %*% asCol(Zpi) / sumZpi)[ ,1]
        }
        returnType(double())
        if(log) return(logL)
        return(exp(logL))
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
        return(numeric(length, value = 1))
    }
)

orchids_DHMM_code <- quote({
    ## -------------------------------------------------
    ## Parameters:
    ## s: survival probability 
    ## psiV: transitions from vegetative 
    ## psiF: transitions from flowering 
    ## psiD: transitions from dormant 
    ## -------------------------------------------------
    ## States (S):
    ## 1 vegetative 
    ## 2 flowering 
    ## 3 dormant 
    ## 4 dead 
    ## Observations (O):  
    ## 1 seen vegetative 
    ## 2 seen flowering 
    ## 3 not seen 
    ## -------------------------------------------------
    ## Priors and constraints 
    ## Survival: uniform 
    for (t in 1:(k-1)){  
        s[t] ~ dunif(0, 1)
    }
    ## Transitions: gamma priors 
    for (i in 1:3){
        a[i] ~ dgamma(1, 1) 
        psiD[i] <- a[i]/sum(a[1:3]) 
        b[i] ~ dgamma(1, 1) 
        psiV[i] <- b[i]/sum(b[1:3]) 
        c[i] ~ dgamma(1, 1) 
        psiF[i] <- c[i]/sum(c[1:3]) 
    }
    ## Define state-transition and observation matrices 	
    for (t in 1:(k-1)) {
        T[1,1,t] <- s[t] * psiV[1]
        T[2,1,t] <- s[t] * psiV[2]
        T[3,1,t] <- s[t] * psiV[3]
        T[4,1,t] <- 1-s[t]
        T[1,2,t] <- s[t] * psiF[1]
        T[2,2,t] <- s[t] * psiF[2]
        T[3,2,t] <- s[t] * psiF[3]
        T[4,2,t] <- 1-s[t]
        T[1,3,t] <- s[t] * psiD[1]
        T[2,3,t] <- s[t] * psiD[2]
        T[3,3,t] <- s[t] * psiD[3]
        T[4,3,t] <- 1-s[t]
        T[1,4,t] <- 0
        T[2,4,t] <- 0
        T[3,4,t] <- 0
        T[4,4,t] <- 1
    }
    T[1,1,k] <- 1
    T[2,1,k] <- 0
    T[3,1,k] <- 0
    T[4,1,k] <- 0
    T[1,2,k] <- 0
    T[2,2,k] <- 1
    T[3,2,k] <- 0
    T[4,2,k] <- 0
    T[1,3,k] <- 0
    T[2,3,k] <- 0
    T[3,3,k] <- 1
    T[4,3,k] <- 0
    T[1,4,k] <- 0
    T[2,4,k] <- 0
    T[3,4,k] <- 0
    T[4,4,k] <- 1
    for (i in 1:nind) {
        y[i, f[i]:k] ~ dDHMMorchid(length = k-f[i]+1,
                                   prior = prior[1:4],
                                   Z = Z[1:3,1:4],
                                   T = T[1:4,1:4,f[i]:k])
    }
})

## CH <- as.matrix(read.table("~/github/userDistMCMC/orchids.txt", sep=" ", header = FALSE))
## ## first, remove all individuals not seen until the last occasion:
## f <- numeric()
## for (i in 1:dim(CH)[1])
##     f[i] <- min(which(CH[i,]!=0))
## CH <- CH[which(f!=11), ]  ## remove all individuals not seen until the last occasion:
## rCH <- CH  # Recoded CH 
## rCH[rCH==0] <- 3
## nind <- dim(rCH)[1]
## k <- dim(rCH)[2]
## f <- numeric()   ## vector with occasion of first capture 
## for (i in 1:dim(CH)[1])
##     f[i] <- min(which(CH[i,]!=0))
## Z <- array(c(1,0,0, ## column 1
##              0,1,0, ## column 2, etc.
##              0,0,1,
##              0,0,1),
##            c(3,4))
## orchids_DHMM_constants <- list(f=f,
##                                k=k,
##                                nind=nind,
##                                prior=c(1/2,1/2,0,0),
##                                Z=Z)
## orchids_DHMM_data <- list(y = rCH)
## inits <- list(s = rep(1/2,k-1),
##               a = rep(1,3),
##               b = rep(1,3),
##               c = rep(1,3))

## orchidDHMM2 <- list(code=code, constants=constants, data=data, inits=inits)

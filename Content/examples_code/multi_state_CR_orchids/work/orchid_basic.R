## From Section 9.7 of BPA code
CH <- as.matrix(read.table("orchids.txt", sep=" ", header = FALSE))
n_occasions <- dim(CH)[2]
# Compute vector with occasion of first capture
f <- numeric()
for (i in 1:dim(CH)[1]){f[i] <- min(which(CH[i,]!=0))}
## Recode CH matrix: note, a 0 is not allowed by WinBUGS!
## 1 = seen vegetative, 2 = seen flowering, 3 = not seen 
rCH <- CH  # Recoded CH 
rCH[rCH==0] <- 3 
## Specify model in BUGS language 
# "ladyslipper.jags" in BPA code
library(nimble)
nimbleOptions(disallow_multivariate_argument_expressions = FALSE)
orchidCode <- nimbleCode({
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
    for (t in 1:(n_occasions-1)){  
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
    for (i in 1:nind){
        ## Define probabilities of state S(t+1) given S(t) 
        for (t in 1:(n_occasions-1)){
            ps[1,i,t,1] <- s[t] * psiV[1]
            ps[1,i,t,2] <- s[t] * psiV[2]
            ps[1,i,t,3] <- s[t] * psiV[3]
            ps[1,i,t,4] <- 1-s[t]
            ps[2,i,t,1] <- s[t] * psiF[1]
            ps[2,i,t,2] <- s[t] * psiF[2]
            ps[2,i,t,3] <- s[t] * psiF[3]
            ps[2,i,t,4] <- 1-s[t]
            ps[3,i,t,1] <- s[t] * psiD[1]
            ps[3,i,t,2] <- s[t] * psiD[2]
            ps[3,i,t,3] <- s[t] * psiD[3]
            ps[3,i,t,4] <- 1-s[t]
            ps[4,i,t,1] <- 0 
            ps[4,i,t,2] <- 0 
            ps[4,i,t,3] <- 0 
            ps[4,i,t,4] <- 1 
            ## Define probabilities of O(t) given S(t) 
            po[1,i,t,1] <- 1 
            po[1,i,t,2] <- 0 
            po[1,i,t,3] <- 0 
            po[2,i,t,1] <- 0 
            po[2,i,t,2] <- 1 
            po[2,i,t,3] <- 0 
            po[3,i,t,1] <- 0 
            po[3,i,t,2] <- 0 
            po[3,i,t,3] <- 1 
            po[4,i,t,1] <- 0 
            po[4,i,t,2] <- 0 
            po[4,i,t,3] <- 1 
        } #t 
    } #i 
    ## Likelihood
    for (i in 1:nind){
        ## Define latent state at first capture 
        z[i,f[i]] <- y[i,f[i]]
        for (t in (f[i]+1):n_occasions){
            ## State process: draw S(t) given S(t-1)
            z[i,t] ~ dcat(ps[z[i,t-1], i, t-1, 1:4]) 
            ## Observation process: draw O(t) given S(t) 
            y[i,t] ~ dcat(po[z[i,t], i, t-1, 1:3]) 
        } #t 
    } #i
})

## Function to create known latent states z 
known_state_ms <- function(ms, notseen){
    ## notseen: label for not seen 
    state <- ms 
    state[state==notseen] <- NA 
    for (i in 1:dim(ms)[1]){
        m <- min(which(!is.na(state[i,]))) 
        state[i,m] <- NA 
    }
    return(state) 
}
## Bundle data 
jags_data <- list(y = rCH,
                  f = f,
                  n_occasions = dim(rCH)[2],
                  nind = dim(rCH)[1],
                  z = known_state_ms(rCH, 3)) 

## Note that all initial values of the unknown z must all be 3 (not 1 or 2). Therefore the function ms_init_z need some slight changes. 
## ms_init_z <- function(ch, f){
##     for (i in 1:dim(ch)[1]){
##         ch[i,1:f[i]] <- NA
##     }
##     states <- 3
##     v <- which(ch==states) 
##     ch[-v] <- NA 
##     ch[v] <- states
##     return(ch) 
## }

ms_init_z <- function(ch, f){
   for (i in 1:dim(ch)[1]){ch[i,1:f[i]] <- NA}
   states <- max(ch, na.rm = TRUE)
   known.states <- 1:(states-1)
   v <- which(ch==states)
   ch[-v] <- NA
   ch[v] <- sample(known.states, length(v), replace = TRUE)
   return(ch)
   }
## Initial values 
initFunction <- function(){
    list(s = runif((dim(rCH)[2]-1), 0, 1),
         z = ms_init_z(rCH, f)
         )}
    ## Parameters monitored 
parameters <- c("s", "psiV", "psiF", "psiD")
## One could argue to monitor the underlying random variables instead:
## parameters <- c('a', 'b', 'c', 's')

orchid <- list(code=orchidCode, data=jags_data, inits=initFunction())

orchidModel <- nimbleModel(
    orchid$code,
    constants = orchid$data,
    inits = orchid$inits
, calculate = TRUE)

orchidMCMC <- buildMCMC(orchidModel)

options(error = recover)
orchidMCMC$run(niter = 3)

orchidModel$initializeInfo()

orchid_basic <- compareMCMCs(
    orchid,
    MCMCs = c("jags", "nimble"),
    monitors = parameters,
    niter = 20000,
    burnin = 2000,
    summary = FALSE
)

## These runs are not long enough.
## Slice sampling b[1] and b[2] might help

make_MCMC_comparison_pages(orchid_basic,
                           dir = "comparison_results",
                           modelNames = "orchid_basic")

browseURL(Sys.glob(file.path("comparison_results", "orchid_basic.html")))


## orchidDHMM (multistate, from Kery & Schaub, y[i] ~ dDHMM(...) for nimble only)
## (9.7. Real data example: the showy lady's slipper)
code <- quote({
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

CH <- as.matrix(read.table("~/github/userDistMCMC/orchids.txt", sep=" ", header = FALSE))
## first, remove all individuals not seen until the last occasion:
f <- numeric()
for (i in 1:dim(CH)[1])
    f[i] <- min(which(CH[i,]!=0))
CH <- CH[which(f!=11), ]  ## remove all individuals not seen until the last occasion:
## optionally truncate data:
if(trunc) {
    ind <- 1:5
    CH <- CH[ind,]
}
rCH <- CH  # Recoded CH 
rCH[rCH==0] <- 3
nind <- dim(rCH)[1]
k <- dim(rCH)[2]
f <- numeric()   ## vector with occasion of first capture 
for (i in 1:dim(CH)[1])
    f[i] <- min(which(CH[i,]!=0))
Z <- array(c(1,0,0, ## column 1
             0,1,0, ## column 2, etc.
             0,0,1,
             0,0,1),
           c(3,4))
constants <- list(f=f,
                  k=k,
                  nind=nind,
                  prior=c(1/2,1/2,0,0),
                  Z=Z)
data <- list(y = rCH)
inits <- list(s = rep(1/2,k-1),
              a = rep(1,3),
              b = rep(1,3),
              c = rep(1,3))

orchidDHMM2 <- list(code=code, constants=constants, data=data, inits=inits)

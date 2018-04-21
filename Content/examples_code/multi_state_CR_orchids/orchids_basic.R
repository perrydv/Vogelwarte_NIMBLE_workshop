source("orchids_setup_data.R")

library(nimble)
nimbleOptions(disallow_multivariate_argument_expressions = FALSE)
orchids_code <- nimbleCode({
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

orchids_info <- list(code=orchids_code, data=orchids_data, inits=orchids_inits())

## parameters <- c("s", "psiV", "psiF", "psiD")
## ## One could argue to monitor the underlying random variables instead:
## ## parameters <- c('a', 'b', 'c', 's')


## orchid_basic <- compareMCMCs(
##     orchid,
##     MCMCs = c("jags", "nimble"),
##     monitors = parameters,
##     niter = 20000,
##     burnin = 2000,
##     summary = FALSE
## )

## ## These runs are not long enough.
## ## Slice sampling b[1] and b[2] might help

## make_MCMC_comparison_pages(orchid_basic,
##                            dir = "comparison_results",
##                            modelNames = "orchid_basic")

## browseURL(Sys.glob(file.path("comparison_results", "orchid_basic.html")))

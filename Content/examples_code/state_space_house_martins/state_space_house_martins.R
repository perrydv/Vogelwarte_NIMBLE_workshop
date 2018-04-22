library(nimble)
ssmCode <- nimbleCode({
        # Priors and constraints
        logN.est[1] ~ dnorm(5.6, 0.01)    # Prior for initial population size
        mean.r ~ dnorm(1, 0.001)          # Prior for mean growth rate
        sigma.proc ~ dunif(0, 1)          # Prior for sd of state process
        sigma2.proc <- pow(sigma.proc, 2)
        tau.proc <- pow(sigma.proc, -2)
        sigma.obs ~ dunif(0, 1)           # Prior for sd of observation process
        sigma2.obs <- pow(sigma.obs, 2)
        tau.obs <- pow(sigma.obs, -2)

        # State process
        for (t in 1:(T-1)){
           r[t] ~ dnorm(mean.r, tau.proc)
           logN.est[t+1] <- logN.est[t] + r[t]
        }

        # Likelihood
        # Observation process 
        for (t in 1:T) {
           y[t] ~ dnorm(logN.est[t], tau.obs)
        }

        # Population sizes on real scale
        for (t in 1:T) {
            N.est[t] <- exp(logN.est[t])
        }
})

# Code from BPA book:
pyears <- 6 # Number of future years with predictions
hm <- c(271, 261, 309, 318, 231, 216, 208, 226, 195, 226, 233, 209, 
   226, 192, 191, 225, 245, 205, 191, 174, rep(NA, pyears))
year <- 1990:(2009 + pyears)

# Bundle data
bugs.data <- list(y = log(hm), T = length(year))
## NIMBLE will handle y as data, T as a constant

# Initial values
inits <- function(){
      list(sigma.proc = runif(1, 0, 1), mean.r = rnorm(1),
                         sigma.obs = runif(1, 0, 1), 
                         logN.est = c(rnorm(1, 5.6, 0.1), 
                                  rep(NA, (length(year)-1))))
}

ssm <- nimbleModel(ssmCode,
                   constants = bugs.data, 
                   inits = inits())

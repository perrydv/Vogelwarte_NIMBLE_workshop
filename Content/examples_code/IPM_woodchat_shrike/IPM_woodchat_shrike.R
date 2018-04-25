## Thanks to Michael Schaub for this example

### Setup provided by Michael Schaub
# Example of an integrated population model for a woodchat shrike (passerine bird)

# Available data:
# - marray: capture-recapture data in the marray format. It's a 3D array, the third dimension being the age (juvenile vs. adult)
# - count: population counts in each year
# - productivity data: vector J is the number of fledglings per year and B is the annual number of surveyed broods which give raise to the number of fledglings.

# Some features of the model:
# - based on the life history of a passerine (2 age classes for survival, age at first reproduction = 1 year)
# - includes demographic and environmental stochasticity (i.e temporal random effects on all demographic rates)

##############################################

# Load data
load("WoodchatShrike.Rdata")

# Define a function which produces the necessary values to create a discrete uniform prior in JAGS using dcat  
disc.unif <- function(A, B){
   pprob <- c(rep(0, A-1), rep(1/(B-A+1), (B-A+1)))
   return(pprob)
   }


library(nimble)


## nimble model code,
## slightly modified from JAGS code
ipm_code <- nimbleCode({ 

# Priors and linear models
mean.logit.sj <- logit(mean.sj)
mean.sj ~ dunif(0, 1) 
mean.logit.sa <- logit(mean.sa)
mean.sa ~ dunif(0, 1) 
mean.p ~ dunif(0, 1)
mean.log.f <- log(mean.f)
mean.f ~ dunif(0, 10)

for (t in 1:(n.occasions-1)){
   p[t] <- mean.p
   }

for (t in 1:(n.occasions-1)){             
   logit.sj[t] <- mean.logit.sj + eps.sj[t]
   eps.sj[t] ~ dnorm(0, tau.sj)
   sj[t] <- ilogit(logit.sj[t])         # back transformation from logit scale
   logit.sa[t] <- mean.logit.sa + eps.sa[t]
   eps.sa[t] ~ dnorm(0, tau.sa)
   sa[t] <- ilogit(logit.sa[t])
   }

for (t in 1:(n.occasions)){   
   log.f[t] <- mean.log.f + eps.f[t]
   eps.f[t] ~ dnorm(0, tau.f)
   f[t] <- exp(log.f[t])         # back transformation from log scale
   }

sigma.sj ~ dunif(0, 10)
tau.sj <- pow(sigma.sj, -2)
sigma.sa ~ dunif(0, 10)
tau.sa <- pow(sigma.sa, -2)
sigma.f ~ dunif(0, 10)
tau.f <- pow(sigma.f, -2)

sigma.obs ~ dunif(0.5, 50)
tau.obs <- pow(sigma.obs, -2)


# State-space model for count data
# Model for the initial population size
N[1,1] ~ dcat(pNinit[])
N[2,1] ~ dcat(pNinit[])

# Process model over time
for (t in 1:(n.occasions-1)){  
   N[1,t+1] ~ dpois(sj[t] * f[t] * (N[1,t] + N[2,t])) 
   N[2,t+1] ~ dbin(sa[t], (N[1,t] + N[2,t]))
   }

# Observation model
for (t in 1:n.occasions){
   count[t] ~ dnorm(N[1,t] + N[2,t], tau.obs)
   }


# Poisson regression model for productivity data
for (t in 1:n.occasions){
   J[t] ~ dpois(f[t] * B[t])
   }

# Capture-recapture model (multinomial likelihood)
# Define the multinomial likelihood
for (t in 1:(n.occasions-1)){
    ## nimble needs more explicit indexing, so replace as follows.
    ## (An alternative is to use dimensions argument to nimbleModel.)
    ##   marr.j[t,1:n.occasions] ~ dmulti(pr.j[t,], rel.j[t])
       marr.j[t,1:n.occasions] ~ dmulti(pr.j[t,1:n.occasions], rel.j[t])
    ##    marr.a[t,1:n.occasions] ~ dmulti(pr.a[t,], rel.a[t])
       marr.a[t,1:n.occasions] ~ dmulti(pr.a[t,1:n.occasions], rel.a[t])
   }
# Define the cell probabilities of the m-arrays
# Main diagonal
for (t in 1:(n.occasions-1)){
   q[t] <- 1-p[t]   # Probability of non-recapture
   pr.j[t,t] <- sj[t]*p[t]
   pr.a[t,t] <- sa[t]*p[t]
   # Above main diagonal
   for (j in (t+1):(n.occasions-1)){
      pr.j[t,j] <- sj[t]*prod(sa[(t+1):j])*prod(q[t:(j-1)])*p[j]
      pr.a[t,j] <- prod(sa[t:j])*prod(q[t:(j-1)])*p[j]
      } #j
   # Below main diagonal
   for (j in 1:(t-1)){
      pr.j[t,j] <- 0
      pr.a[t,j] <- 0
      } #j
   } #t
# Last column: probability of non-recapture
for (t in 1:(n.occasions-1)){
   pr.j[t,n.occasions] <- 1-sum(pr.j[t,1:(n.occasions-1)])
   pr.a[t,n.occasions] <- 1-sum(pr.a[t,1:(n.occasions-1)])
   } #t


# Derived parameters
# Total population size
for (t in 1:(n.occasions)){
   Ntot[t] <- N[1,t] + N[2,t]
   }
} )


# Bundle data
bugs.data <- list(marr.j = marray[,,1], marr.a = marray[,,2], n.occasions = dim(marray)[2], rel.j = rowSums(marray[,,1]), rel.a = rowSums(marray[,,2]), J = J, B = B, count = count, pNinit = disc.unif(1, 300))

# Initial values
inits <- function(){list(mean.sj = runif(1, 0, 0.5), mean.sa = runif(1, 0.4, 0.6), mean.f = runif(1, 1.3, 2))}

## nimble takes initial values as a list, not a function
## (something we should probably allow)
initsVals <- inits()

# Parameters monitored
parameters <- c("mean.sj", "sj", "sigma.sj", "mean.sa", "sa", "sigma.sa", "mean.p", "mean.f", "f", "sigma.f", "sigma.obs", "N", "Ntot")



library(methods) ## needed only when building documents outside of R
library(nimble)
library(mcmcplots)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')
cur_dir <- getwd()
setwd(file.path(nimble_course_dir,
                 'examples_code',
                 'state_space_house_martins'))
source("state_space_house_martins_model.R")
setwd(cur_dir)

martin_code_alt <- nimbleCode({
# Priors and constraints
logN.est[1] ~ dnorm(5.6, 0.01)       # Prior for initial population size
mean.r ~ dnorm(1, 0.001)             # Prior for mean growth rate
sigma.proc ~ dunif(0, 1)          # Prior for sd of state process
sigma2.proc <- pow(sigma.proc, 2)
tau.proc <- pow(sigma.proc, -2)
sigma.obs ~ dunif(0, 1)           # Prior for sd of observation process
sigma2.obs <- pow(sigma.obs, 2)
tau.obs <- pow(sigma.obs, -2)

# Likelihood
# State process
for (t in 1:(T-1)) {
    logN.est[t+1] ~ dnorm(logN.est[t] + mean.r, tau.proc)
}

# Observation process
for (t in 1:T) {
    y[t] ~ dnorm(logN.est[t], tau.obs)
}

# Population sizes on real scale
for (t in 1:T) {
    N.est[t] <- exp(logN.est[t])
}
})


blockStates <- function(MCMCconf, Rmodel, states, type) {
    stateNodes <- Rmodel$expandNodeNames(states)
    numStates <- length(stateNodes)
    numBlocks <- ceiling(numStates/3)
    for(i in 1:numBlocks) {
        iStart <- (3*(i-1)+1)       ## 1, 4, 7, 10 etc.
        iEnd <- min(3*i, numStates) ## 3, 6, 9, 12 etc. or max
        blockNodes <- stateNodes[iStart:iEnd]
        MCMCconf$removeSamplers(blockNodes)
        ## check if there is a singleton at the end
        if(iEnd > iStart) {
            MCMCconf$addSampler(blockNodes, type = type, silent = TRUE)
        } else {
            MCMCconf$addSampler(blockNodes, type = 'RW') ## in case there is a singleton
        }
    }
    MCMCconf
}

martin_inits2 <- function() {
    list(sigma.proc = runif(1, 0, 1), mean.r = rnorm(1),
         sigma.obs = runif(1, 0, 1), 
         logN.est = c(rnorm(20, bugs.data$y[1:20], 0.1), 
                      rnorm(6, mean(bugs.data$y[1:20]), .1)))
}

set.seed(1)
Rmodel <- nimbleModel(martin_code_alt,
                      constants = bugs.data,
                      inits = martin_inits2())

AFSSblockStates <- blockStates(configureMCMC(Rmodel),
                                   Rmodel,
                                   'logN.est',
                                   'AF_slice')

AFSSblockStates$printSamplers()

AFSSMCMC <- buildMCMC(AFSSblockStates)
AFSSMCMC$samplerFunctions[[10]]
AFSSMCMC$samplerFunctions[[18]]$target
AFSSMCMC$samplerFunctions[[13]]$target
for(i in 14) {
    debug(AFSSMCMC$samplerFunctions[[i]]$run)
}
AFSSMCMC$run(3)

debug(adaptWidths)
debug(adaptFactors)

myans <- numeric(100)
xbv <- seq(from = Lbound, to = Rbound, length = 100)
for(i in 1:100) {
    myx <- x0 + xbv[i] * eigenVec
    myans[i] <- setAndCalculateTarget(myx)
}

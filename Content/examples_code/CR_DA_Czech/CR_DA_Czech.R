## From data of Jiri Reif et al. and model of Kery and Schaub (2012), Chapter 6, Section 6.3

# 6.3. Analysis of a real data set: model Mtbh for species richness estimation
# Read in data and look at them
p610 <- read.table("p610.txt", header = TRUE)
y <- p610[,5:9]                           # Grab counts
y[y > 1] <- 1                             # Counts to det-nondetections
C <- sum(apply(y, 1, max)) ; print(C)     # Number of observed species
table(apply(y, 1, sum))                   # Capture-frequencies

library(nimble)
# Specify model in BUGS language
# File "M_tbh.txt" in book code
p610_code <- nimbleCode({
    ## Priors
    omega ~ dunif(0, 1)
    for  (j in 1:T){
        alpha[j] <- log(mean.p[j] / (1-mean.p[j])) # Define logit 
        mean.p[j] ~ dunif(0, 1) 	# Detection intercepts
    }
    gamma ~ dnorm(0, 0.01)
    tau <- 1 / (sd * sd)
    sd ~ dunif(0, 3)
    
    ## Likelihood
    for (i in 1:M){
        z[i] ~ dbern(omega)
        eps[i] ~ T(dnorm(0, tau), -16, 16) ## originally dnorm(0, tau)I(-16, 16)
        
        ## First occasion: no term for recapture (gamma)
        y[i,1] ~ dbern(p.eff[i,1])
        p.eff[i,1] <- z[i] * p[i,1]
        p[i,1] <- 1 / (1 + exp(-lp[i,1]))
        lp[i,1] <- alpha[1] + eps[i]
        
        ## All subsequent occasions: includes recapture term (gamma)
        for (j in 2:T){
            y[i,j] ~ dbern(p.eff[i,j])
            p.eff[i,j] <- z[i] * p[i,j]
            p[i,j] <- 1 / (1 + exp(-lp[i,j]))   
            lp[i,j] <- alpha[j] + eps[i] + gamma * y[i,(j-1)]
        } #j
    } #i
    
    ## Derived quantities
    N <- sum(z[])
})

isVirtual <- rowSums(y)==0
zData <- as.numeric(!isVirtual)
zData[zData == 0] <- NA
zInits <- zData
zInits[is.na(zInits)] <- rbinom(sum(is.na(zInits)), size = 1, prob = 0.5)
zInits[!is.na(zData)] <- NA
# Bundle data
win.data <- list(y = as.matrix(y), M = nrow(y), T = ncol(y), z = zData)

## Initial values
## (It is wasteful to allow fixed ones not to be counted as data.
##  Also for the RJ DA samplers below, it is necessary to mark them as data.)
inits <- function() list(z = rep(1, nrow(y)),
                         sd = runif(1, 0.1, 0.9),
                         ## Added for nimble
                         eps = runif(nrow(y), -1, 1),
                         tau = 1,
                         z = zInits)

# Parameters monitored
params <- c("N", "mean.p", "gamma", "sd", "omega")

# MCMC settings
ni <- 5000#50000
nt <- 4
nb <- 1000#10000
nc <- 3

## Call nimble
samples <- nimbleMCMC(
    p610_code,
    constants = win.data,
    monitors = params,
    inits = inits)

# Call WinBUGS from R (BRT 24 min)
##out <- bugs(win.data, inits, params, "M_tbh.txt", n.chains = nc, 
##n.thin = nt, n.iter = ni, n.burnin = nb, debug = TRUE, bugs.directory = bugs.dir, working.directory = getwd())

## test RJ sampling:
source("../../general_code/RJsamplers.R")

p610_code_DA <- nimbleCode({
    ## Priors
    omega ~ dunif(0, 1)
    for  (j in 1:T){
        alpha[j] <- log(mean.p[j] / (1-mean.p[j])) # Define logit 
        mean.p[j] ~ dunif(0, 1) 	# Detection intercepts
    }
    gamma ~ dnorm(0, 0.01)
   ## tau <- 1 / (sd * sd)
    sd ~ dunif(0, 3)
    
    ## Likelihood
    for (i in 1:M){
        z[i] ~ dbern(omega)
        eps[i] ~ dnorm_nonzero(0, sd = sd)
        
        ## First occasion: no term for recapture (gamma)
        y[i,1] ~ dbern(p.eff[i,1])
        p.eff[i,1] <- z[i] * p[i,1]
        p[i,1] <- 1 / (1 + exp(-lp[i,1]))
        lp[i,1] <- alpha[1] + eps[i]
        
        ## All subsequent occasions: includes recapture term (gamma)
        for (j in 2:T){
            y[i,j] ~ dbern(p.eff[i,j])
            p.eff[i,j] <- z[i] * p[i,j]
            p[i,j] <- 1 / (1 + exp(-lp[i,j]))   
            lp[i,j] <- alpha[j] + eps[i] + gamma * y[i,(j-1)]
        } #j
    } #i
    
    ## Derived quantities
    N <- sum(z[])
})

dnorm_nonzero <- nimbleFunction(
    run = function(x = double(), mean = double(), sd = double(), log = logical(0, default = 0)) {
        returnType(double())
        if(x == 0) return(0)
        return(dnorm(x, mean, sd, log))
    })

rnorm_nonzero <- nimbleFunction(
    run = function(n = integer(), mean = double(), sd = double()) {
        returnType(double())
        return(rnorm(1, mean, sd))
    })

inits <- function() {
    ans <- list(z = rep(1, nrow(y)),
                sd = runif(1, 0.1, 0.9),
                ## Added for nimble
                eps = runif(nrow(y), -1, 1),
                sd = 1,
                z = zInits)
    ans$eps[ans$z == 0] <- 0
    ans
}

p610_model_DA <- nimbleModel(
    p610_code_DA,
    constants = win.data,
    inits = inits())

MCMCconf <- configureMCMC(p610_model_DA, monitors = params)

p610_configureDA <- function(MCMCconf,
                             moreSigma = FALSE) {
    ##MCMCconf$printSamplers()
    updateConf_indicatorSamplers(MCMCconf,
                                 "z",
                                 "eps",
                                 byRow = NULL)
    ##    MCMCconf$printSamplers("eps")
    
    updateConf_DAsamplers(MCMCconf,
                          "z",
                          list("eps"),
                          control = list(insertProb = 0.2, removeProb = 0.2))
    
    ##MCMCconf$printSamplers("z")
    if(moreSigma) {
        numSamplers <- length(MCMCconf$getSamplers())
        MCMCconf$addSampler(target = "sd", control = list(log = TRUE))
        iHalf <- ceiling(numSamplers/2)
        MCMCconf$setSamplers(c(1:iHalf, numSamplers + 1, (iHalf+1):numSamplers))
    }
    
    MCMCconf
}

p610_configureDA(MCMCconf)

MCMC <- buildMCMC(MCMCconf)
compiled <- compileNimble(p610_model_DA, MCMC)

compiled$MCMC$run(50000)
samples2 <- as.matrix(compiled$MCMC$mvSamples)
effectiveSize(samples2)

MCMCdefs <- list(
    nimbleDA = quote({
        p610_configureDA(configureMCMC(Rmodel))
    }),
    nimbleDAsigma = quote({
        p610_configureDA(configureMCMC(Rmodel), moreSigma = TRUE)
    })
)

## compare:
p610_comparison <- compareMCMCs(
    list(code = p610_code_DA,
         data = win.data,
         inits = inits()),
    MCMCdefs = MCMCdefs,
    MCMCs = c('nimble','nimbleDA','nimbleDAsigma'), ## More work to include JAGS because of T() notation
    monitors = params,
    niter = 50000,
    burnin = 10000,
    thin = 4,
    summary = FALSE
)

make_MCMC_comparison_pages(p610_comparison, dir = "p610_comparison", modelNames = "p610_DA")

browseURL(file.path("p610_comparison", "p610_DA.html"))

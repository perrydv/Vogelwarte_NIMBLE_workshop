## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)

## ----quiet-nimble--------------------------------------------------------
nimbleOptions(verbose = FALSE)

## ----simple-model--------------------------------------------------------
simpleModel <- nimbleModel(
    nimbleCode({silly ~ dnorm(0, sd = 20)})
)

## ----quick-sample--------------------------------------------------------
MCMCconf <- configureMCMC(simpleModel, nodes = NULL)
MCMCconf$addSampler(target = "silly", type = "RW")
## Otherwise it would be sampled by a posterior predictive
## sampler, which would not be interesting!
MCMC <- buildMCMC(MCMCconf)

## ----sample1-------------------------------------------------------------
MCMC$run(1000)
samples <- as.matrix(MCMC$mvSamples)
plot(samples[,"silly"])

## ----write-RW-MH---------------------------------------------------------
our_RWMH <- nimbleFunction(
    contains = sampler_BASE,
    setup = function(model, mvSaved, target, control) {
        scale  <- if(!is.null(control$scale))         control$scale         else 1
        calcNodes <- model$getDependencies(target)
    },
    run = function() {
        currentValue <- model[[target]]
        propValue <- rnorm(1, mean = currentValue,  sd = scale)
        model[[target]] <<- propValue
        logMHR <- calculateDiff(model, calcNodes)
        jump <- decide(logMHR)
        if(jump) nimCopy(from = model, to = mvSaved, row = 1, nodes = calcNodes, logProb = TRUE)
        else     nimCopy(from = mvSaved, to = model, row = 1, nodes = calcNodes, logProb = TRUE)
    },
    methods = list(
        reset = function() {}
    )
)

## ----use-our-sampler-----------------------------------------------------
MCMCconf2 <- configureMCMC(simpleModel, nodes = NULL)
MCMCconf2$addSampler(target = "silly", type = our_RWMH, control = list(scale = 2))
MCMC2 <- buildMCMC(MCMCconf2)

## ----run-our-sampler-----------------------------------------------------
MCMC2$run(1000)
samples2 <- as.matrix(MCMC2$mvSamples)
plot(samples2[,'silly'])

## ----use-our-sampler2----------------------------------------------------
MCMCconf3 <- configureMCMC(simpleModel, nodes = NULL)
MCMCconf3$addSampler(target = "silly", type = our_RWMH, control = list(scale = 100))
MCMC3 <- buildMCMC(MCMCconf3)

## ----run-our-sampler2----------------------------------------------------
MCMC3$run(1000)
samples3 <- as.matrix(MCMC3$mvSamples)
plot(samples3[,'silly'])


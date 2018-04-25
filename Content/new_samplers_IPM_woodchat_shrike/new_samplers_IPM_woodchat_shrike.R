## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')
cur_dir <- getwd()
setwd(file.path(nimble_course_dir,
                 'examples_code',
                 'IPM_woodchat_shrike'))
source("IPM_woodchat_shrike.R")
setwd(cur_dir)

## ----data-look-----------------------------------------------------------
bugs.data$marr.a
bugs.data$marr.j
bugs.data$B
bugs.data$J

## ------------------------------------------------------------------------
nimbleOptions(verbose = FALSE)
## 1. Build model
ipm_model <- nimbleModel(ipm_code,
                         constants = bugs.data,
                         inits = initsVals)
## 2. Build MCMC configuration and samplers:
ipm_mcmc <- buildMCMC(ipm_model)
## 3. Compile model via generated C++.
Cipm_model <- compileNimble(ipm_model)
## 4. Compile MCMC via generated C++
Cipm_mcmc <- compileNimble(ipm_mcmc, project = ipm_model)
## 5. Run MCMC. (nimble does not natively support multiple chains.)
# MCMC settings
ni <- 3000; nt <- 1; nb <- 1000; nc <- 3
samples <- runMCMC(Cipm_mcmc, ni)
colnames(samples)

## ----study-mcmc-results--------------------------------------------------
## Pick a few trace plots
plot(samples[,'N[1, 1]']) ## yuck
plot(samples[,'N[1, 2]']) ## much better
plot(samples[,'mean.p']) ## looks pretty good
## look at some pairs, dropped burnin = 500
pairs(samples[-(1:500), 1:8], pch = '.')
pairs(samples[-(1:500), 9:16], pch = '.')
## skip some
pairs(samples[-(1:500), 21:28], pch = '.') ## some parameters mixing poorly!
## Look at ESS:
library(coda)
effectiveSize(samples)
## We see horrible mixing for mean.sj and mean.f, and bad mixing for sigma.f
## Is mean.sj correlated with anything?
cor(samples)[,'mean.sj']

## ----custom-sampler------------------------------------------------------
sampler_JuvAdult <- nimbleFunction(
    name = 'sampler_JuvAdult',
    contains = sampler_BASE,
    setup = function(model, mvSaved, target, control) {
        adaptive      <- if(!is.null(control$adaptive))      control$adaptive      else TRUE
        adaptInterval <- if(!is.null(control$adaptInterval)) control$adaptInterval else 200
        scale         <- if(!is.null(control$scale))         control$scale         else 1
        constantSum   <- if(!is.null(control$constantSum))   as.integer(control$constantSum)   else 1L        
        calcNodes <- model$getDependencies(target)
        ##
        targetJuv <- target[1]
        targetAdult <- target[2]
        ## numeric value generation
        scaleOriginal <- scale
        timesRan      <- 0
        timesAccepted <- 0
        timesAdapted  <- 0
        optimalAR     <- 0.44
        gamma1        <- 0

    },
    run = function() {
        propLogScale <- 0
        propDiff <- round(rnorm(1, mean = 0, sd = scale))
        model[[targetJuv]] <<- model[[targetJuv]] + propDiff
        model[[targetAdult]] <<- model[[targetAdult]] - constantSum * propDiff
        logMHR <- calculateDiff(model, calcNodes)
        jump <- decide(logMHR)
        if(jump) nimCopy(from = model, to = mvSaved, row = 1, nodes = calcNodes, logProb = TRUE)
        else     nimCopy(from = mvSaved, to = model, row = 1, nodes = calcNodes, logProb = TRUE)
        if(adaptive)     adaptiveProcedure(jump)
    },
    methods = list(
        adaptiveProcedure = function(jump = logical()) {
            timesRan <<- timesRan + 1
            if(jump)     timesAccepted <<- timesAccepted + 1
            if(timesRan %% adaptInterval == 0) {
                acceptanceRate <- timesAccepted / timesRan
                timesAdapted <<- timesAdapted + 1
                gamma1 <<- 1/((timesAdapted + 3)^0.8)
                gamma2 <- 10 * gamma1
                adaptFactor <- exp(gamma2 * (acceptanceRate - optimalAR))
                scale <<- scale * adaptFactor
                timesRan <<- 0
                timesAccepted <<- 0
            }
        },
        reset = function() {
            scale <<- scaleOriginal
            timesRan      <<- 0
            timesAccepted <<- 0
            timesAdapted  <<- 0
            gamma1 <<- 0
        }
    ), where = getLoadingNamespace()
)

configureMCMC_IPM <- function(model) {
    mcmcConf <- configureMCMC(model)
    mcmcConf$removeSamplers('N')
    Nnodes <- model$expandNodeNames('N')
    for(i in seq(1, length(Nnodes), by = 2)) {
        JuvAdultPair <- Nnodes[i:(i+1)]## e.g. c('N[1, 1]', 'N[2, 1]')
        mcmcConf$addSampler(JuvAdultPair,
                            type = sampler_JuvAdult)
        mcmcConf$addSampler(JuvAdultPair,
                            type = sampler_JuvAdult,
                            control = list(constantSum = FALSE))
    }
    mcmcConf
}

## ----compare-performance, eval = FALSE-----------------------------------
## configureMCMC_IPM <- function(model) {
##     mcmcConf <- configureMCMC(model)
##     mcmcConf$removeSamplers('N')
##     Nnodes <- model$expandNodeNames('N')
##     for(i in seq(1, length(Nnodes), by = 2)) {
##         JuvAdultPair <- Nnodes[i:(i+1)]## e.g. c('N[1, 1]', 'N[2, 1]')
##         mcmcConf$addSampler(JuvAdultPair,
##                             type = sampler_JuvAdult)
##         mcmcConf$addSampler(JuvAdultPair,
##                             type = sampler_JuvAdult,
##                             control = list(constantSum = FALSE))
##     }
##     mcmcConf
## }
## 
## ipm_comparison <- compareMCMCs(
##     list(code = ipm_code,
##          inits = initsVals,
##          data = bugs.data),
##     MCMCs = c('nimble','jags','nimbleCustom'),
##     MCMCdefs = list(nimbleCustom = quote({
##         configureMCMC_IPM(Rmodel)
##     })),
##     summary = FALSE,
##     burnin = 5000,
##     niter = 20000,
##     monitors = parameters)
## 
## make_MCMC_comparison_pages(ipm_comparison,
##                            dir = "ipm_comparison",
##                            modelNames = "woodshrike")
## 
## ##browseURL(file.path("ipm_comparison","woodshrike.html"))


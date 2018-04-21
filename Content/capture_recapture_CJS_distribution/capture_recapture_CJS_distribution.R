## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')
cur_dir <- getwd()
setwd(file.path(nimble_course_dir,
                 'examples_code',
                 'CJS_dipper'))
source("dipper_basic.R")
source("dipper_CJS.R")
setwd(cur_dir)


## ----dipper-basic-model--------------------------------------------------
dipper_code

## ----compare-MCMC-basic--------------------------------------------------
dipper_basic_comparison <- compareMCMCs(
    dipper_info,
    MCMCdefs = list(
        nim_slice_p_phi = quote({
            MCMCconf <- configureMCMC(Rmodel)
            MCMCconf$removeSamplers(c("p","phi"))
            MCMCconf$addSampler("p", type = "slice")
            MCMCconf$addSampler("phi", type = "slice")
            MCMCconf
        })),
    MCMCs = c("jags", "nimble", "nim_slice_p_phi"),
    monitors = c("phi", "p"),
    niter = 10000,
    burnin = 1000,
    summary = FALSE)

make_MCMC_comparison_pages(dipper_basic_comparison,
                           dir = "dipper_basic_comparison",
                           modelNames = "dipper_basic")

## Optional way to open browser directly from R
## browseURL(file.path("dipper_basic_comparison", "dipper_basic.html"))

## ----dipper-CJS----------------------------------------------------------
dipper_code_CJS

## ----dCJS----------------------------------------------------------------
dCJS <- nimbleFunction(
    run = function(x = double(1),    ## standard name for the "data"
                   survival = double(),
                   capture = double(),
                   l = double(),
                   log = integer(0, default = 0) ## required log argument
                   ) {
        probAliveGivenHistory <- 1
        ## logProbData will be the final answer
        logProbData <- 0
        if(l == 1) {  ## l==1 should not occur, but be defensive
            return(logProbData) 
        }
        for(t in 2:l) {
            ## probAlive is P(Alive(t) | x(1)...x(t-1))
            ## probAliveGivenHistory is (Alive(t-1) | x(1)...x(t-1))
            probAlive <- probAliveGivenHistory * survival
            if(x[t] == 1) {
                ## ProbThisObs = P(x(t) | x(1)...x(t-1))
                probThisObs <- probAlive * capture
                probAliveGivenHistory <- 1
            } else {
                probAliveNotSeen <- probAlive * (1-capture)
                probThisObs <- probAliveNotSeen + (1-probAlive)
                probAliveGivenHistory <- probAliveNotSeen / probThisObs
            }
            logProbData <- logProbData + log(probThisObs)
        }
        if(log) return(logProbData)
        return(exp(logProbData))
        returnType(double())
    }
)

## ----rCJS----------------------------------------------------------------
rCJS <- nimbleFunction(
    run = function(n = integer(),
                   survival = double(),
                   capture = double(),
                   l = double()) {
        returnType(double(1))
        return(numeric(l)) ## dummy behavior
    }
)

## ----MCMC-CJS------------------------------------------------------------

dipper_CJR_comparison <- compareMCMCs(
    dipper_info_CJS,
    MCMCdefs = list(
        nimCJS_slice_p_phi = quote({
            MCMCconf <- configureMCMC(Rmodel)
            MCMCconf$removeSamplers(c("p","phi"))
            MCMCconf$addSampler("p", type = "slice")
            MCMCconf$addSampler("phi", type = "slice")
            MCMCconf
        })),
    MCMCs = c("nimble", "nimCJS_slice_p_phi"),
    monitors = c("phi", "p"),
    niter = 10000,
    burnin = 1000,
    summary = FALSE)

dipper_CJR_comparison[[1]] <- rename_MCMC_comparison_method("nimble", "nimbleCJS", dipper_CJR_comparison[[1]])

dipper_all_comparison <- combine_MCMC_comparison_results(dipper_basic_comparison[[1]],
                                                         dipper_CJR_comparison[[1]],
                                                         name = "dipper_MCMC_comparison")

make_MCMC_comparison_pages(dipper_all_comparison,
                           dir = "dipper_all_comparison",
                           modelNames = "dipper")

## browseURL(file.path("dipper_all_comparison", "dipper.html"))



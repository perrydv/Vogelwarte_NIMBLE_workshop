## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
library(mcmcplots)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')
cur_dir <- getwd()
setwd(file.path(nimble_course_dir,
                 'examples_code',
                 'CJS_dipper'))
source('dipper_model.R')
setwd(cur_dir)

## ---- comparisons--------------------------------------------------------
dipperInfo <- list(code=dipper_code,
                   constants=constants,
                   data=data, inits=inits)

## A function to replace default samplers with slice
## samplers for requested nodes
configureSlice <- function(Rmodel, nodes) {
    MCMCconf <- configureMCMC(Rmodel) ## get a default configuration
    ## print default samplers for illustration
    MCMCconf$printSamplers(c('p','phi'))
    for(node in nodes) {
        MCMCconf$removeSamplers(node)
        MCMCconf$addSampler(target = node, type = "slice")
    }
    ## print modified samplers for illustration
    MCMCconf$printSamplers(c('p','phi'))
    MCMCconf
}

## This is only needed during Rmarkdown/NIMBLE non-standard evaluation conflicts
.GlobalEnv$configureSlice <- configureSlice

## A configuration list for compareMCMCs
MCMCdefs <- list(
    nimble_custom = quote({
        ## This code will be evaluated in an environment
        ## where 'Rmodel' is the model.
        ## The use of .GlobalEnv is because of strange behavior
        ## during Rmarkdown document generation.
        customConf <- configureSlice(Rmodel, c('p', 'phi'))
        ## We must return a configuration
        customConf
    })
)

dipper_comparisons <- compareMCMCs(
    dipperInfo,
    MCMCs = c("jags", "nimble", "nimble_custom"),
    MCMCdefs = MCMCdefs,
    monitors = c("phi", "p"),
    niter = 10000,
    burnin = 1000,
    summary = FALSE)

## ---- comparison-results-------------------------------------------------
make_MCMC_comparison_pages(dipper_comparisons,
                           dir = "dipper_comparison_results",
                           modelNames = "dipper_comparisons")


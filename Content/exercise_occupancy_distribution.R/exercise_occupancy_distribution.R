## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')

## ----AHM-figures---------------------------------------------------------
cur_dir <- getwd()
setwd(file.path(nimble_course_dir,
                 'examples_code',
                 'occupancy_with_covariates'))
.GlobalEnv$DO_PLOT <- TRUE
source("occupancy_with_covariates.R")
setwd(cur_dir)

## ----AHM-BUGS-code-------------------------------------------------------
Section10p4_code

## ----AHM-BUGS-noDerived-code---------------------------------------------
Section10p4_noDerived_code

## ----basic-MCMC----------------------------------------------------------
params_of_interest <- c("alpha0", "alpha1", "beta0", "beta1")
## N.occ would be of interest, but we'll need to get that after
## MCMC in the next version, so we skip it here too.

ni <- 25000
nb <- 2000

occupancy_basic_comparison <- compareMCMCs(
  modelInfo = list(
    code = Section10p4_noDerived_code,
    data = occupancy_data,
    inits = occupancy_inits()
  ),
  ## making the comparison for all latent states in params
  ## would be cumbersome
  monitors = params_of_interest,
  MCMCs = c('nimble', 'jags'),
  summary = FALSE,
  burnin = nb,
  niter = ni
)

make_MCMC_comparison_pages(occupancy_basic_comparison,
                           modelNames = "Section10p4",
                           dir = "occupancy_basic_comparison")

##browseURL(file.path(occupancy_basic_comparison, "Section10p4.html"))



## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
library(mcmcplots)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')
cur_dir <- getwd()
setwd(file.path(nimble_course_dir,
                 'examples_code',
                 'Nmixture_with_covariates'))
source("Nmixture_with_covariates.R")
setwd(cur_dir)

## ----BUGS-code-----------------------------------------------------------
Section6p4_code

## ---- show-samplers------------------------------------------------------
MCMCconf <- configureMCMC(Nmix_model)
MCMCconf$printSamplers()


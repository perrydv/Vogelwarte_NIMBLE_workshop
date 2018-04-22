## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')

## ----make-figures--------------------------------------------------------
cur_dir <- getwd()
setwd(file.path(nimble_course_dir,
                 'examples_code',
                 'ZIP_Nmixture_SwissGreatTits'))
.GlobalEnv$DO_PLOT <- TRUE
source("ZIP_Nmixture_SwissGreatTits.R")
setwd(cur_dir)

## ----original-code-------------------------------------------------------
Section6p11_code
DO_POSTERIOR_PREDICTION <- FALSE
.GlobalEnv$DO_POSTERIOR_PREDICTION <- FALSE


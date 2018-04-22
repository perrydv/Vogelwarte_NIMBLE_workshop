## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')
cur_dir <- getwd()
setwd(file.path(nimble_course_dir,
                 'examples_code',
                 'multi_state_CR_orchids'))
source("orchids_basic.R")
source("orchids_dDHMM.R")
setwd(cur_dir)


## ----basic-code----------------------------------------------------------
orchids_code


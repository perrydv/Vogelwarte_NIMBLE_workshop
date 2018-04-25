## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
library(mcmcplots)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')
cur_dir <- getwd()
setwd(file.path(nimble_course_dir,
                 'examples_code',
                 'extra'))
source("model1.R")
setwd(cur_dir)

## ----runMCEM-------------------------------------------------------------
MCEM <- buildMCEM(Nmix_model, c('N'), C = 0.02)
MLEs <- MCEM$run(initM = 1000)
MLEs
save(MLEs, file = "Nmix_MLEs.RData")


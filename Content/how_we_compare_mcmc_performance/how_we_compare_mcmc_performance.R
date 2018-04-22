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
source('dipper_basic.R')
setwd(cur_dir)

## ---- default-mcmc, eval = TRUE------------------------------------------
dipper_model <- nimbleModel(dipper_code,
                            constants = dipper_constants,
                            data = dipper_data,
                            inits = dipper_inits)
defaultMCMCconf <- configureMCMC(dipper_model)
defaultMCMC <- buildMCMC(defaultMCMCconf)
## We can compile both in one step
dipper_compiled <- compileNimble(dipper_model, defaultMCMC)
CdefaultMCMC <- dipper_compiled$defaultMCMC
## Illustration of running MCMC "directly"
CdefaultMCMC$run(5000)
defaultSamples <- as.matrix(CdefaultMCMC$mvSamples)
## Do burn-in manually when running in this mode
defaultSamples <- defaultSamples[1001:5000,]
dir.create('default_samples_plots', showWarnings = FALSE)
mcmcplot(defaultSamples, dir = 'default_samples_plots')

## ---- zoomed-trace-plot, eval = TRUE-------------------------------------
plot(defaultSamples[2051:2100, 'p'], type = 'b') 

## ---- ess, eval = TRUE---------------------------------------------------
library(coda)
effectiveSize(defaultSamples)


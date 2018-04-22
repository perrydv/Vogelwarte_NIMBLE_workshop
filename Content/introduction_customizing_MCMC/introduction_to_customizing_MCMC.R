## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
library(igraph)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')
source(file.path(nimble_course_dir,
                 'examples_code',
                 'pump',
                 'pump_model.R'))
source(file.path(nimble_course_dir,
                 'examples_code',
                 'extra',
                 'model1.R'))

## ----pumpMCMCconf--------------------------------------------------------
pumpMCMCconf <- configureMCMC(pump)
pumpMCMCconf$printSamplers()

## ----sampler-assignment-objects------------------------------------------
pump_samplers<- pumpMCMCconf$getSamplers()
pump_samplers
## look at the first one
alpha_sampler <- pump_samplers[[1]]
class(alpha_sampler)
ls(alpha_sampler)
alpha_sampler$target

## ----NmixMCMCconf--------------------------------------------------------
NmixMCMCconf <- configureMCMC(Nmix_model)
NmixMCMCconf$printSamplers()

## ----customize-pump-samplers---------------------------------------------
## First check on samplers for node alpha
pumpMCMCconf$printSamplers("alpha")
## Remove the old sampler
pumpMCMCconf$removeSamplers("alpha")
## Add a new sampler
pumpMCMCconf$addSampler(target = "alpha", type = "slice")
pumpMCMCconf$printSamplers()

## ----customize-pump-samplers-2-------------------------------------------
pumpMCMCconf$addSampler(target = "alpha", type = "slice")
pumpMCMCconf$printSamplers()
pumpMCMCconf$setSamplers(c(1:6, 12, 7:11, 13))
pumpMCMCconf$printSamplers()

## ----replate-theta-samplers----------------------------------------------
## First let's start with a fresh default configuration
pumpMCMCconf <- configureMCMC(pump)
## Next let's make a function that replaces samplers for
## any nodes requested.
assignRW <- function(MCMCconf, model, nodes) {
    nodes <- model$expandNodeNames(nodes)
    for(node in nodes) {
        MCMCconf$removeSamplers(node)
        MCMCconf$addSampler(target = node, type = "RW")
    }
    MCMCconf
}
## Then let's use the function for all theta nodes.
assignRW(pumpMCMCconf, pump, 'theta')
pumpMCMCconf$printSamplers()

## ----empty-config--------------------------------------------------------
## configure sampler only for node alpha
pumpMCMCconf_empty <- configureMCMC(pump, nodes = 'alpha')
pumpMCMCconf_empty$printSamplers()
## We could then use addSampler to populate the rest of what we want.


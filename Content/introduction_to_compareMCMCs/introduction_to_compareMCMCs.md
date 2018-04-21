---
title: "Introduction to compareMCMCs"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
    mathjax: deafult
---



# Automating MCMC comparisons in NIMBLE

- NIMBLE provides tools to automatically compare MCMC efficiency
across methods.
- Methods can include different NIMBLE MCMC configurations as well as
  JAGS, OpenBUGS/WinBUGS (not tested much) and Stan (separate code
  required).
- We will use `compareMCMCs`, which calls `MCMCsuite` internally.
- `MCMCsuite` can be used directy as well.

# Example: Metropolis-Hastings vs slice sampling. NIMBLE vs. JAGS

- `compareMCMCs` and `MCMCsuite` need to build and compile the model themselves.
- (This may become more flexible in the future.)
- These functions provide a variety of pre-defined MCMC configurations and a system
for providing your own.
- I will illustrate using slice samplers instead of the default
Metropolis-Hastings samplers for `p` and `phi`.
- (Assigning *all* samplers to be slice samplers is available as
  pre-defined option "nimble_slice" in the `MCMCs` argument.)


```r
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
```

```
## Working on model1
```

```
## defining model...
```

```
## building model...
```

```
## setting data and initial values...
```

```
## running calculate on model (any error reports that follow may simply reflect missing values in model variables) ... 
## checking model sizes and dimensions... This model is not fully initialized. This is not an error. To see which variables are not initialized, use model$initializeInfo(). For more information on model initialization, see help(modelInitialization).
## model building finished.
```

```
## Compiling model graph
##    Resolving undeclared variables
##    Allocating nodes
## Graph information:
##    Observed stochastic nodes: 848
##    Unobserved stochastic nodes: 850
##    Total graph size: 12463
## 
## Initializing model
## 
## [1] RW sampler: phi
## [2] RW sampler: p
## [849] slice sampler: p
## [850] slice sampler: phi
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
## compilation finished.
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
## compilation finished.
```

```
## |-------------|-------------|-------------|-------------|
## |-------------------------------------------------------|
## |-------------|-------------|-------------|-------------|
## |-------------------------------------------------------|
```


```r
make_MCMC_comparison_pages(dipper_comparisons,
                           dir = "dipper_comparison_results",
                           modelNames = "dipper_comparisons")
```

The results are [here](dipper_comparison_results/dipper_comparisons.html)

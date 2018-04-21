---
title: "Quick introduction to NIMBLE"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



# Introduction to NIMBLE

Numerical Inference for statistical Models using Bayesian and Likelihood Estimation

* Model language + algorithm language
* Model language: A new dialect of BUGS/JAGS
* NIMBLE makes BUGS extensible: New functions and distributions
* A package of algorithms (MCMC, SMC, MCEM)
* Algorithm language: nimbleFunctions, embedded within R
* Compiler: Generates and compiles C++ from models and algorithms

# A basic example: the pump model

We'll use the *pump* model example from the original BUGS software. The data set
  describes the failure rates of some pumps.  

---
#<center><img src="figures/pumpDAG.jpg"></center>
---

### pump model summary

* `N`=10 pumps
* `x[i]` is number of failures for pump `i`, observed for time `t[i]`.
* `x[i] ~ lambda[i] * t[i]`
* `lambda[i]` is a random effect for pump `i`
* `lambda[i] ~ dgamma(alpha, beta)`
* `alpha` and `beta` are hyperparameters with priors.

# Write pump model

### Define the model code in R (or a separate file if you'd like) ###


```r
library(nimble)
pumpCode <- nimbleCode({ 
  for (i in 1:N){

      # likelihood (data model)
      x[i] ~ dpois(lambda[i])

      # latent process (random effects)
      # linear predictor      
      lambda[i] <- theta[i]*t[i]
      # random effects distribution
      theta[i] ~ dgamma(alpha,beta)
  }
  # priors on hyperparameters
  alpha ~ dexp(1.0)
  beta ~ dgamma(0.1,1.0)
})
```

# Build pump model

### Build a model object that can be queried and manipulated in R


```r
N <- 10
t <- c(94.3, 15.7, 62.9, 126, 5.24, 31.4, 1.05, 1.05, 2.1, 10.5)
x <- c(5, 1, 5, 14, 3, 19, 1, 1, 4, 22)
pumpConsts <- list(t = t, N = 10)
pumpData <- list(x = x)
pumpInits <- list(alpha = 1,
                  beta = 1,
                  theta = rep(0.1, pumpConsts$N))
pump <- nimbleModel(pumpCode, 
                    data = pumpData,
                    constants = pumpConsts,
                    inits = pumpInits)
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
## checking model sizes and dimensions...
## model building finished.
```

# Explore pump model

### The model is an object you can use:

```r
pump$getNodeNames()
```

```
##  [1] "alpha"               "beta"                "lifted_d1_over_beta"
##  [4] "theta[1]"            "theta[2]"            "theta[3]"           
##  [7] "theta[4]"            "theta[5]"            "theta[6]"           
## [10] "theta[7]"            "theta[8]"            "theta[9]"           
## [13] "theta[10]"           "lambda[1]"           "lambda[2]"          
## [16] "lambda[3]"           "lambda[4]"           "lambda[5]"          
## [19] "lambda[6]"           "lambda[7]"           "lambda[8]"          
## [22] "lambda[9]"           "lambda[10]"          "x[1]"               
## [25] "x[2]"                "x[3]"                "x[4]"               
## [28] "x[5]"                "x[6]"                "x[7]"               
## [31] "x[8]"                "x[9]"                "x[10]"
```

```r
pump$theta
```

```
##  [1] 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1
```

# Compile pump model

### Build a fast version of the model via C++ code generation and compilation


```r
Cpump <- compileNimble(pump)
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```
## compilation finished.
```

#### You can also use the compiled version directly

```r
Cpump$theta
```

```
##  [1] 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1
```

# Configure and build MCMC #

### Set up the configuration of samplers and build the samplers


```r
pumpConf <- configureMCMC(pump)
pumpMCMC <- buildMCMC(pumpConf)
```

#### You can also do this in one step if no customization will be needed

```r
pumpMCMC <- buildMCMC(pump)
```

# Compile  and run the MCMC


```r
CpumpMCMC <- compileNimble(pumpMCMC, project = pump)
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```
## compilation finished.
```


```r
samples <- runMCMC(CpumpMCMC, niter = 1000)
```

```
## running chain 1...
```

```
## |-------------|-------------|-------------|-------------|
## |-------------------------------------------------------|
```

### Look at the results

```r
dir.create("pump_samples", showWarnings = FALSE)
mcmcplot(samples, dir = "pump_samples")
```

```
##                                                                            Preparing plots for alpha.  50% complete.
```

```
##                                                                            Preparing plots for beta.  100% complete.
```

                                                                           

The plots are [here](pump_samples/MCMCoutput.html).

# Other ways to run MCMC

- To quickly combine all steps, use `nimbleMCMC`.
- To take full control, use `CpumpMCMC$run(niter)`
- To compare multiple MCMC configurations, we'll learn `compareMCMCs`, which uses `MCMCsuite`

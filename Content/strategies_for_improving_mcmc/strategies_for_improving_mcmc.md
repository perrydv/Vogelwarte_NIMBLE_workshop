---
title: "Strategies for improving MCMC in NIMBLE"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



# We will use the house martin state-space model as an example

This model is highly conjugate.  Such rare models are where JAGS is at its best.

This model is easily sampled, so it is not in great need of improvement, but examples with it run quickly.

# Terminology

- "target" node(s) = node(s) to be sampled (or "updated") by a particular MCMC sampler.

# Think like the graph

- The "graph" refers to the model, emphasizing relationships among nodes

    - A node is a model "vertex"
    - A dependency is a model "edge"

- For many MCMC samplers, only the part of the model conditionally
dependent on the target nodes needs to be used in calculations.

    - Example: sampler on `r[25]` the penultimate (2nd from last)  environmental ("process")
      noise value
    - The model's `getDependencies` method shows what part of the
      model will need calculation.


```r
martin_model$getDependencies('r[25]')
```

```
## [1] "r[25]"        "logN.est[26]" "y[26]"        "N.est[26]"
```

We see that `r[25]` is needed to calculate:

- its own log probability
- true log population size at the next time (`logN.est[26]`)
- actual population size at the next time (`N.est[26]`) (which is not
needed for the MCMC).
- log probability of the next observation (`y[26]`).

Thinking about the graph will allow you to save computation by:

- avoiding unnecessary computation (we'll do that now)
- grouping calculations that are always done together (we'll see
examples of this later).

# Re-write the model to avoid unnecessary computation #

Let's look more closely at this model.

* Dependencies of `r[24]`:

```r
martin_model$getDependencies('r[24]')
```

```
## [1] "r[24]"        "logN.est[25]" "logN.est[26]" "y[25]"       
## [5] "N.est[25]"    "y[26]"        "N.est[26]"
```

* Dependencies of `r[20]`:

```r
martin_model$getDependencies('r[20]')
```

```
##  [1] "r[20]"        "logN.est[21]" "logN.est[22]" "y[21]"       
##  [5] "N.est[21]"    "logN.est[23]" "y[22]"        "N.est[22]"   
##  [9] "logN.est[24]" "y[23]"        "N.est[23]"    "logN.est[25]"
## [13] "y[24]"        "N.est[24]"    "logN.est[26]" "y[25]"       
## [17] "N.est[25]"    "y[26]"        "N.est[26]"
```

* Dependencies of `r[1]`:

```r
martin_model$getDependencies('r[1]')
```

```
##  [1] "r[1]"         "logN.est[2]"  "logN.est[3]"  "y[2]"        
##  [5] "N.est[2]"     "logN.est[4]"  "y[3]"         "N.est[3]"    
##  [9] "logN.est[5]"  "y[4]"         "N.est[4]"     "logN.est[6]" 
## [13] "y[5]"         "N.est[5]"     "logN.est[7]"  "y[6]"        
## [17] "N.est[6]"     "logN.est[8]"  "y[7]"         "N.est[7]"    
## [21] "logN.est[9]"  "y[8]"         "N.est[8]"     "logN.est[10]"
## [25] "y[9]"         "N.est[9]"     "logN.est[11]" "y[10]"       
## [29] "N.est[10]"    "logN.est[12]" "y[11]"        "N.est[11]"   
## [33] "logN.est[13]" "y[12]"        "N.est[12]"    "logN.est[14]"
## [37] "y[13]"        "N.est[13]"    "logN.est[15]" "y[14]"       
## [41] "N.est[14]"    "logN.est[16]" "y[15]"        "N.est[15]"   
## [45] "logN.est[17]" "y[16]"        "N.est[16]"    "logN.est[18]"
## [49] "y[17]"        "N.est[17]"    "logN.est[19]" "y[18]"       
## [53] "N.est[18]"    "logN.est[20]" "y[19]"        "N.est[19]"   
## [57] "logN.est[21]" "y[20]"        "N.est[20]"    "logN.est[22]"
## [61] "y[21]"        "N.est[21]"    "logN.est[23]" "y[22]"       
## [65] "N.est[22]"    "logN.est[24]" "y[23]"        "N.est[23]"   
## [69] "logN.est[25]" "y[24]"        "N.est[24]"    "logN.est[26]"
## [73] "y[25]"        "N.est[25]"    "y[26]"        "N.est[26]"
```

We can see that because of the way the model is parameterized, there
are long chains of dependencies.  To sample `r[1]`, the first
environmental noise value, nearly the entire model needs to be
calculated.

Even worse, the computational burden of sampling this state-space model as written increases non-linearly with the length of the model.

#### Another way to write this model

We can re-write the model so that the latent population size at each
is stochastic, rather than the environmental noise at each time.  The
modes are statistically equivalent.


```r
martin_code_alt <- nimbleCode({
# Priors and constraints
logN.est[1] ~ dnorm(5.6, 0.01)       # Prior for initial population size
mean.r ~ dnorm(1, 0.001)             # Prior for mean growth rate
sigma.proc ~ dunif(0, 1)          # Prior for sd of state process
sigma2.proc <- pow(sigma.proc, 2)
tau.proc <- pow(sigma.proc, -2)
sigma.obs ~ dunif(0, 1)           # Prior for sd of observation process
sigma2.obs <- pow(sigma.obs, 2)
tau.obs <- pow(sigma.obs, -2)

# Likelihood
# State process
for (t in 1:(T-1)) {
    logN.est[t+1] ~ dnorm(logN.est[t] + mean.r, tau.proc)
}

# Observation process
for (t in 1:T) {
    y[t] ~ dnorm(logN.est[t], tau.obs)
}

# Population sizes on real scale
for (t in 1:T) {
    N.est[t] <- exp(logN.est[t])
}
})
```

Now we can see how this makes a lighter dependency structure:


```r
martin_model_alt <- nimbleModel(martin_code_alt,
                                constants = bugs.data,
                                inits = martin_inits())
```

```
## defining model...
```

```
## Detected y as data within 'constants'.
```

```
## Adding y as data for building model.
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

```r
martin_model_alt$getDependencies('logN.est[20]')
```

```
## [1] "logN.est[20]"                                      
## [2] "lifted_logN_dot_est_oBt_cB_plus_mean_dot_r_L10[20]"
## [3] "y[20]"                                             
## [4] "N.est[20]"                                         
## [5] "logN.est[21]"
```

#### Compare MCMCs

We'll use `compareMCMCs` and related functions to compare MCMC
efficiency for the original and alternate way to write the model.  We
can run each of them in JAGS and NIMBLE.


```r
set.seed(1)
ourInits <- martin_inits()
mcmcResult <- compareMCMCs(
     list(original = list(code = martin_code, inits = ourInits, data = bugs.data)),
     niter = 50000, burnin = 5000, MCMCs = c('nimble','jags'), summary = TRUE)
```

```
## Working on original
```

```
## defining model...
```

```
## Detected y as data within 'constants'.
```

```
## Adding y as data for building model.
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
##    Observed stochastic nodes: 20
##    Unobserved stochastic nodes: 35
##    Total graph size: 128
## 
## Initializing model
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
```

```r
mcmcResultAlt <- compareMCMCs(
     list(rewritten = list(code = martin_code_alt, inits = ourInits, data = bugs.data)),
     niter = 50000, burnin = 5000, MCMCs = c('nimble', 'jags'), summary = TRUE)
```

```
## Working on rewritten
```

```
## defining model...
```

```
## Detected y as data within 'constants'.
```

```
## Adding y as data for building model.
## building model...
## setting data and initial values...
## running calculate on model (any error reports that follow may simply reflect missing values in model variables) ... 
## checking model sizes and dimensions... This model is not fully initialized. This is not an error. To see which variables are not initialized, use model$initializeInfo(). For more information on model initialization, see help(modelInitialization).
## model building finished.
```

```
## Compiling model graph
##    Resolving undeclared variables
##    Allocating nodes
## Graph information:
##    Observed stochastic nodes: 20
##    Unobserved stochastic nodes: 35
##    Total graph size: 128
## 
## Initializing model
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
```

```r
## Do some relabeling before combining results into one figure
mcmcResultAlt[[1]] <- rename_MCMC_comparison_method('nimble', 'nimble(alt)',
                                                    mcmcResultAlt[[1]])
mcmcResultAlt[[1]] <- rename_MCMC_comparison_method('jags', 'jags(alt)',
                                                    mcmcResultAlt[[1]])

mcmcBoth <- combine_MCMC_comparison_results(mcmcResult[[1]], mcmcResultAlt[[1]])

make_MCMC_comparison_pages(mcmcBoth, dir = 'martin_MCMC_comparison')
```

The results are [here](martin_MCMC_comparison/MCMCresults.html)

It does look like the alternative version yields faster MCMC for both
NIMBLE and JAGS.

# Manual blocking

NIMBLE comes with two kinds of block samplers:

- Adaptive multivariate normal random-walk block sampler: This makes
  multivariate normal proposals using a covariance matrix that adapts
  to the shape of the posterior.
- Automated factor slice sampler: This uses slice samplers in rotated
corrdinates.  This is more computationally intense but will ensure
that moves are made.

Let's try sampling `sigma.obs` and `sigma.proc` using AFSS:


```r
configureAFSSsigmas <- function(Rmodel) {
    MCMCconf <- configureMCMC(Rmodel)
    MCMCconf$removeSamplers('sigma.proc')
    MCMCconf$removeSamplers('sigma.obs')
    MCMCconf$addSampler(target = c('sigma.proc','sigma.obs'),
                        type = 'AF_slice')
    MCMCconf
}

configureRWBsigmas <- function(Rmodel) {
    MCMCconf <- configureMCMC(Rmodel)
    MCMCconf$removeSamplers('sigma.proc')
    MCMCconf$removeSamplers('sigma.obs')
    MCMCconf$addSampler(target = c('sigma.proc','sigma.obs'),
                        type = 'RW_block')
    MCMCconf
}

## Next two lines are needed only when generating html
.GlobalEnv$configureAFSSsigmas <- configureAFSSsigmas
.GlobalEnv$configureRWBsigmas <- configureRWBsigmas

mcmcResultBlockSigmas <- compareMCMCs(
    list(original = list(code = martin_code_alt, inits = ourInits, data = bugs.data)),
    niter = 50000,
    burnin = 5000,
    MCMCdefs = list(
        AFSSsigmas = quote({configureAFSSsigmas(Rmodel)}),
        RWBsigmas = quote({configureRWBsigmas(Rmodel)})
    ),
    MCMCs = c('AFSSsigmas', 'RWBsigmas'),
    summary = TRUE)
```

```
## Working on original
```

```
## defining model...
```

```
## Detected y as data within 'constants'.
```

```
## Adding y as data for building model.
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
## Note: Assigning an RW_block sampler to nodes with very different scales can result in low MCMC efficiency.  If all nodes assigned to RW_block are not on a similar scale, we recommend providing an informed value for the "propCov" control list argument, or using the AFSS sampler instead.
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

# Automatic blocking

* NIMBLE includes an algorithm (Turek et al. 2016) that automatically
searches for good blocking combinations.

* This takes additional time, but it is worth it if you can re-use
what you learn.

* It is available as an option to `configureMCMC` or `compareMCMCs`.

For this model, autoBlock did not help, so we'll illustrate it later.

# Sample some nodes on a log scale (especially sigmas)

# Sample some nodes more often

# Try different kinds of samplers

In this model, it may be worth trying RW samplers instead of conjugate
(Gibbs) samplers.

# Write new samplers

# Defer posterior predictive computations until after MCMC

In this model, years 2010-2015 (`y[21]` - `y[26]`) are posterior-predictive.


---
title: "Writing new distributions: Cormack-Jolly-Seber capture-recapture"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



#  Basic capture-recapture model: CJS

Capture history: [1 0 0 1 0 0 0]

1 = captured (alive)
0 = not seen

### One way to look at the probabilities

P([1 0 0 1 0 0 0]) = P(seen) P(survives + not seen) P(survives + not seen) P(survives + seen) P(never seen again for 3 years)

P(never seen again for 3 years) = P(dead) + P(survives + not seen) * P(never seen again for 2 years)

P(never seen again for 2 years) = .... recursive reasoning.

### Another way to look at the probabilities (Hidden Markov Model)

P([1 0 0 1 0 0 0]) = P(1) P(0 | 1) P(0 | [1 0]) P(1 | [1 0 0]) * ...

The important part of us is the software flexibility, not the math.

# Example: Dipper data

- Very common example
- Used for NIMBLE in Turek et al. (2016), Bayesian Analysis.
- We ignore covariates for sex and flood years or order to create the simplest possible model for software illustration.  (We don't recommend skipping important variables in real analyses!)
- 294 birds
- 7 years

# Standard BUGS code

Typical BUGS code for this model would be something like this:


```r
dipper_code
```

```
## {
##     phi ~ dunif(0, 1)
##     p ~ dunif(0, 1)
##     for (i in 1:nind) {
##         for (t in (first[i] + 1):k) {
##             mu_x[i, t] <- phi * x[i, t - 1]
##             mu_y[i, t] <- p * x[i, t]
##             x[i, t] ~ dbin(mu_x[i, t], 1)
##             y[i, t] ~ dbin(mu_y[i, t], 1)
##         }
##     }
## }
```

### Node definitions

- `phi` = survival probability
- `p` = detection (capture) probability
- `x[i, t]` = alive (1) or dead (0) for individual `i` at time `t`
- `y[i, t]` = captured (1) or not captured (0) for individual `i` at time `t`.
- `first[i]` = year of first capture for individual `i`

### Additional setup
- `x[i, t]` is data from first to last capture for individual `i`, and latent state thereafter.
- `y[i, t]` is not defined before first capture for individual `i`.

### Think about the graph and the sampling
- Every time `phi` or `p` is sampled, the entire model needs recalculation, so those are costly.
- Every `x[i, t]` that is a latent state (after last capture) needs to be sampled.
- The conditional distribution of `phi` and `p` changes with the states of `x[i, t]`.

# Run MCMCs on basic model

We will compare JAGS, NIMBLE with default samplers, and NIMBLE with slice samplers on `phi` and `p`.


```r
dipper_basic_comparison <- compareMCMCs(
    dipper_info,
    MCMCdefs = list(
        nim_slice_p_phi = quote({
            MCMCconf <- configureMCMC(Rmodel)
            MCMCconf$removeSamplers(c("p","phi"))
            MCMCconf$addSampler("p", type = "slice")
            MCMCconf$addSampler("phi", type = "slice")
            MCMCconf
        })),
    MCMCs = c("jags", "nimble", "nim_slice_p_phi"),
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
##    Observed stochastic nodes: 1083
##    Unobserved stochastic nodes: 615
##    Total graph size: 12048
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
## |-------------|-------------|-------------|-------------|
## |-------------------------------------------------------|
```

```r
make_MCMC_comparison_pages(dipper_basic_comparison,
                           dir = "dipper_basic_comparison",
                           modelNames = "dipper_basic")

## Optional way to open browser directly from R
## browseURL(file.path("dipper_basic_comparison", "dipper_basic.html"))
```

Results are [here](dipper_basic_comparison/dipper_basic.html)

# Rewrite the model with a distribution for capture histories

We know how to calculate the probability of a capture history, so we'd
like to use that as a distribution.  We want this code to work:
 

```r
dipper_code_CJS
```

```
## {
##     phi ~ dunif(0, 1)
##     p ~ dunif(0, 1)
##     for (i in 1:nind) {
##         y[i, first[i]:k] ~ dCJS(survival = phi, capture = p, 
##             l = k - first[i] + 1)
##     }
## }
```

# Write the distribution for capture histories

We write the `dCJS` as a nimbleFunction.  I will write it in the
state-space model format because this is more generalizable.


```r
dCJS <- nimbleFunction(
    run = function(x = double(1),    ## standard name for the "data"
                   survival = double(),
                   capture = double(),
                   l = double(),
                   log = integer(0, default = 0) ## required log argument
                   ) {
        probAliveGivenHistory <- 1
        ## logProbData will be the final answer
        logProbData <- 0
        if(l == 1) {  ## l==1 should not occur, but be defensive
            return(logProbData) 
        }
        for(t in 2:l) {
            ## probAlive is P(Alive(t) | x(1)...x(t-1))
            ## probAliveGivenHistory is (Alive(t-1) | x(1)...x(t-1))
            probAlive <- probAliveGivenHistory * survival
            if(x[t] == 1) {
                ## ProbThisObs = P(x(t) | x(1)...x(t-1))
                probThisObs <- probAlive * capture
                probAliveGivenHistory <- 1
            } else {
                probAliveNotSeen <- probAlive * (1-capture)
                probThisObs <- probAliveNotSeen + (1-probAlive)
                probAliveGivenHistory <- probAliveNotSeen / probThisObs
            }
            logProbData <- logProbData + log(probThisObs)
        }
        if(log) return(logProbData)
        return(exp(logProbData))
        returnType(double())
    }
)
```

We also need to write an "r" function, but if it will not be used, it
can be a dummy placeholder (even this may not always be needed).


```r
rCJS <- nimbleFunction(
    run = function(n = integer(),
                   survival = double(),
                   capture = double(),
                   l = double()) {
        returnType(double(1))
        return(numeric(l)) ## dummy behavior
    }
)
```

# Run MCMCs on the new model


```r
dipper_CJR_comparison <- compareMCMCs(
    dipper_info_CJS,
    MCMCdefs = list(
        nimCJS_slice_p_phi = quote({
            MCMCconf <- configureMCMC(Rmodel)
            MCMCconf$removeSamplers(c("p","phi"))
            MCMCconf$addSampler("p", type = "slice")
            MCMCconf$addSampler("phi", type = "slice")
            MCMCconf
        })),
    MCMCs = c("nimble", "nimCJS_slice_p_phi"),
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
## Registering the following user-provided distributions: dCJS .
## NIMBLE has registered dCJS as a distribution based on its use in BUGS code. Note that if you make changes to the nimbleFunctions for the distribution, you must call 'deregisterDistributions' before using the distribution in BUGS code for those changes to take effect.
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
dipper_CJR_comparison[[1]] <- rename_MCMC_comparison_method("nimble", "nimbleCJS", dipper_CJR_comparison[[1]])

dipper_all_comparison <- combine_MCMC_comparison_results(dipper_basic_comparison[[1]],
                                                         dipper_CJR_comparison[[1]],
                                                         name = "dipper_MCMC_comparison")

make_MCMC_comparison_pages(dipper_all_comparison,
                           dir = "dipper_all_comparison",
                           modelNames = "dipper")

## browseURL(file.path("dipper_all_comparison", "dipper.html"))
```

Results are [here](dipper_all_comparison/dipper.html)

# Conclusions

- Removing latent states by numerically integrating (summing) over
them can be beneficial, sometimes enormously so.

- One might argue the `dCJS` requires technical understanding but then
the final BUGS code is easier to write and understand.


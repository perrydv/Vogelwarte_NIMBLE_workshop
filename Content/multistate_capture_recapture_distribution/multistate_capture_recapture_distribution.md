---
title: "Writing new distributions: multi-state capture-recapture"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



# Multi-state capture-recapture

- State/Capture history = [0 A 0 C B 0...] where "0" is not seen and A, B, C are observed states.

- When observed, states may be accurate or noisy.

- States may be individual condition (breeding/non-breeding), locations, or other.

- Model is defined by state transition and observation probabilities

# Orchids (ladyslipper) example

- From Bayesian Population Analysis Using WinBUGS (K&#233;ry and Schaub)
- Orchids modeled in states "vegetative", "flowering", "dormant", "dead"
- Observations: "seen vegetative", "seen flowering", "not seen".
- k = 11 annual observation periods 
- n = 250 unique plants
- n = 236 plants seen before the last observation time

This is a simple multi-state model because the state when not seen is unknown.

Obviously multi-state models can be more complicated than this.

# BUGS code 

This code is from BPA:


```r
orchids_code
```

```
## {
##     for (t in 1:(n_occasions - 1)) {
##         s[t] ~ dunif(0, 1)
##     }
##     for (i in 1:3) {
##         a[i] ~ dgamma(1, 1)
##         psiD[i] <- a[i]/sum(a[1:3])
##         b[i] ~ dgamma(1, 1)
##         psiV[i] <- b[i]/sum(b[1:3])
##         c[i] ~ dgamma(1, 1)
##         psiF[i] <- c[i]/sum(c[1:3])
##     }
##     for (i in 1:nind) {
##         for (t in 1:(n_occasions - 1)) {
##             ps[1, i, t, 1] <- s[t] * psiV[1]
##             ps[1, i, t, 2] <- s[t] * psiV[2]
##             ps[1, i, t, 3] <- s[t] * psiV[3]
##             ps[1, i, t, 4] <- 1 - s[t]
##             ps[2, i, t, 1] <- s[t] * psiF[1]
##             ps[2, i, t, 2] <- s[t] * psiF[2]
##             ps[2, i, t, 3] <- s[t] * psiF[3]
##             ps[2, i, t, 4] <- 1 - s[t]
##             ps[3, i, t, 1] <- s[t] * psiD[1]
##             ps[3, i, t, 2] <- s[t] * psiD[2]
##             ps[3, i, t, 3] <- s[t] * psiD[3]
##             ps[3, i, t, 4] <- 1 - s[t]
##             ps[4, i, t, 1] <- 0
##             ps[4, i, t, 2] <- 0
##             ps[4, i, t, 3] <- 0
##             ps[4, i, t, 4] <- 1
##             po[1, i, t, 1] <- 1
##             po[1, i, t, 2] <- 0
##             po[1, i, t, 3] <- 0
##             po[2, i, t, 1] <- 0
##             po[2, i, t, 2] <- 1
##             po[2, i, t, 3] <- 0
##             po[3, i, t, 1] <- 0
##             po[3, i, t, 2] <- 0
##             po[3, i, t, 3] <- 1
##             po[4, i, t, 1] <- 0
##             po[4, i, t, 2] <- 0
##             po[4, i, t, 3] <- 1
##         }
##     }
##     for (i in 1:nind) {
##         z[i, f[i]] <- y[i, f[i]]
##         for (t in (f[i] + 1):n_occasions) {
##             z[i, t] ~ dcat(ps[z[i, t - 1], i, t - 1, 1:4])
##             y[i, t] ~ dcat(po[z[i, t], i, t - 1, 1:3])
##         }
##     }
## }
```

- `ps[1, i, t, 2]` = probability of transition from state 1 to 2 for individual `i` at time `t`.
- `po[1, i, t, 2]` = probability of being observed in state 2 when in state 1 for individual `i` at time `t`.
- `s[t]` = survival probability at time `t`.
- `psiV[j]` = probability of transition from state 1 (Vegetative) to state j.
- `psiF[j]` = probability of transition from state 2 (Flowering) to state j.
- `psiD[j]` = probability of transition from state 3 (Dormant) to state j.

## Thinking about the code and the model's graph:

- Index `i` in `ps` and `po` is unnecessary in this model.   It creates thousands more edges (dependencies).
- Keeping indx `i` is ok for pretending we have a model with individual effects.
- According to Turek et al. 2016, this model has 2.157 latent variables.
- categorical distributions (`dcat`) are costly to sample with default methods: Samplers will try every possible value on every update, even when impossible or unlikely.

    - We could write a possibly more efficiency sampler in NIMBLE, but that's not our goal right now.

# Compare NIMBLE and JAGS on basic model

Let's run MCMC on the basic model.


```r
parameters <- c("s", "psiV", "psiF", "psiD")
## One could argue to monitor the underlying random variables instead:
## parameters <- c('a', 'b', 'c', 's')


orchids_basic_comparison <- compareMCMCs(
    orchids_info,
    MCMCs = c("jags", "nimble"),
    monitors = parameters,
    niter = 20000,
    burnin = 2000,
    summary = FALSE
)
```

```
## Working on model1
```

```
## defining model...
```

```
## Detected y,z as data within 'constants'.
```

```
## Adding y,z as data for building model.
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
##    Observed stochastic nodes: 3384
##    Unobserved stochastic nodes: 477
##    Total graph size: 64041
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
make_MCMC_comparison_pages(orchids_basic_comparison,
                           dir = "orchids_basic_comparison",
                           modelNames = "orchids_basic")

browseURL(file.path("orchids_basic_comparison", "orchids_basic.html"))
```

Results are [here](orchids_basic_comparison/orchid_basic.html).

We could start working on customized sampler choices.

We can look more closely at the numbers like this:

```r
orchids_basic_comparison[[1]]$summary
```

```
## , , s[1]
## 
##             mean    median         sd  CI95_low  CI95_upp     n      ess
## jags   0.9837236 0.9866809 0.01271141 0.9516180 0.9990969 18000 4344.256
## nimble 0.9839808 0.9867624 0.01220086 0.9535886 0.9990047 18000 2192.617
##        efficiency
## jags     20.67433
## nimble   17.46855
## 
## , , s[2]
## 
##             mean    median         sd  CI95_low  CI95_upp     n      ess
## jags   0.8897721 0.8912402 0.02410811 0.8390733 0.9320987 18000 9067.594
## nimble 0.8899542 0.8916331 0.02394541 0.8390888 0.9322308 18000 3869.220
##        efficiency
## jags     43.15272
## nimble   30.82602
## 
## , , s[3]
## 
##             mean    median         sd  CI95_low  CI95_upp     n      ess
## jags   0.9495746 0.9518048 0.01776631 0.9091439 0.9785958 18000 7061.383
## nimble 0.9498536 0.9518419 0.01767800 0.9099494 0.9787589 18000 3687.570
##        efficiency
## jags     33.60515
## nimble   29.37881
## 
## , , s[4]
## 
##             mean    median         sd  CI95_low  CI95_upp     n      ess
## jags   0.9575245 0.9595642 0.01637055 0.9195078 0.9835923 18000 5903.204
## nimble 0.9574591 0.9591250 0.01603298 0.9220988 0.9836758 18000 3529.456
##        efficiency
## jags     28.09337
## nimble   28.11913
## 
## , , s[5]
## 
##             mean    median         sd  CI95_low  CI95_upp     n      ess
## jags   0.9500181 0.9519735 0.01767490 0.9101407 0.9788438 18000 5542.771
## nimble 0.9503887 0.9521965 0.01768178 0.9104144 0.9785981 18000 3450.324
##        efficiency
## jags     26.37807
## nimble   27.48868
## 
## , , s[6]
## 
##             mean    median         sd  CI95_low  CI95_upp     n      ess
## jags   0.9506290 0.9525461 0.01767592 0.9110396 0.9793656 18000 4539.726
## nimble 0.9508679 0.9528467 0.01760518 0.9118887 0.9796837 18000 3554.722
##        efficiency
## jags     21.60457
## nimble   28.32041
## 
## , , s[7]
## 
##             mean    median         sd  CI95_low  CI95_upp     n      ess
## jags   0.9282642 0.9299866 0.02000369 0.8843523 0.9629243 18000 6886.720
## nimble 0.9282206 0.9299986 0.02012334 0.8844872 0.9621429 18000 3442.712
##        efficiency
## jags     32.77393
## nimble   27.42804
## 
## , , s[8]
## 
##             mean    median         sd  CI95_low  CI95_upp     n      ess
## jags   0.9650269 0.9669883 0.01507681 0.9305729 0.9886506 18000 3298.069
## nimble 0.9650559 0.9668700 0.01504830 0.9316360 0.9888217 18000 3010.335
##        efficiency
## jags     15.69552
## nimble   23.98330
## 
## , , s[9]
## 
##             mean    median         sd  CI95_low  CI95_upp     n      ess
## jags   0.9236523 0.9250985 0.02139987 0.8775584 0.9606039 18000 5934.959
## nimble 0.9247758 0.9263652 0.02144618 0.8792118 0.9616475 18000 2621.113
##        efficiency
## jags     28.24449
## nimble   20.88237
## 
## , , s[10]
## 
##             mean    median         sd  CI95_low  CI95_upp     n      ess
## jags   0.9822067 0.9844994 0.01265530 0.9517764 0.9990345 18000 3524.665
## nimble 0.9819405 0.9843932 0.01299154 0.9507395 0.9988598 18000 1811.387
##        efficiency
## jags     16.77389
## nimble   14.43129
## 
## , , psiV[1]
## 
##             mean    median         sd  CI95_low  CI95_upp     n       ess
## jags   0.8285327 0.8286360 0.01183343 0.8048119 0.8511836 18000 11589.018
## nimble 0.8279749 0.8283356 0.01201933 0.8033485 0.8504543 18000  5496.997
##        efficiency
## jags     55.15218
## nimble   43.79449
## 
## , , psiV[2]
## 
##             mean    median         sd  CI95_low  CI95_upp     n       ess
## jags   0.1525759 0.1523324 0.01119527 0.1313096 0.1751397 18000 13051.674
## nimble 0.1528676 0.1526724 0.01130440 0.1315696 0.1758921 18000  5464.889
##        efficiency
## jags     62.11297
## nimble   43.53869
## 
## , , psiV[3]
## 
##              mean     median          sd   CI95_low   CI95_upp     n
## jags   0.01889140 0.01857529 0.004619999 0.01095606 0.02889942 18000
## nimble 0.01915748 0.01869286 0.004703266 0.01114524 0.02948329 18000
##             ess efficiency
## jags   4316.759   20.54347
## nimble 1801.140   14.34966
## 
## , , psiF[1]
## 
##             mean    median         sd  CI95_low  CI95_upp     n       ess
## jags   0.1823041 0.1819261 0.01835404 0.1475463 0.2192639 18000 15266.268
## nimble 0.1824874 0.1818777 0.01835831 0.1485133 0.2196908 18000  5224.318
##        efficiency
## jags     72.65223
## nimble   41.62206
## 
## , , psiF[2]
## 
##             mean    median         sd  CI95_low  CI95_upp     n      ess
## jags   0.8039664 0.8041921 0.01892873 0.7660750 0.8399327 18000 16286.93
## nimble 0.8036284 0.8042158 0.01888717 0.7654988 0.8391435 18000  5498.49
##        efficiency
## jags     77.50956
## nimble   43.80639
## 
## , , psiF[3]
## 
##              mean     median          sd    CI95_low   CI95_upp     n
## jags   0.01372953 0.01289526 0.005929651 0.004607143 0.02757258 18000
## nimble 0.01388413 0.01303390 0.005830446 0.004637606 0.02740478 18000
##             ess efficiency
## jags   5623.619   26.76282
## nimble 2577.917   20.53823
## 
## , , psiD[1]
## 
##             mean    median         sd  CI95_low  CI95_upp     n       ess
## jags   0.5603799 0.5616580 0.09950074 0.3644090 0.7482471 18000  774.8815
## nimble 0.5519759 0.5551881 0.10059750 0.3500499 0.7402507 18000 1466.3590
##        efficiency
## jags     3.687664
## nimble  11.682460
## 
## , , psiD[2]
## 
##             mean    median         sd   CI95_low  CI95_upp     n       ess
## jags   0.1731301 0.1660330 0.06998650 0.06046978 0.3261058 18000  928.2599
## nimble 0.1718414 0.1635985 0.07052332 0.05841168 0.3287193 18000 2709.2343
##        efficiency
## jags     4.417592
## nimble  21.584429
## 
## , , psiD[3]
## 
##             mean    median         sd  CI95_low  CI95_upp     n      ess
## jags   0.2664900 0.2576622 0.09639062 0.1069210 0.4798065 18000 848.6381
## nimble 0.2761827 0.2671115 0.09950024 0.1100275 0.4981654 18000 629.7323
##        efficiency
## jags     4.038672
## nimble   5.017067
```

We see that `psiD`, especially `psiD[3]`, are the worst-mixing
parameters, so we could focus customization effort there.

But our goal here is to rewrite the model using multistate CR.

# Rewriting the model with a dynamic hidden Markov model distribution (dDHMM) #

We want the model to work like this


```r
orchids_DHMM_code
```

```
## {
##     for (t in 1:(k - 1)) {
##         s[t] ~ dunif(0, 1)
##     }
##     for (i in 1:3) {
##         a[i] ~ dgamma(1, 1)
##         psiD[i] <- a[i]/sum(a[1:3])
##         b[i] ~ dgamma(1, 1)
##         psiV[i] <- b[i]/sum(b[1:3])
##         c[i] ~ dgamma(1, 1)
##         psiF[i] <- c[i]/sum(c[1:3])
##     }
##     for (t in 1:(k - 1)) {
##         T[1, 1, t] <- s[t] * psiV[1]
##         T[2, 1, t] <- s[t] * psiV[2]
##         T[3, 1, t] <- s[t] * psiV[3]
##         T[4, 1, t] <- 1 - s[t]
##         T[1, 2, t] <- s[t] * psiF[1]
##         T[2, 2, t] <- s[t] * psiF[2]
##         T[3, 2, t] <- s[t] * psiF[3]
##         T[4, 2, t] <- 1 - s[t]
##         T[1, 3, t] <- s[t] * psiD[1]
##         T[2, 3, t] <- s[t] * psiD[2]
##         T[3, 3, t] <- s[t] * psiD[3]
##         T[4, 3, t] <- 1 - s[t]
##         T[1, 4, t] <- 0
##         T[2, 4, t] <- 0
##         T[3, 4, t] <- 0
##         T[4, 4, t] <- 1
##     }
##     T[1, 1, k] <- 1
##     T[2, 1, k] <- 0
##     T[3, 1, k] <- 0
##     T[4, 1, k] <- 0
##     T[1, 2, k] <- 0
##     T[2, 2, k] <- 1
##     T[3, 2, k] <- 0
##     T[4, 2, k] <- 0
##     T[1, 3, k] <- 0
##     T[2, 3, k] <- 0
##     T[3, 3, k] <- 1
##     T[4, 3, k] <- 0
##     T[1, 4, k] <- 0
##     T[2, 4, k] <- 0
##     T[3, 4, k] <- 0
##     T[4, 4, k] <- 1
##     for (i in 1:nind) {
##         y[i, f[i]:k] ~ dDHMMorchid(length = k - f[i] + 1, prior = prior[1:4], 
##             Z = Z[1:3, 1:4], T = T[1:4, 1:4, f[i]:k])
##     }
## }
```

# Writing dDHMM

Here is a somewhat general version of a dynamic HMM distribution, from Turek et al. (2016).


```r
dDHMMorchid <- nimbleFunction(
    run = function(x = double(1),    ## Observed capture (state) history
                   length = double(),## length of x (needed as a separate param for rDHMM)
                   prior = double(1),## 
                   Z = double(2),
                   T = double(3),
                   log = integer(0, default = 0)) {
        pi <- prior
        logL <- 0
        for(t in 1:length) {
            Zpi <- Z[x[t], ] * pi
            sumZpi <- sum(Zpi)
            logL <- logL + log(sumZpi)
            if(t != length)   pi <- (T[,,t] %*% asCol(Zpi) / sumZpi)[ ,1]
        }
        returnType(double())
        if(log) return(logL)
        return(exp(logL))
    }
)

rDHMMorchid <- nimbleFunction(
    run = function(n = integer(),
        length = double(), prior = double(1),
        Z = double(2),
        T = double(3)) {
        if(n != 1) print('should only specify n=1 in rDHMM() distribution')
        print('STILL NEED TO WRITE THE rDHMM() METHOD!')
        returnType(double(1))
        return(numeric(length, value = 1))
    }
)
```

### Some notes:

- The `prior` could be exchanged for a known initial state.
- Turek et al. set a 50/50 prior in Vegetative/Flowering, which I think ends up not mattering in this case.
- We call it "dynamic" because the transition matrix `T` can vary through time.
- One could make a narrower version that takes survival and transition vectors as inputs, rather than computing the `T` matrix in the model first.

# Run MCMC with the dDHMM version

- Slightly different inputs are needed.


```r
orchids_DHMM_comparison <- compareMCMCs(
    list(code = orchids_DHMM_code,
         data = orchids_DHMM_data,
         constants = orchids_DHMM_constants,
         inits = orchids_DHMM_inits()), 
    MCMCs = c("nimble"),
    monitors = parameters,
    niter = 20000,
    burnin = 2000,
    summary = FALSE
)
```

```
## Working on model1
```

```
## defining model...
```

```
## Registering the following user-provided distributions: dDHMMorchid .
## NIMBLE has registered dDHMMorchid as a distribution based on its use in BUGS code. Note that if you make changes to the nimbleFunctions for the distribution, you must call 'deregisterDistributions' before using the distribution in BUGS code for those changes to take effect.
```

```
## Adding prior,Z as data for building model.
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
```

```
## Warning in nimble::getParam(.self, node, param): Note that getParam is
## not available for parameters of dimension greater than two, but other
## calculations with models are unaffected
```

```
## Warning in model$checkBasics(): Possible size/dimension mismatch amongst
## vectors and matrices in BUGS expression: y[i, f[i]:11] ~ dDHMMorchid(length
## = lifted_d11_minus_f_oBi_cB_plus_1_L44[i], prior = prior[1:4], Z = Z[1:3,
## 1:4], T = T[1:4, 1:4, f[i]:11], lower_ = -Inf, upper_ = Inf). Ignore this
## warning if the user-provided distribution has multivariate parameters with
## distinct sizes or if size of variable differs from sizes of parameters.
```

```
## 
## model building finished.
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
orchids_DHMM_comparison[[1]] <- rename_MCMC_comparison_method("nimble", "nimbleDHMM", orchids_DHMM_comparison[[1]])


orchids_all_comparison <- combine_MCMC_comparison_results(orchids_basic_comparison[[1]],
                                                         orchids_DHMM_comparison[[1]],
                                                         name = "orchids_MCMC_comparison")

make_MCMC_comparison_pages(orchids_all_comparison,
                           dir = "orchids_all_comparison",
                           modelNames = "orchids")

## browseURL(file.path("orchids_all_comparison", "orchids.html"))
```

Results are [here](orchids_all_comparisons/orchids.html)

# Conclusions

- A good improvement was seen, but not as much as for the dipper example.
- One could still proceed with customizing samplers with the dDHMM version of the model.
- In the Canada Goose example, Turek et al. also grouped duplicate capture histories together.

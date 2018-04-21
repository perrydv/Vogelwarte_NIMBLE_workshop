---
title: "Block sampling coefficients in Nmixture example"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



# Refresher on the Nmixture with covariates example

- Simulated example from AHM Chapter 6.4.

- 3 sampling occasions at each of 100 sites split among 3 habitat types.

- Detection covariate is `Xwind`.  Abundance covariate is `XvegHt`.

- What needs to be sampled in this model?

    - `alpha0[1]` ... `alpha0[3]`, detection intercepts at 3 sampling times
    - `alpha1[1]` ... `alpha1[3]`, detection slopes at 3 sampling times
    - `beta0[1]` ... `beta0[3]`, abundance intercepts at 3 sampling times
    - `beta1[1]` ... `beta1[3]`, abundance slopes at 3 sampling times
    - `N[1]` ... `N[100]`, latent population size at 100 sites

- There are some posterior predictive nodes.

# Look at the BUGS code


```r
Section6p4_code
```

```
## {
##     for (k in 1:3) {
##         alpha0[k] ~ dunif(-10, 10)
##         alpha1[k] ~ dunif(-10, 10)
##         beta0[k] ~ dunif(-10, 10)
##         beta1[k] ~ dunif(-10, 10)
##     }
##     for (i in 1:M) {
##         N[i] ~ dpois(lambda[i])
##         log(lambda[i]) <- beta0[hab[i]] + beta1[hab[i]] * vegHt[i]
##         critical[i] <- step(2 - N[i])
##         z[i] <- step(N[i] - 0.5)
##         for (j in 1:J) {
##             C[i, j] ~ dbin(p[i, j], N[i])
##             logit(p[i, j]) <- alpha0[j] + alpha1[j] * wind[i, 
##                 j]
##         }
##     }
##     Nocc <- sum(z[1:100])
##     Ntotal <- sum(N[1:100])
##     Nhab[1] <- sum(N[1:33])
##     Nhab[2] <- sum(N[34:66])
##     Nhab[3] <- sum(N[67:100])
##     for (k in 1:100) {
##         for (level in 1:3) {
##             lam.pred[k, level] <- exp(beta0[level] + beta1[level] * 
##                 XvegHt[k])
##             logit(p.pred[k, level]) <- alpha0[level] + alpha1[level] * 
##                 Xwind[k]
##         }
##     }
##     N.critical <- sum(critical[1:100])
## }
```

# What are default samplers?


```r
MCMCconf <- configureMCMC(Nmix_model)
MCMCconf$printSamplers()
```

```
## [1]   RW sampler: alpha0[1]
## [2]   RW sampler: alpha0[2]
## [3]   RW sampler: alpha0[3]
## [4]   RW sampler: alpha1[1]
## [5]   RW sampler: alpha1[2]
## [6]   RW sampler: alpha1[3]
## [7]   RW sampler: beta0[1]
## [8]   RW sampler: beta0[2]
## [9]   RW sampler: beta0[3]
## [10]  RW sampler: beta1[1]
## [11]  RW sampler: beta1[2]
## [12]  RW sampler: beta1[3]
## [13]  slice sampler: N[1]
## [14]  slice sampler: N[2]
## [15]  slice sampler: N[3]
## [16]  slice sampler: N[4]
## [17]  slice sampler: N[5]
## [18]  slice sampler: N[6]
## [19]  slice sampler: N[7]
## [20]  slice sampler: N[8]
## [21]  slice sampler: N[9]
## [22]  slice sampler: N[10]
## [23]  slice sampler: N[11]
## [24]  slice sampler: N[12]
## [25]  slice sampler: N[13]
## [26]  slice sampler: N[14]
## [27]  slice sampler: N[15]
## [28]  slice sampler: N[16]
## [29]  slice sampler: N[17]
## [30]  slice sampler: N[18]
## [31]  slice sampler: N[19]
## [32]  slice sampler: N[20]
## [33]  slice sampler: N[21]
## [34]  slice sampler: N[22]
## [35]  slice sampler: N[23]
## [36]  slice sampler: N[24]
## [37]  slice sampler: N[25]
## [38]  slice sampler: N[26]
## [39]  slice sampler: N[27]
## [40]  slice sampler: N[28]
## [41]  slice sampler: N[29]
## [42]  slice sampler: N[30]
## [43]  slice sampler: N[31]
## [44]  slice sampler: N[32]
## [45]  slice sampler: N[33]
## [46]  slice sampler: N[34]
## [47]  slice sampler: N[35]
## [48]  slice sampler: N[36]
## [49]  slice sampler: N[37]
## [50]  slice sampler: N[38]
## [51]  slice sampler: N[39]
## [52]  slice sampler: N[40]
## [53]  slice sampler: N[41]
## [54]  slice sampler: N[42]
## [55]  slice sampler: N[43]
## [56]  slice sampler: N[44]
## [57]  slice sampler: N[45]
## [58]  slice sampler: N[46]
## [59]  slice sampler: N[47]
## [60]  slice sampler: N[48]
## [61]  slice sampler: N[49]
## [62]  slice sampler: N[50]
## [63]  slice sampler: N[51]
## [64]  slice sampler: N[52]
## [65]  slice sampler: N[53]
## [66]  slice sampler: N[54]
## [67]  slice sampler: N[55]
## [68]  slice sampler: N[56]
## [69]  slice sampler: N[57]
## [70]  slice sampler: N[58]
## [71]  slice sampler: N[59]
## [72]  slice sampler: N[60]
## [73]  slice sampler: N[61]
## [74]  slice sampler: N[62]
## [75]  slice sampler: N[63]
## [76]  slice sampler: N[64]
## [77]  slice sampler: N[65]
## [78]  slice sampler: N[66]
## [79]  slice sampler: N[67]
## [80]  slice sampler: N[68]
## [81]  slice sampler: N[69]
## [82]  slice sampler: N[70]
## [83]  slice sampler: N[71]
## [84]  slice sampler: N[72]
## [85]  slice sampler: N[73]
## [86]  slice sampler: N[74]
## [87]  slice sampler: N[75]
## [88]  slice sampler: N[76]
## [89]  slice sampler: N[77]
## [90]  slice sampler: N[78]
## [91]  slice sampler: N[79]
## [92]  slice sampler: N[80]
## [93]  slice sampler: N[81]
## [94]  slice sampler: N[82]
## [95]  slice sampler: N[83]
## [96]  slice sampler: N[84]
## [97]  slice sampler: N[85]
## [98]  slice sampler: N[86]
## [99]  slice sampler: N[87]
## [100] slice sampler: N[88]
## [101] slice sampler: N[89]
## [102] slice sampler: N[90]
## [103] slice sampler: N[91]
## [104] slice sampler: N[92]
## [105] slice sampler: N[93]
## [106] slice sampler: N[94]
## [107] slice sampler: N[95]
## [108] slice sampler: N[96]
## [109] slice sampler: N[97]
## [110] slice sampler: N[98]
## [111] slice sampler: N[99]
## [112] slice sampler: N[100]
```

# Think about scalar samplers

- By default NIMBLE often uses adaptive random-walk
Metropolis-Hastings samplers (`type = 'RW'`) on scalar nodes.  These
are computationally fast but do not always yield a move.

- An alternative is slice sampling (`type = 'slice'`).  These always
yield a move but are computationally slower.

- JAGS uses slice samplers more extensively than NIMBLE's default, but
you can always customize NIMBLE's choices.

- JAGS does not use Metropolis-Hastings, IIUC.

# Think about the samplers: posterior correlations

- Coefficients in linear predictors generally yield correlated
posteriors, for which block sampling may help.

    - Adaptive random-walk Metropolis-Hastings (RWMH) block sampler (`type =
    'RW_block'`) is computationally fast but may or may not mix well.

    - One can use repeats of RWMH to push for more mixing.

    - Automated Factor Slice Sampler (AFSS) (`type = 'AF_slice'`) is
      computationally slower but should create better mixing.

# Think about shared computation in the graph

- Coefficients in linear predictors by definition share graph
dependencies (or "descendents" or "children").

- By sampling them jointly with one of the block sampling strategies,
we can save computations.

# Think about the latent states

- Sampling the discrete latent states common to population models
raises special challenges.

- By default, NIMBLE and JAGS (IIUC) use slice samplers for
Poisson-distributed variables.

- Later, we can try writing a new sampler for these latent states.

# Exercise: compare some sampling strategies

Use NIMBLE to compare the following strategies:

- JAGS
- NIMBLE with default samplers
- NIMBLE with slice samplers on all nodes
- NIMBLE with the following customization:

    - `AF_slice` samplers on each pair of coefficients that enter the
      same linear predictor (e.g. `alpha0[1]` and `alpha1[1]`,
      `beta0[1]` and `beta1[1]`, etc.).





---
title: "Example: state-space model with house martin data"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---




- House martin abundance estimates from 1990-2009
- 6 additional years of posterior prediction are included
- The model is density-independent.
- There are no covariates.
- Process noise and observation error and both normal on a log scale.

# Model code


```r
martin_code
```

```
## {
##     logN.est[1] ~ dnorm(5.6, 0.01)
##     mean.r ~ dnorm(1, 0.001)
##     sigma.proc ~ dunif(0, 1)
##     sigma2.proc <- pow(sigma.proc, 2)
##     tau.proc <- pow(sigma.proc, -2)
##     sigma.obs ~ dunif(0, 1)
##     sigma2.obs <- pow(sigma.obs, 2)
##     tau.obs <- pow(sigma.obs, -2)
##     for (t in 1:(T - 1)) {
##         r[t] ~ dnorm(mean.r, tau.proc)
##         logN.est[t + 1] <- logN.est[t] + r[t]
##     }
##     for (t in 1:T) {
##         y[t] ~ dnorm(logN.est[t], tau.obs)
##     }
##     for (t in 1:T) {
##         N.est[t] <- exp(logN.est[t])
##     }
## }
```

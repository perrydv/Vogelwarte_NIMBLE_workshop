---
title: "Example introduction: Cormack-Jolly-Seber model with dipper data"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



# Dipper data

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

---
title: "Example: multi-state capture-recapture with ladyslipper orchids"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



# Orchids (ladyslipper) example

This example is described [here](../example_multi_state_CR_orchids/example_multi_state_CR_orchids_slides.html)

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


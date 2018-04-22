---
title: "Example: Zero-inflated Poisson N-mixture model for Swiss Great Tits data"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



# Example: Swiss Great Tits

This examples is from Applied Hierarchical Modeling in Ecology, Vol I (K&#233;ry and Royle), Chapter 6, section 6.11.1.

### Data summary:

- 267 1-km^2 quadrats in Switzerland
- 2-3 surveys per breeding season per quadrat
- Counts follow zero-inflated Poisson: There some probability of a structural zero, and otherwise a Poisson distribution.
- Latent abundance depends on 8 coefficients (intercept + 7 fixed effects)
- Detection probability depends on survey-specific intercept + 13 fixed effects (including some interactions).
- Random effects for site abundance, site detection and survey are not used in this example.

# Figure(s) from book

Let's run the original book code and generate its figure(s).


```r
cur_dir <- getwd()
setwd(file.path(nimble_course_dir,
                 'examples_code',
                 'ZIP_Nmixture_SwissGreatTits'))
.GlobalEnv$DO_PLOT <- TRUE
source("ZIP_Nmixture_SwissGreatTits.R")
```

```
## Loading required package: unmarked
```

```
## Loading required package: reshape
```

```
## Loading required package: lattice
```

```
## Loading required package: parallel
```

```
## Loading required package: Rcpp
```

```
## Warning: package 'Rcpp' was built under R version 3.4.4
```

```
## List of 5
##  $ species:'data.frame':	6 obs. of  3 variables:
##   ..$ specid : int [1:6] 3790 3800 3820 3830 3860 3870
##   ..$ latname: chr [1:6] "PARMAJ" "PARCAE" "PARATE" "PARCRI" ...
##   ..$ name   : chr [1:6] "Great tit" "Blue tit" "Coal tit" "Crested tit" ...
##  $ sites  :'data.frame':	267 obs. of  9 variables:
##   ..$ siteID   : chr [1:267] "Q001" "Q002" "Q003" "Q004" ...
##   ..$ coordx   : int [1:267] 922942 928942 928942 934942 934942 946942 946942 952942 958942 958942 ...
##   ..$ coordy   : int [1:267] 63276 79276 103276 95276 111276 95276 111276 119276 111276 127276 ...
##   ..$ AQ       : int [1:267] 1 2 3 3 4 5 6 7 9 10 ...
##   ..$ AQ.coordx: int [1:267] 920442 930942 930942 930942 930942 950942 950942 950942 960942 960942 ...
##   ..$ AQ.coordy: int [1:267] 170224 190724 210724 210724 220724 210724 220724 230724 220724 240724 ...
##   ..$ elev     : int [1:267] 450 450 1050 950 1150 550 750 650 550 550 ...
##   ..$ rlength  : num [1:267] 6.4 5.5 4.3 4.5 5.4 3.6 3.9 6.1 5.8 4.5 ...
##   ..$ forest   : int [1:267] 3 21 32 9 35 2 6 60 5 13 ...
##  $ counts : num [1:267, 1:3, 1:10, 1:6] NA 21 2 NA 4 NA 11 4 NA NA ...
##   ..- attr(*, "dimnames")=List of 4
##   .. ..$ site   : chr [1:267] "Q001" "Q002" "Q003" "Q004" ...
##   .. ..$ rep    : chr [1:3] "1" "2" "3"
##   .. ..$ year   : chr [1:10] "2004" "2005" "2006" "2007" ...
##   .. ..$ species: chr [1:6] "Great tit" "Blue tit" "Coal tit" "Crested tit" ...
##  $ date   : int [1:267, 1:3, 1:10] 28 23 25 24 22 27 20 21 34 20 ...
##   ..- attr(*, "dimnames")=List of 3
##   .. ..$ site: chr [1:267] "Q001" "Q002" "Q003" "Q004" ...
##   .. ..$ rep : chr [1:3] "1" "2" "3"
##   .. ..$ year: chr [1:10] "2004" "2005" "2006" "2007" ...
##  $ dur    : int [1:267, 1:3, 1:10] 240 175 215 180 180 300 215 200 135 150 ...
##   ..- attr(*, "dimnames")=List of 3
##   .. ..$ site: chr [1:267] "Q001" "Q002" "Q003" "Q004" ...
##   .. ..$ rep : chr [1:3] "1" "2" "3"
##   .. ..$ year: chr [1:10] "2004" "2005" "2006" "2007" ...
##  num [1:263, 1:3] 25 20 4 12 0 4 12 7 10 5 ...
##  - attr(*, "dimnames")=List of 2
##   ..$ site: chr [1:263] "Q001" "Q002" "Q003" "Q004" ...
##   ..$ rep : chr [1:3] "1" "2" "3"
```

![plot of chunk make-figures](figure/make-figures-1.png)

```
## unmarkedFrame Object
## 
## 263 sites
## Maximum number of observations per site: 3 
## Mean number of observations per site: 2.83 
## Sites with at least one detection: 191 
## 
## Tabulation of y observations:
##    0    1    2    3    4    5    6    7    8    9   10   11   12   13   14 
##  215   45   32   33   42   34   37   34   26   24   24   20   24   23   19 
##   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29 
##   18   16    8   12    8    4    6    3    5    7    5    2    2    1    1 
##   30   31   32   33   34   35   38   41 <NA> 
##    2    2    1    2    1    3    1    1   46 
## 
## Site-level covariates:
##       elev              forest           iLength      
##  Min.   :-1.46576   Min.   :-1.2571   Min.   :0.1064  
##  1st Qu.:-0.99774   1st Qu.:-0.9508   1st Qu.:0.1695  
##  Median :-0.06169   Median :-0.0677   Median :0.1961  
##  Mean   : 0.00000   Mean   : 0.0000   Mean   :0.2099  
##  3rd Qu.: 1.03036   3rd Qu.: 0.7793   3rd Qu.:0.2326  
##  Max.   : 2.43443   Max.   : 2.3112   Max.   :0.8333  
## 
## Observation-level covariates:
##  time         date              dur          
##  1:263   Min.   :-2.0395   Min.   :-2.67940  
##  2:263   1st Qu.:-0.7859   1st Qu.:-0.67188  
##  3:263   Median :-0.2417   Median :-0.01575  
##          Mean   : 0.0000   Mean   : 0.00000  
##          3rd Qu.: 0.5073   3rd Qu.: 0.65899  
##          Max.   : 3.7113   Max.   : 3.23391  
##          NA's   :46        NA's   :46
```

```r
setwd(cur_dir)
```

# Original BUGS code

Here is the original BUGS code, modified slightly for NIMBLE, including separation of posterior predictive quantities inside a definition-time conditional.


```r
Section6p11_code
```

```
## {
##     phi ~ dunif(0, 1)
##     theta <- 1 - phi
##     ltheta <- logit(theta)
##     beta0 ~ dnorm(0, 0.1)
##     for (k in 1:7) {
##         beta[k] ~ dnorm(0, 1)
##     }
##     tau.lam <- pow(sd.lam, -2)
##     sd.lam ~ dunif(0, 2)
##     for (j in 1:3) {
##         alpha0[j] <- logit(mean.p[j])
##         mean.p[j] ~ dunif(0, 1)
##     }
##     for (k in 1:13) {
##         alpha[k] ~ dnorm(0, 1)
##     }
##     tau.p.site <- pow(sd.p.site, -2)
##     sd.p.site ~ dunif(0, 2)
##     tau.p.survey <- pow(sd.p.survey, -2)
##     sd.p.survey ~ dunif(0, 2)
##     for (i in 1:nsite) {
##         a[i] ~ dbern(phi)
##         eps.lam[i] ~ dnorm(0, tau.lam)
##         loglam[i] <- beta0 + inprod(beta[1:7], lamDM[i, 1:7]) + 
##             eps.lam[i] * hlam.on
##         loglam.lim[i] <- min(250, max(-250, loglam[i]))
##         lam[i] <- exp(loglam.lim[i])
##         mu.poisson[i] <- a[i] * lam[i]
##         N[i] ~ dpois(mu.poisson[i])
##     }
##     for (i in 1:nsite) {
##         eps.p.site[i] ~ dnorm(0, tau.p.site)
##         for (j in 1:nrep) {
##             y[i, j] ~ dbin(p[i, j], N[i])
##             p[i, j] <- 1/(1 + exp(-lp.lim[i, j]))
##             lp.lim[i, j] <- min(250, max(-250, lp[i, j]))
##             lp[i, j] <- alpha0[j] + alpha[1] * elev[i] + alpha[2] * 
##                 elev2[i] + alpha[3] * date[i, j] + alpha[4] * 
##                 date2[i, j] + alpha[5] * dur[i, j] + alpha[6] * 
##                 dur2[i, j] + alpha[7] * elev[i] * date[i, j] + 
##                 alpha[8] * elev2[i] * date[i, j] + alpha[9] * 
##                 elev[i] * dur[i, j] + alpha[10] * elev[i] * dur2[i, 
##                 j] + alpha[11] * elev2[i] * dur[i, j] + alpha[12] * 
##                 date[i, j] * dur[i, j] + alpha[13] * date[i, 
##                 j] * dur2[i, j] + eps.p.site[i] * hp.site.on + 
##                 eps.p.survey[i, j] * hp.survey.on
##             eps.p.survey[i, j] ~ dnorm(0, tau.p.survey)
##         }
##     }
##     if (DO_POSTERIOR_PREDICTION) {
##         for (i in 1:nsite) {
##             for (j in 1:nrep) {
##                 y.sim[i, j] ~ dbin(p[i, j], N[i])
##                 e.count[i, j] <- N[i] * p[i, j]
##                 chi2.actual[i, j] <- pow((y[i, j] - e.count[i, 
##                   j]), 2)/(e.count[i, j] + e)
##                 chi2.sim[i, j] <- pow((y.sim[i, j] - e.count[i, 
##                   j]), 2)/(e.count[i, j] + e)
##             }
##         }
##         fit.actual <- sum(chi2.actual[1:263, 1:3])
##         fit.sim <- sum(chi2.sim[1:263, 1:3])
##         bpv <- step(fit.sim - fit.actual)
##         c.hat <- fit.actual/fit.sim
##         Ntotal263 <- sum(N[1:263])
##     }
## }
```

```r
DO_POSTERIOR_PREDICTION <- FALSE
.GlobalEnv$DO_POSTERIOR_PREDICTION <- FALSE
```

---
title: "How we compare MCMC performance"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
    mathjax: deafult
---



# Overview

* NIMBLE allows fine-grained control over how MCMC is done.
* Often, great improvements can be made.
* First, we need a way to measure performance.

# Example: Dipper capture-recapture (CJS) model


```r
defaultMCMCconf <- configureMCMC(dipper_model)
defaultMCMC <- buildMCMC(defaultMCMCconf)
## We can compile both in one step
dipper_compiled <- compileNimble(dipper_model, defaultMCMC)
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```
## compilation finished.
```

```r
CdefaultMCMC <- dipper_compiled$defaultMCMC
## Illustration of running MCMC "directly"
CdefaultMCMC$run(5000)
```

```
## |-------------|-------------|-------------|-------------|
## |-------------------------------------------------------|
```

```
## NULL
```

```r
defaultSamples <- as.matrix(CdefaultMCMC$mvSamples)
## Do burn-in manually when running in this mode
defaultSamples <- defaultSamples[1001:5000,]
dir.create('default_samples_plots', showWarnings = FALSE)
mcmcplot(defaultSamples, dir = 'default_samples_plots')
```

```
## 
```

```
## 
```



MCMC plots are [here](default_samples_plots/MCMCoutput.html)

# Effective sample size for one node (parameter or latent state)

- When looking at the MCMC traceplot for one variable, we see that
samples are not sequentially independent.  That is the nature of MCMC.


```r
plot(defaultSamples[2051:2100, 'p'], type = 'b') 
```

![plot of chunk zoomed-trace-plot](figure/zoomed-trace-plot-1.png)

In this case we see both autocorrelation and Metropolis-Hastings
rejections, which have occurred when the state does not change.  (This
does not happen in JAGS, because it does not use Metropolis-Hastings.)

- *Effective sample size (ESS)* is the equivalent number of
independent samples in an MCMC chain for one parameter.

# What does "equivalent number of independent samples" mean?

- If `p[i]` were drawn independently (m samples), we could say:

$\mbox{Var}[\overline{p[i]}] = \mbox{Var}[ \frac{1}{m} \sum_{i = 1}^m p[i] ]= \frac{\mbox{Var}[p[i]]}{m}$

- Instead, we have

$\mbox{Var}[\overline{p[i]}] = \frac{\mbox{Var}[p[i]]}{\mbox{ESS}}$

where ESS is the *Effective Sample Size*.


```r
library(coda)
effectiveSize(defaultSamples)
```

```
##        p      phi 
## 274.5079 630.4315
```

We can see that the effective sample size is considerably smaller than the number of samples (4000, in this case).

# Measuring MCMC performance: MCMC efficiency

- We define *MCMC efficiency* as

$\frac{\mbox{ESS}}{\mbox{computation time}}$

- This is the number of effectively independent samples generated per time.
- ESS is different for every parameter.
- Computation time is the same for every parameter: the total time.
- We do not count setup steps like model building and compilation as
  part of computation time.  Even
  though these take time, we are more interested in the final MCMC
  performance.
- One needs a reasonable sample just to get a reasonable estimate of ESS.
- We generally do not thin when comparing methods because thinning always removes some information from a sample.  People might disagree on this choice.

# A single number: Minimum MCMC efficiency

- We want a single number to measure the performance of an MCMC.
- Often there are many fast-mixing parameters and one or a few
slow-mixing ones.
- We need all parameters to be mixed well to rely on results.
- Therefore our single measure of efficiency is:

**Net MCMC efficiency = Minimum MCMC efficiency over all parameters**

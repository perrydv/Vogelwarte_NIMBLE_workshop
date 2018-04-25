---
title: "MCEM in Nmixture example"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



# Maximum likelihood for general hierarchical models.

- A surprisingly difficult problem.

- The likelihood to be maximized is integrated over the latent states.  (Otherwise it is not really a likelihood.)

- First, do any summation/integration over latent states by direct math or computation if possible.

    - Example: dCHR, dDHMM, dZIP (user-defined distributions to sum over discrete latent states)

- Some approaches in the literature:

    - MCEM, SAEM
    - Data cloning (Lele et al; simultaneously inveted by Jacquier et al.)
    - Laplace approximation & quadrature (coming in NIMBLE, I hope).
	- More.

# Monte Carlo Expectation Maximization

- Expectation Maximization (Dempster et al. 1977) is a classic algorithm for maximizing
likelihood of models with random effects/latent states/missing data.

- Classic EM only works for models with conjugacy, so the math can be done explicitly.

- Monte Carlo EM uses Monte Carlo approximation for any hierarchical model.

- MCEM proceeds by iterating the following steps:

    - Hold the top-level parameters fixed and sample the latent states by MCMC (or other method).
    - Maximize the top-level parameters for the sample of latent states.

- Increase the MCMC sample size as the algorithm proceeds to increase accuracy for convergence.

- The algorithm is a workhorse but can be slow!

# Example with the Nmixture model


```r
MCEM <- buildMCEM(Nmix_model, c('N'), C = 0.02)
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```
## compilation finished.
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```
## compilation finished.
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```
## compilation finished.
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```
## compilation finished.
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```
## compilation finished.
```

```r
MLEs <- MCEM$run(initM = 1000)
```

```
## |-------------|-------------|-------------|-------------|
## |-------------------------------------------------------|
## Iteration Number: 1.
## Current number of MCMC iterations: 1000.
## Parameter Estimates: 
##  alpha0[1]  alpha0[2]  alpha0[3]  alpha1[1]  alpha1[2]  alpha1[3] 
## -1.0993657 -1.5290314 -1.6457508 -3.1362048 -3.7558190 -4.4338299 
##   beta0[1]   beta0[2]   beta0[3]   beta1[1]   beta1[2]   beta1[3] 
## -2.0256069 -0.1400302 -0.7782489 -1.1441400  1.3794713  2.5368219 
## Convergence Criterion: 1.02.
## |-------------|-------------|-------------|-------------|
## |-------------------------------------------------------|
## Iteration Number: 2.
## Current number of MCMC iterations: 1000.
## Parameter Estimates: 
##  alpha0[1]  alpha0[2]  alpha0[3]  alpha1[1]  alpha1[2]  alpha1[3] 
## -1.2415240 -1.7494757 -1.9075950 -3.4611581 -4.4336969 -4.8238382 
##   beta0[1]   beta0[2]   beta0[3]   beta1[1]   beta1[2]   beta1[3] 
## -2.8029575 -0.2658124 -0.5631668 -2.0188350  1.7769682  2.4406132 
## Convergence Criterion: 1.243734.
## |-------------|-------------|-------------|-------------|
## |-------------------------------------------------------|
## Iteration Number: 3.
## Current number of MCMC iterations: 1000.
## Parameter Estimates: 
##  alpha0[1]  alpha0[2]  alpha0[3]  alpha1[1]  alpha1[2]  alpha1[3] 
## -1.2853836 -1.8080569 -1.9596226 -3.4749490 -4.5717045 -4.8407319 
##   beta0[1]   beta0[2]   beta0[3]   beta1[1]   beta1[2]   beta1[3] 
## -2.9726422 -0.2960158 -0.4412036 -2.1707298  1.9696683  2.3156169 
## Convergence Criterion: 0.1127387.
## |-------------|-------------|-------------|-------------|
## |-------------------------------------------------------|
## Iteration Number: 4.
## Current number of MCMC iterations: 1000.
## Parameter Estimates: 
##  alpha0[1]  alpha0[2]  alpha0[3]  alpha1[1]  alpha1[2]  alpha1[3] 
## -1.3011575 -1.8148213 -1.9684130 -3.4654861 -4.5594395 -4.7807834 
##   beta0[1]   beta0[2]   beta0[3]   beta1[1]   beta1[2]   beta1[3] 
## -3.1814354 -0.2986396 -0.3717864 -2.4528163  1.9428889  2.2408348 
## Convergence Criterion: 0.05063777.
## |-------------|-------------|-------------|-------------|
## |-------------------------------------------------------|
## Iteration Number: 5.
## Current number of MCMC iterations: 1000.
## Parameter Estimates: 
##  alpha0[1]  alpha0[2]  alpha0[3]  alpha1[1]  alpha1[2]  alpha1[3] 
## -1.3146393 -1.8181527 -1.9641482 -3.4349671 -4.5332485 -4.6862780 
##   beta0[1]   beta0[2]   beta0[3]   beta1[1]   beta1[2]   beta1[3] 
## -3.2420023 -0.2985505 -0.3576102 -2.5336973  2.0157084  2.2348483 
## Convergence Criterion: 0.04412921.
## |-------------|-------------|-------------|-------------|
## |-------------------------------------------------------|
## Iteration Number: 6.
## Current number of MCMC iterations: 1000.
## Parameter Estimates: 
##  alpha0[1]  alpha0[2]  alpha0[3]  alpha1[1]  alpha1[2]  alpha1[3] 
## -1.3165801 -1.8301757 -1.9879900 -3.4342490 -4.5559567 -4.7441856 
##   beta0[1]   beta0[2]   beta0[3]   beta1[1]   beta1[2]   beta1[3] 
## -3.3332380 -0.2968007 -0.3505905 -2.6174069  1.9944022  2.2288451 
## Convergence Criterion: 0.01070241.
```

```r
MLEs
```

```
##  alpha0[1]  alpha0[2]  alpha0[3]  alpha1[1]  alpha1[2]  alpha1[3] 
## -1.3165801 -1.8301757 -1.9879900 -3.4342490 -4.5559567 -4.7441856 
##   beta0[1]   beta0[2]   beta0[3]   beta1[1]   beta1[2]   beta1[3] 
## -3.3332380 -0.2968007 -0.3505905 -2.6174069  1.9944022  2.2288451
```

```r
save(MLEs, file = "Nmix_MLEs.RData")
```

The MLEs look reasonable compared to the posterior summaries.

They could be more accurate by decreasing C.



---
title: "Introduction to customizing MCMC in NIMBLE"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



# How does Markov chain Monte Carlo work?

I assume you have some familiarity with the concepts of sampling from Bayesian posterior distribution.  But how does MCMC work?

MCMC is more like a set of general rules than a single algorithm.

There are lots of **samplers** that satisfy the rules.

Statisticians are regularly inventing new samplers and proving that they too satisfy the rules.

Other packages provide limited flexibility to control the details of how MCMC will be done for a particular model.

NIMBLE allows control over which samplers wil be used, and it allows you to write new samplers.

# Some terminology: sampler vs. kernel.

A **sampler** updates the value of one or more nodes in a model.

- Sometimes an "update" results in the same value it started with.

A **kernel** is a set of samplers that together are valid for sampling from the full posterior.

(Speaking casually, people might say "sampler" to describe a "kernel", but we find it useful to maintain the distinction.)

# A sampler configuration in NIMBLE

NIMBLE's first step towards creating an MCMC is to create a **configuration**.

A configuration is simply a list of what kind of sampler will be used for which parts of a model.

We will use two examples:

- the pump model (*for the last time*!);
- the Nmixture model with covariates.

## Pump sampler assignments


```r
pumpMCMCconf <- configureMCMC(pump)
pumpMCMCconf$printSamplers()
```

```
## [1]  RW sampler: alpha
## [2]  conjugate_dgamma_dgamma sampler: beta
## [3]  conjugate_dgamma_dpois sampler: theta[1]
## [4]  conjugate_dgamma_dpois sampler: theta[2]
## [5]  conjugate_dgamma_dpois sampler: theta[3]
## [6]  conjugate_dgamma_dpois sampler: theta[4]
## [7]  conjugate_dgamma_dpois sampler: theta[5]
## [8]  conjugate_dgamma_dpois sampler: theta[6]
## [9]  conjugate_dgamma_dpois sampler: theta[7]
## [10] conjugate_dgamma_dpois sampler: theta[8]
## [11] conjugate_dgamma_dpois sampler: theta[9]
## [12] conjugate_dgamma_dpois sampler: theta[10]
```

We can access the sampler configuration objects to dig deeper

```r
pump_samplers<- pumpMCMCconf$getSamplers()
pump_samplers
```

```
## [[1]]
## RW sampler: alpha
## [[2]]
## conjugate_dgamma_dgamma sampler: beta
## [[3]]
## conjugate_dgamma_dpois sampler: theta[1]
## [[4]]
## conjugate_dgamma_dpois sampler: theta[2]
## [[5]]
## conjugate_dgamma_dpois sampler: theta[3]
## [[6]]
## conjugate_dgamma_dpois sampler: theta[4]
## [[7]]
## conjugate_dgamma_dpois sampler: theta[5]
## [[8]]
## conjugate_dgamma_dpois sampler: theta[6]
## [[9]]
## conjugate_dgamma_dpois sampler: theta[7]
## [[10]]
## conjugate_dgamma_dpois sampler: theta[8]
## [[11]]
## conjugate_dgamma_dpois sampler: theta[9]
## [[12]]
## conjugate_dgamma_dpois sampler: theta[10]
```

```r
## look at the first one
alpha_sampler <- pump_samplers[[1]]
class(alpha_sampler)
```

```
## [1] "samplerConf"
## attr(,"package")
## [1] "nimble"
```

```r
ls(alpha_sampler)
```

```
## [1] "control"         "initialize"      "name"            "samplerFunction"
## [5] "show"            "target"          "targetAsScalar"  "toStr"
```

```r
alpha_sampler$target
```

```
## [1] "alpha"
```

## N-mixture sampler assignments


```r
NmixMCMCconf <- configureMCMC(Nmix_model)
NmixMCMCconf$printSamplers()
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

# Customizing a sampler configuration

Let's say you want to remove the random-walk sampler on `alpha` in the pump model and replace it with a slice sampler.


```r
## First check on samplers for node alpha
pumpMCMCconf$printSamplers("alpha")
```

```
## [1] RW sampler: alpha
```

```r
## Remove the old sampler
pumpMCMCconf$removeSamplers("alpha")
## Add a new sampler
pumpMCMCconf$addSampler(target = "alpha", type = "slice")
pumpMCMCconf$printSamplers()
```

```
## [1]  conjugate_dgamma_dgamma sampler: beta
## [2]  conjugate_dgamma_dpois sampler: theta[1]
## [3]  conjugate_dgamma_dpois sampler: theta[2]
## [4]  conjugate_dgamma_dpois sampler: theta[3]
## [5]  conjugate_dgamma_dpois sampler: theta[4]
## [6]  conjugate_dgamma_dpois sampler: theta[5]
## [7]  conjugate_dgamma_dpois sampler: theta[6]
## [8]  conjugate_dgamma_dpois sampler: theta[7]
## [9]  conjugate_dgamma_dpois sampler: theta[8]
## [10] conjugate_dgamma_dpois sampler: theta[9]
## [11] conjugate_dgamma_dpois sampler: theta[10]
## [12] slice sampler: alpha
```

# More customizing of a sampler configuration #

We can also:

- have more than sampler for a node;
- re-order the samplers.

Sometimes this matters to MCMC efficiency.  Let's say we want another sampler on `alpha` because it needs more mixing attention, and we want them to be separated in the order:


```r
pumpMCMCconf$addSampler(target = "alpha", type = "slice")
pumpMCMCconf$printSamplers()
```

```
## [1]  conjugate_dgamma_dgamma sampler: beta
## [2]  conjugate_dgamma_dpois sampler: theta[1]
## [3]  conjugate_dgamma_dpois sampler: theta[2]
## [4]  conjugate_dgamma_dpois sampler: theta[3]
## [5]  conjugate_dgamma_dpois sampler: theta[4]
## [6]  conjugate_dgamma_dpois sampler: theta[5]
## [7]  conjugate_dgamma_dpois sampler: theta[6]
## [8]  conjugate_dgamma_dpois sampler: theta[7]
## [9]  conjugate_dgamma_dpois sampler: theta[8]
## [10] conjugate_dgamma_dpois sampler: theta[9]
## [11] conjugate_dgamma_dpois sampler: theta[10]
## [12] slice sampler: alpha
## [13] slice sampler: alpha
```

```r
pumpMCMCconf$setSamplers(c(1:6, 12, 7:11, 13))
pumpMCMCconf$printSamplers()
```

```
## [1]  conjugate_dgamma_dgamma sampler: beta
## [2]  conjugate_dgamma_dpois sampler: theta[1]
## [3]  conjugate_dgamma_dpois sampler: theta[2]
## [4]  conjugate_dgamma_dpois sampler: theta[3]
## [5]  conjugate_dgamma_dpois sampler: theta[4]
## [6]  conjugate_dgamma_dpois sampler: theta[5]
## [7]  slice sampler: alpha
## [8]  conjugate_dgamma_dpois sampler: theta[6]
## [9]  conjugate_dgamma_dpois sampler: theta[7]
## [10] conjugate_dgamma_dpois sampler: theta[8]
## [11] conjugate_dgamma_dpois sampler: theta[9]
## [12] conjugate_dgamma_dpois sampler: theta[10]
## [13] slice sampler: alpha
```

# Customizing samplers programmatically

Say you want to replace the sampler for every `theta` node with a random-walk Metropolis-Hastings sampler.


```r
## First let's start with a fresh default configuration
pumpMCMCconf <- configureMCMC(pump)
## Next let's make a function that replaces samplers for
## any nodes requested.
assignRW <- function(MCMCconf, model, nodes) {
    nodes <- model$expandNodeNames(nodes)
    for(node in nodes) {
        MCMCconf$removeSamplers(node)
        MCMCconf$addSampler(target = node, type = "RW")
    }
    MCMCconf
}
## Then let's use the function for all theta nodes.
assignRW(pumpMCMCconf, pump, 'theta')
```

```
## MCMC configuration object
```

```r
pumpMCMCconf$printSamplers()
```

```
## [1]  RW sampler: alpha
## [2]  conjugate_dgamma_dgamma sampler: beta
## [3]  RW sampler: theta[1]
## [4]  RW sampler: theta[2]
## [5]  RW sampler: theta[3]
## [6]  RW sampler: theta[4]
## [7]  RW sampler: theta[5]
## [8]  RW sampler: theta[6]
## [9]  RW sampler: theta[7]
## [10] RW sampler: theta[8]
## [11] RW sampler: theta[9]
## [12] RW sampler: theta[10]
```

Note that an MCMC configuration object is a reference class object, so it is passed by reference and modifications happen in-place.

# Populating an empty or partial MCMC configuration

Another strategy to take complete control is to make an empty configuration or a partial configuration by providing only those nodes you want configured.


```r
## configure sampler only for node alpha
pumpMCMCconf_empty <- configureMCMC(pump, nodes = 'alpha')
pumpMCMCconf_empty$printSamplers()
```

```
## [1] RW sampler: alpha
```

```r
## We could then use addSampler to populate the rest of what we want.
```


# Kinds of samplers

The kinds of samplers that bundled with NIMBLE are listed by `help(samplers)` or in the source code [here]( ).

Each sampler has `control` options we haven't discussed.

These include:

- Gibbs (aka conjugate). 
- binary
- adaptive random-walk Metropolis-Hastings
- block adaptive random-walk Metropolis-Hastings
- `RW_llFunction` A random-walk Metropolis-Hastings that calls any log-likelihood function you provide.
- slice
- elliptical slice sampler
- automated factor slice sampler
- cross-level sampler
- random-walk for particle MCMC
- block random-walk for particle MCMC
- random-walk multinomial sampler
- random-walk Dirichlet sampler
- CAR (conditional autoregression model) normal sampler
- CAR proper sampler
- posterior predictive sampler

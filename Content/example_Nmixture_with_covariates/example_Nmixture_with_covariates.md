---
title: "Example: simulated N-mixture model with covariates"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



# Nmixture with covariates example

- Simulated example from Applied Hierarchical Modeling in Ecology, Vol. 1 (K&#233;ry and Royle), Chapter 6.4.

- 3 sampling occasions at each of 100 sites split among 3 habitat types.

- Detection covariate is `Xwind`.  Abundance covariate is `XvegHt`.

- What needs to be sampled in this model?

    - `alpha0[1]` ... `alpha0[3]`, detection intercepts at 3 sampling times
    - `alpha1[1]` ... `alpha1[3]`, detection slopes at 3 sampling times
    - `beta0[1]` ... `beta0[3]`, abundance intercepts at 3 sampling times
    - `beta1[1]` ... `beta1[3]`, abundance slopes at 3 sampling times
    - `N[1]` ... `N[100]`, latent population size at 100 sites

- There are some posterior predictive nodes.

# Look at the original BUGS/JAGS code

The code for JAGS is [here](../examples_code/Nmixture_with_covariates/model2.txt).

---
title: "Why program in NIMBLE"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---

# Write new distributions

- At first glance, the BUGS language supports all basic distributions.
- In BUGS and JAGS, people use the "zeros trick" to create new distributions:

    - Define a "data" value of 0 following a Poisson.
    - Write the Poisson mean to give the desired probability.
    - This is awkward and limited to what can be written in BUGS.

- A "distribution" can be **any** relationship defining a (log probability).
- Examples of custom distribution needs:

    - zero-inflated distributions (ZIB, ZIP, ZINB)
    - capture-recapture distributions
    - hidden Markov model distributions (multi-state capture-recapture)
    - occupancy and dynamic occupancy distributions
    - distributions that use a model-specific parameterization

# Write new MCMC samplers

- MCMC is more like list of components (samplers) than a single algorithm.
- Choosing the right samplers can yield huge gains in MCMC efficiency.
- "The cathedral and the bazaar" (Raymond).
- A prescriptive "cathedral" approach, where we as experts prescribe samplers for every occasion, is bound to fail.
- A "bazaar" approach where advanced users can implement their own solutions is desirable.
- Examples:

    - Samplers for `dcat` latent states (inherently inefficient)
    - Samplers for integer latent states
    - Samplers for SCR locations
    - Samplers for data-augmentation virtual individuals
	- Samplers on transformed coordinate scales
	- Samplers that take advantage of specific model structure
	- Samplers drawn from the huge MCMC literature, which has many
      ideas that are rarely used in applied work because they are not
      in general software.

# Write new algorithms

- MCMC does not address every statistical question
- Normalizing constants for model comparisons (information criteria)
- Cross-validation (in NIMBLE)
- Calibrated posterior-predictive p-values (in development)
- Maximum likelihood methods (MCEM, others in development)
- Sequential Monte Carlo (in NIMBLE)
- WAIC (in NIMBLE)
- Model simulators
- Model likelihood calculators
- Future: Laplace approximation and quadrature
- Other approaches to model selection, validation, and estimation.
- Your ideas.

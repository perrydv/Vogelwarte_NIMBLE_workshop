---
title: "Vogelwarte NIMBLE workshop: Day 1"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---

# Organization of workshop and materials

- [Organization](../administrative_stuff/administrative_stuff_slides.html)

# Getting started with NIMBLE

- [Introduction to NIMBLE](../introduction_to_NIMBLE/introduction_to_NIMBLE_slides.html)
- [NIMBLE's dialect of BUGS modeling language](../nimble_dialect_of_BUGS/nimble_dialect_of_BUGS_slides.html)
- [Converting existing models and data from JAGS or BUGS to NIMBLE](../converting_jags_bugs_to_nimble/converting_jags_bugs_to_nimble_slides.html)
- [Introduction to using NIMBLE models](../using_nimble_models/using_nimble_models_slides.html)

- Understanding variables, nodes, and lifted nodes

- [Exercise: Convert N-mixture model from JAGS to NIMBLE](../exercise_converting_jags_bugs_to_nimble/exercise_converting_jags_bugs_to_nimble_slides.html).

    - Code is [here](../exercise_converting_jags_bugs_to_nimble/exercise_converting_jags_bugs_to_nimble.R).

# MCMC in NIMBLE

- Introduction to customizing MCMC in NIMBLE
- [How we compare MCMC performance](../how_we_compare_mcmc_performance/how_we_compare_mcmc_performance_slides.html)
- [NIMBLE's compareMCMCs and MCMCsuite functions](../introduction_to_compareMCMCs/introduction_to_compareMCMCs_slides.html)
- [Strategies for improving MCMC](../strategies_for_improving_mcmc/strategies_for_improving_mcmc_slides.html)
- [Exercise: Nmixture model with coefficients](../Nmixture_block_sampling_coefs/Nmixture_block_sampling_coefs_slides.html)

    - Code is [here](../exercise_converting_jags_bugs_to_nimble/exercise_converting_jags_bugs_to_nimble.R).

- Worked example: Nmixture model for Swiss Great Tits
- NIMBLE's automatic blocking system

# Programming in NIMBLE

- [Why program in NIMBLE?](../why_program_in_nimble/why_program_in_nimble_slides.html)
- [Introduction to nimbleFunctions](../introduction_to_nimbleFunctions/introduction_to_nimbleFunctions_slides.html)
- [The NIMBLE compiler](../introduction_nimble_compiler/introduction_nimble_compiler_slides.html)
- [The NIMBLE language: What is supported for compilation?](../nimble_language/nimble_language_slides.html)

# Writing new model functions and distributions

- [Cormack-Jolly-Seber as a distribution](../capture_recapture_CJS_distribution/capture_recapture_CJS_distribution_slides.html)
- [Exercise: Occupancy as a distribution](../exercise_occupancy_distribution/exercise_occupancy_distribution_slides.html)
- Multi-state capture-recapture as a Hidden Markov Model distribution
- [Exercise: Zero-inflated Poisson]

# Programming with models in NIMBLE

- [Programming with models: A likelihood calculator](../programming_with_models/programming_with_models_slides.html)
- [Programming with models: A data simulator](../programming_data_simulator/programming_data_simulator_slides.html)
- [Compiling in multiple steps: The NIMBLE project](../programming_project/programming_project_slides.html)

# Writing new MCMC samplers

- Introduction to MCMC samplers in NIMBLE
- Exercise: 
- Exercise: Discrete random-walk sampler for latent population sizes
- Reversible jump for model selection
- Reversible jump for data augmentation

# Other algorithms in NIMBLE


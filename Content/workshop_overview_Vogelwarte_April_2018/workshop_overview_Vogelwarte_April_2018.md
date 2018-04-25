---
title: "Vogelwarte NIMBLE workshop"
subtitle: "April 23-25, 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---

# Organization of workshop and materials

- [Organization](../administrative_stuff/administrative_stuff_slides.html)
- [List of examples](../examples_overview/examples_overview_slides.html)

# Getting started with NIMBLE

- [Introduction to NIMBLE](../introduction_to_NIMBLE/introduction_to_NIMBLE_slides.html)
- [NIMBLE's dialect of BUGS modeling language](../nimble_dialect_of_BUGS/NIMBLE_dialect_of_BUGS_slides.html)
- [Converting existing models and data from JAGS or BUGS to NIMBLE](../converting_jags_bugs_to_nimble/converting_jags_bugs_to_nimble_slides.html)
- [Introduction to using NIMBLE models](../using_nimble_models/using_nimble_models_slides.html)

- [Understanding variables, nodes, lifted nodes, and the graph](understanding-variables-nodes-and-lifted-nodes/understanding-variables-nodes-and-lifted-nodes_slides.html)

- [Exercise: Convert N-mixture model from JAGS to NIMBLE](../exercise_converting_jags_bugs_to_nimble/exercise_converting_jags_bugs_to_nimble_slides.html).

    - Code is [here](../exercise_converting_jags_bugs_to_nimble/exercise_converting_jags_bugs_to_nimble.R).

- Exercise part 2: Identify different nodes, variables, and kinds of nodes in the N-mixture model.

# MCMC in NIMBLE

- [Introduction to customizing MCMC in NIMBLE](../introduction_customizing_MCMC/introduction_customizing_MCMC_slides.html)
- [How we compare MCMC performance](../how_we_compare_mcmc_performance/how_we_compare_mcmc_performance_slides.html)
- [NIMBLE's compareMCMCs and MCMCsuite functions](../introduction_to_compareMCMCs/introduction_to_compareMCMCs_slides.html)
- [Strategies for improving MCMC](../strategies_for_improving_mcmc/strategies_for_improving_mcmc_slides.html)
- [Exercise: Nmixture model with coefficients](../exercise_Nmixture_block_sampling_coefs/exercise_Nmixture_block_sampling_coefs_slides.html)

    - Code is [here](../exercise_Nmixture_block_sampling_coefs/exercise_Nmixture_block_sampling_coefs.R)

- [Worked example: Nmixture model for Swiss Great Tits](worked_example_ZIP_Nmixture_SwissGreatTits/worked_example_ZIP_Nmixture_SwissGreatTits_slides.html)
- NIMBLE's automatic blocking system

# Programming in NIMBLE

- [Why program in NIMBLE?](../why_program_in_nimble/why_program_in_nimble_slides.html)
- [Introduction to nimbleFunctions](../introduction_to_nimbleFunctions/introduction_to_nimbleFunctions_slides.html)
- [The NIMBLE compiler](../introduction_nimble_compiler/introduction_nimble_compiler_slides.html)
- [The NIMBLE language: What is supported for compilation?](../nimble_language/nimble_language_slides.html)

# Writing new model functions and distributions

- [Cormack-Jolly-Seber as a distribution](../capture_recapture_CJS_distribution/capture_recapture_CJS_distribution_slides.html)
- [Exercise: Occupancy as a distribution](../exercise_occupancy_distribution/exercise_occupancy_distribution_slides.html)

    - [Exercise code](../exercise_occupancy_distribution/exercise_occupancy_distribution.R)

- [Multi-state capture-recapture as a Hidden Markov Model distribution](../multistate_capture_recapture_distribution/multistate_capture_recapture_distribution_slides.html)
- Exercise: Zero-inflated Poisson

# Programming with models in NIMBLE

- Programming with models: A likelihood calculator
- Programming with models: A data simulator
- Compiling in multiple steps: The NIMBLE project

# Writing new MCMC samplers

- [Introduction to MCMC samplers in NIMBLE: write our own random-walk Metropolis-Hastings.](../introduction_to_samplers_write_MH/introduction_to_samplers_write_MH_slides.html)
- [Worked example: jointly sample juveniles and adults in an integrated population model.](../new_samplers_IPM_woodchat_shrike/new_samplers_IPM_woodchat_shrike_slides.html)
- [Reversible jump for model selection: example on web site](https://r-nimble.org/examples).
- [Reversible jump for data augmentation: Czech transect capture-recapture (just example code)](../examples_code/CR_DA_Czech/CR_DA_Czech.R)
- Spatial capture-recapture: discussion (also see [this](https://www.nature.com/articles/srep41036) and [this](https://www.nature.com/articles/s41598-018-20675-9) paper by Jose Jimenez.   Also see [this old list post](https://nature.berkeley.edu/~pdevalpine/SCR_NIMBLE_ideas/SCR_NIMBLE_ideas.html) by me, using a much older version of nimble.

# Other algorithms in NIMBLE

- [Maximum likelihood estimation using MCEM.](../MCEM_Nmixture_with_covariates/MCEM_Nmixture_with_covariates_slides.html)
- Cross-validation.
- WAIC.
- Future: Calibrated posterior predictive p-values.
- Your idea here.

# Future directions

- [Future directions of NIMBLE development](../future_directions/future_directions_slides.html)

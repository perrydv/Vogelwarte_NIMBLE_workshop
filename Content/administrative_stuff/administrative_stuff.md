---
title: "Vogelwarte NIMBLE workshop: Organization of materials"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---

# Installing NIMBLE

## We will work from development version
- Branch "devel" on [NIMBLE's GitHub repository](https://github.com/nimble-dev/nimble)
- To install branch "devel" from R:

```r
library(devtools)
install_github("nimble-dev/nimble", ref = "devel", subdir = "packages/nimble")
```

## Web site and User Manual
- For general information, see [NIMBLE's web site](http://r-nimble.org)
- The User Manual is [here](http://r-nimble.org/manuals/NimbleUserManual.pdf).

## For release 0.6-11
- To install from CRAN, use `install.packages("nimble")`.
- To install from r-nimble.org, see [here](https://r-nimble.org/download).
- Chapter four of the [User Manual](http://r-nimble.org/manuals/NimbleUserManual.pdf) discusses installation requirements.

# GitHub site

- Workshope materials are on [NIMBLE's Github outreach repository](https://github.com/nimble-dev/nimble-outreach)

- We may update materials during the course of the workshop.

## Using Github to get the documents

To download the files from Github, you can do the following:

### Within RStudio

Within RStudio go to File->New Project->Version Control->Git and enter:

- "Repository URL": https://github.com/nimble-dev/nimble-outreach
- "Project Directory Name": nimble-outreach (or something else of your choosing)
- "Directory": ~/Desktop (or somewhere of your choosing)

Then to update from the repository to get any changes we've made, you can select (from within RStudio):
Tools->Version Control->Pull Branches

or from the Environment/History/Git window, click on the Git tab and then on the blue down arrow.


Be warned that you probably do not want to make your own notes or changes to the files we are providing. Because if you do, and you then do a "Git Pull" to update the materials, you'll have to deal with the conflict between your local version and our version. You probably will want to make a personal copy of such files in another directory or by making copies of files with new names.

### From the GitHub site directly:

- Go to [https://github.com/nimble-dev/nimble-outreach](https://github.com/nimble-dev/nimble-outreach) and click on the 'Clone or Download' button in the right side of the window and then on 'Download ZIP'.

### From a GitHub desktop app:

- Go to [https://github.com/nimble-dev/nimble-outreach](https://github.com/nimble-dev/nimble-outreach) and click on the 'Clone or Download' button in the right side of the window and then on 'Open in Desktop'.

### From a terminal window

Run the following commands:

- `cd /directory/where/you/want/repository/located`
- `git clone https://github.com/nimble-dev/nimble-outreach`

Then to update from the repository to get any changes we've made:

- `cd /directory/where/you/put/the/repository/nimble-outreach`
- `git pull`


## Etherpad for quick sharing

- There is an online shared document at [https://pad.systemli.org/p/nimble_vogelwarte](https://pad.systemli.org/p/nimble_vogelwarte).
- We can use this for rapid code sharing.
- This will disappear after 30 days of inactivity.

## Organization of workshop modules

- Each module is in a separate directory. Example: [Introduction to NIMBLE](../introduction_to_nimble)
- In each directory you will see:

    - Rmarkdown source file.  You do not need to use this.  Example: [introduction_to_nimble.Rmd](../introduction_to_nimble/introduction_to_nimble.Rmd)
    - Slides (..._slides.html).  Example: [introduction_to_nimble_slides.Rmd](../introduction_to_nimble/introduction_to_nimble_slides.html)
    - The slides content as a single html (.html). Example: [introduction_to_nimble.Rmd](../introduction_to_nimble/introduction_to_nimble.html)
    - The R code extracted to a separate file. Example: [introduction_to_nimble.R](../introduction_to_nimble/introduction_to_nimble.R)

- There will be one or more master files to navigate among the modules.

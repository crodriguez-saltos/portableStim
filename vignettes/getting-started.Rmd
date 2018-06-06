---
title: "portableStim: Getting Started"
author: "Carlos Antonio Rodriguez-Saltos"
date: "`r Sys.Date()`"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Vignette Title}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

```{r setup, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
```

The portableStim packages allows the user to generate acoustic presentations based on a single source audio file. The audio file is repeated several times, according to user specifications, and silence gaps are placed in between repeates. The silence gaps may be constant in duration or they may be drawn from a random, Poisson distribution, depending on user specifications.

A typical presentation generated using portableStim will have the following structure:

![Structure of an acoustic presentation generated using portableStim](presentation_diagram.png){width=600px}

## Installing portableStim
portableStim can be easily installed inot an R distribution by running the following command, from the R console:

```{r, eval= FALSE}
devtools::install_github("crodriguez-saltos/portableStim")
```

Make sure to have installed the package 'devtools' for the above code to work:

```{r, eval= FALSE}
install.packages("devtools")
```

### Installing SoX
portableStim needs the program SoX to run properly. SoX, the "Swiss Army Knife of sound processing programs", is a cross-platform command-line utility. SoX must be installed by the user before using portableStim. For instructions on how to install SoX on your platform, please refer to the SoX website: http://sox.sourceforge.net/

## The genTrain function
The core of portableStim is genTrain(). Please check the function documentation to see all the arguments that can be specified. The name of a soundfile can be passed to genTrain() as well as the name of the output presentation. genTrain() builds a schema for the presentation based on user specifications and then calls the command line program SoX to manipulate the sound file. Using SoX significantly reduces the time required to generate the presentation file, as opposed to using utilities that load sound files into an R environment.

## tico - our example source file
In the following examples, we will use the "tico" sound datum provided by the package seewave. This sound corresponds to the song of a Rufous-collared Sparrow (_Zonotrichia capensis_) about 1.8 seconds long. 

portableStim requires a sound file as input, rather than a data object. portableStim, however, recognizes when the user calls "tico" and it automatically saves the data object into a temporary file.

"tico" can be called in portableStim by setting the "sound"" argument in genTrain() to "#tico#".

Here is a sonogram of "tico":

```{r fig.width= 7, fig.align='center', fig.height= 4}
data(tico, package = "seewave")
seewave::spectro(tico)
```

## Generating a bout
A bout is a series of repititions of a sound, or rendition, following portableStim nomenclature, with generally short silence intervals in between.

In the following example, we will generate a bout of tico song that is 11 seconds long and that has constant silence intervals of 1 sec each. This bout will be used in all the following examples.

```{r fig.width= 7, fig.align='center', fig.height= 4}
library(portableStim)

# Create a temporary file where to store the output presentation
outputf <- tempfile(fileext = ".wav")  

# Generate presentation
genTrain(
  sound = "#tico#",  # Source sound
  bout.length = 10,  # Length of the bout in seconds
  intRend.type = "constant",  # Type of interval. Can be constant or random.
  intRend.length = 1,  # Length of the silence intervals between renditions, in seconds
  output = outputf,  # Output file
  # The following argumentswill be explained later
  tpres = 11,
  intBout.type = "constant",
  nbout= 1,
  report= F
)

wavef <- tuneR::readWave(outputf)
seewave::spectro(wave = wavef)
```

## Generating a presentation with constant silence intervals
To generate a presentation with constant silence intervals, all of the following parameters must be specified: 1) total time of the presentation, 2) length of the silence interval, and at least one of the following parameters: 1) number of bouts, 2) length of each bout.

In the following example, we will generate a presentation with the following characteristics: 
- presentation time: 1 min
- interval between bouts: 5 sec
- bout length: 5 sec

```{r fig.width= 7, fig.align='center', fig.height= 4}
library(portableStim)

# Create a temporary file where to store the output presentation
outputf <- tempfile(fileext = ".wav")  

# Generate presentation
genTrain(
  # Data required to created a single bout
  sound = "#tico#",  
  bout.length = 5,  
  intRend.type = "constant", 
  intRend.length = 1, 
  output = outputf,
  # Repeat bout as specified by user
  tpres = 1 * 60,  # Presentation duration, in seconds
  intBout.type = "constant",  # Type if interval between bouts
  intBout.length = 5,  # Average duration of intervals between bouts, in seconds
  report= F  # Should silence interval positions be returned?
)

# Plot sonogram of presentation
wavef <- tuneR::readWave(outputf)
seewave::spectro(wave = wavef)
```

Key in telling genTrain() that the bout intervals are constant is the argument "intBout.type". This argument is similar to "intRend.type"", which specifies the type of intervals between renditions within a bout.

## Generating a presentation with random intervals
Presentations can also be generated with silence intervals between bouts drawn from a Poisson distribution. The average length of intervals (ie. intBout.length) is used as the value for the parameter lambda in the Poisson distribution. Lambda is both the average duration of interbout intervals and the standard deviation of that average.

```{r fig.width= 7, fig.align='center', fig.height= 4}
library(portableStim)

# Create a temporary file where to store the output presentation
outputf <- tempfile(fileext = ".wav")  

# Generate presentation
genTrain(
  # Data required to created a single bout
  sound = "#tico#",  
  bout.length = 5,  
  intRend.type = "constant", 
  intRend.length = 1, 
  output = outputf,
  tpres = 1 * 60,
  intBout.type = "random",  # specify random intervals between bouts
  intBout.length = 5,
  report= F
)

# Plot sonogram of presentation
wavef <- tuneR::readWave(outputf)
seewave::spectro(wave = wavef)
```

## Read interval between renditions from a database
The duration of the interval between renditions can be obtained from a database containing typical values for a given species. The database must have two columns, one named "species" and the other named "interval". The column names are self-explanatory.

In the following example, we will open a datafile containing a ficticious value of 1.2 seconds of interval for species "fict". First we will open the datafile:

```{r}
infodb <- read.table(
  system.file("interval_example.txt", package = "portableStim"), 
  header = T
)
head(infodb)
```

Then we just pass this database to genTrain(), specifying the species we want to get the interval from:

```{r fig.width= 7, fig.align='center', fig.height= 4}
library(portableStim)

# Load infodb
infodb <- read.table(
  system.file("interval_example.txt", package = "portableStim"), 
  header = T
)
head(infodb)

# Create a temporary file where to store the output presentation
outputf <- tempfile(fileext = ".wav")  

# Generate presentation
outputf <- genTrain(
  sound = "#tico#",
  species = "fict",  # Select the species by its name
  infodb = infodb,  # Call the infodb database
  bout.length = 10,
  intRend.type = "constant",
  output = outputf,
  tpres = 11,
  intBout.type = "constant",
  nbout= 1,
  report= F,
  returnoutput = T
)

# Plot sonogram of presentation
wavef <- tuneR::readWave(outputf)
seewave::spectro(wave = wavef)
```

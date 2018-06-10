# portableStim

The portableStim packages allows the user to generate acoustic presentations based on a single source audio file. The audio file is repeated several times, according to user specifications, and silence gaps are placed in between repeates. The silence gaps may be constant in duration or they may be drawn from a random, Poisson distribution, depending on user specifications.

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

## Getting started
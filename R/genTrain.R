#'Generate auditory presentation
#'
#'Generate auditory presentations based on existing sound files.
#'@keywords audio stimuli
#'@param sound Source sound. Can also be a directory, or many directories,
#'  containing the sound file.
#'@param species Species for each sound file.
#'@param soundlab Label of sound file (eg. “experimental”, “positive control”,
#'  “negative control”).
#'@param infoDB Databasee containing info on each source file.
#'@param tpres Total duration of presentation in seconds (5 min for sound
#'  transmission)
#'@param nrend Number of renditions per bout.
#'@param intRend.type Type of intervals between renditions (constant - mean
#'  natural interval –- median) (depends on species) - read from a database.
#'@param intRend.length Length of the interval between rendtions. Only
#'  functional if intRend.type = "custom".
#'@param int.factor Factor by which to multiply the length of the interval
#'  between renditions. (0.5, 1, or 2) (for sound transmission experiment).
#'@param nbout Number of bouts in presentation (all experiments except sound
#'  transmission – only those in which bout interval type= random)
#'@param bout.length Length of each bout (predetermined: 20s – behavior; 10s –
#'  sound transmission; 5s - ZENK)
#'@param intBout.type Type of interval between bouts. Can take the values
#'  "random" or "constant".
#'@param intBout.length Length of interval between bouts (depending on type of
#'  interval: range, number)
#'@param rate Bout rate, in times per minute.
#'@param seed Seed for random number generators.
#'@param output Name of output file.
#'
#'@details If the length of the source audio files is such that the presentation
#'  would end being longer than T, the last instance of the source sound will be
#'  truncated in order for the duration of the presentation to be equal to T.
#'
#'  More than one directory file can be given in fs. Use the concanteante (c())
#'  function to list the directories.
#'
#'  Name of files should be stored in a table, relating the name of the file to
#'  a particular species. Alternatively, the species can be included in the name
#'  of the file.
#'
#'  Have just one script that will allow to generate stimuli for all
#'  experiments. Then, create three derivative functions, one for each
#'  experiment.
#'
#'  For auditory stimuli experiment set bout.length, intRend.type,
#'  intRend.length (for positive control), nbout, tpres.'
#'
#'  For ZENK stimuli, set rate, nrend, intBout.length, intBout.type
#'@export

genTrain <- function(
  sound,
  species,
  soundlab,
  infodb,
  tpres,
  #nrend = NA,
  intRend.type,
  intRend.length,
  int.factor = 1,
  nbout = NA,
  bout.length = NA,
  intBout.type,
  intBout.length = NA,
  rate = NA,
  seed = NA,
  output
){

  # Check argument values----
  if (intRend.length >= bout.length){
    stop("Interval between each rendition cannot be equal or larger than bout length.")
  }

  if (!is.na(nbout) & !is.na(intBout.length)){
    warning(paste(
      "tpres, nbout, and intBout.length are given; either nbout or\n",
      "intBout.length may not be taken into account depending on\n",
      "the value of intBout.type."
    ))
  }

  # Set seed----
  if (!is.na(seed)){
    set.seed(seed)
  }

  # Get duration of sound----
  if (sound == "#tico#"){
    data(tico, package = "seewave")
    fdir <- tempdir()
    f <- file.path(fdir, "tico.wav")
    tuneR::writeWave(object = tico, filename = f)
    #rm(tico)
  }

  # TODO: Use sox to extract audio file info
  duration <- getduration(f)

  # Within a presentation, define start and end of bouts----
  if (is.na(nbout) & !is.na(rate)){
    nbout <- round(tpres * rate / 60)
  }

  boutmat <- intblock(
      int.type = intBout.type,
      int.length = intBout.length,
      block.length = bout.length,
      nblock = nbout,
      total = tpres,
      gap_start = T
  )

  # Within a bout, define start and end timepoints of renditions----
  rendmat <- intblock(
    int.type = intRend.type,
    int.length = intRend.length * int.factor,
   # nblock = nrend,
    block.length = duration,
    total = bout.length,
    gap_start = F
  )

  # Arrange bout----
  boutf <- tempfile(fileext = ".wav")
  rend.gaps <- unname(c(
    rendmat[1,1],
    rendmat[1,2:ncol(rendmat)] - rendmat[2, 1:(ncol(rendmat) - 1)]
  ))
  metamerize(sound = f, gaps = rend.gaps, total = bout.length, output = boutf)

  # Arrange presentation----
  bout.gaps <- unname(c(
    boutmat[1,1],
    boutmat[1,2:ncol(boutmat)] - boutmat[2, 1:(ncol(boutmat) - 1)]
  ))
  metamerize(sound = boutf, gaps = bout.gaps, total = tpres, output = output)
}

#'Generate auditory presentation
#'
#'Generate auditory presentations based on existing sound files.
#'@keywords audio stimuli
#'@param sound Source sound. Can also be a directory, or many directories,
#'  containing the sound file.
#'@param species Species for each sound file.
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
#'@param report Logical. Should silence gap start times be reported?
#'@param writewav Logical. Should presentation be written into a wave file?
#'@param output Name of output file.
#'@param ext Extension of output file. Omitted if already specified in output.
#'@param returnoutput Logical. Should output filename be returned?
#'
#'@details If the length of the source audio files is such that the presentation
#'  would end being longer than T, the last instance of the source sound will be
#'  truncated in order for the duration of the presentation to be equal to T.
#'@export

genTrain <- function(
  sound,
  species = NULL,
  infodb = NULL,
  tpres,
  #nrend = NA,
  intRend.type,
  intRend.length = NA,
  int.factor = 1,
  nbout = NA,
  bout.length = NA,
  intBout.type,
  intBout.length = NA,
  rate = NA,
  seed = NA,
  writewav = T,
  output,
  ext = "wav",
  report = T,
  returnoutput = F
){
  # Check argument values----
  if (is.na(bout.length)){
    stop("Please specify bout duration.")
  }

  if (!is.na(nbout) & !is.na(intBout.length)){
    warning(paste(
      "tpres, nbout, and intBout.length are given; either nbout or\n",
      "intBout.length may not be taken into account depending on\n",
      "the value of intBout.type."
    ))
  }

  if (bout.length > tpres){
    stop("Bout duration cannot be longer than presentation duration.")
  }

  # Set seed----
  if (!is.na(seed)){
    set.seed(seed)
  }

  # Construct output filename----
  output <- tools::file_path_sans_ext(output)

  fileparts <- list(output, species)
  fileparts <- lapply(fileparts, function(x){
    gsub(pattern = " ", replacement = "-", x = x)
  })
  pasteunderscore <- function(...) paste(..., sep= "_")
  output <- do.call("pasteunderscore", fileparts)
  while(substr(start = nchar(output), stop= nchar(output), x = output) == "_"){
    output <- substr(start= 1, stop= nchar(output) - 1, x = output)
  }
  output <- paste(output, ext, sep= ".")
  rm(fileparts, pasteunderscore)

  # Read inter-rendition intervals from a database----
  if(!is.null(infodb)){
    if (is.null(species)){
      stop("Please provide a species name.")
    }
    if(!is.na(intRend.length)){
      warning("intRend.length will be overriden by value from database.")
    }
    intRend.length <- infodb[infodb$species == species,]$interval
  }

  if (intRend.length >= bout.length){
    stop("Interval between each rendition cannot be equal or larger than bout length.")
  }

  # Get duration of sound----
  if (sound == "#tico#"){
    data(tico, package = "seewave")
    fdir <- tempdir()
    f <- file.path(fdir, "tico.wav")
    tuneR::writeWave(object = tico, filename = f)
    #rm(tico)
  }else{
    f <- sound
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
  rendmat <- cbind(rendmat, rep(bout.length, 2))
  rend.gaps <- unname(c(
    rendmat[1,1],
    rendmat[1,2:ncol(rendmat)] - rendmat[2, 1:(ncol(rendmat) - 1)]
  ))
  rend.gaps <- rend.gaps[rend.gaps >= 0]

  if (writewav){
    metamerize(sound = f, gaps = rend.gaps, total = bout.length,
               output = boutf)
  }

  # Arrange presentation----
  boutmat <- cbind(boutmat, rep(tpres, 2))
  bout.gaps <- unname(c(
    boutmat[1,1],
    boutmat[1,2:ncol(boutmat)] - boutmat[2, 1:(ncol(boutmat) - 1)]
  ))
  bout.gaps <- bout.gaps[bout.gaps >= 0]
  if (writewav){
    metamerize(sound = boutf, gaps = bout.gaps, total = tpres,
               output = output)
  }

  # Write report----
  if (report){
    return(list(rendtion.gaps = rend.gaps, bout.gaps = bout.gaps))
  }

  if (returnoutput){
    return(output)
  }
}

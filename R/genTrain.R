#' Generate a stimulus train
#'
#' Create auditory stimulus for behavioral experiments.
#' @param sound The sound file to be imported.
#' @keywords audio stimuli
#' @examples
#' genTrain(sound = "#tico#")
#' @export

genTrain <- function(sound){
  if (sound == "#tico#"){
    data(tico, package = "seewave")
    s <- tico
    rm(tico)
  }

  print(s)
}

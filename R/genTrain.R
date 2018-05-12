#' Generate a stimulus train
#' 
#' Create auditory stimulus for behavioral experiments.
#' @param sound The sound to be imported.
#' @keywords audio stimuli
#' @examples 
#' genTrain(sound = "#tico#")

genTrain <- function(sound){
  require(seewave)
  
  if (sound == "#tico#"){
    data(tico)
    s <- tico
    rm(tico)
  }
  
  print(s)
}
#' Get duration of a wave file based on exif data.
#' 
#' Requires SoX.
#' 
#' @keywords audio
#' @param wav Wave file.
#' @export

getduration <- function(wav){
  exif <- system2(
    command = "sox",
    args = paste(wav, "-n stat"),
    stdout = T, stderr = T
  )
  
  ind <- grep(pattern = "Length", x = exif)
  duration <- strsplit(x = exif[ind], split = ":")[[1]][2]
  duration <- as.numeric(duration)
  return(duration)
}

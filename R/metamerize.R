#' Metamerize
#'
#' Construct presentations by repeating an audio signal several times and
#' introducing silence gaps in between. Requires SoX installed in system.
#'
#' @keywords audio, time series
#' @param total Duration of presentation in seconds.
#' @param gaps Vector of silence gaps.
#' @param sound File address of source sound file.
#' @param output Name of output file.
#' @details  Will return TRUE ff the function was run succesfully.
#' @export

metamerize <- function(sound, gaps, total, output){
  # Auxilliary functions----
  exitloop <- function(){
    system2(
      command= "sox",
      args = paste(tempwav, tempwav2, "trim 0", total)
    )
    file.rename(from = tempwav2, to = output)
    return(T)
  }

  # Create temporary files----
  tempwav <- tempfile(fileext = ".wav")
  tempwav2 <- tempfile(fileext = ".wav")

  # Metamerize----
  for (i in 1:length(gaps)){
    if (i == 1){
      # First gap
      system2(
        command = "sox",
        args = paste(sound, tempwav, "pad", paste0(gaps[i], "@0:00"))
      )
    }else{
      # Add gap
      system2(
        command = "sox",
        args = paste(tempwav, tempwav2, "pad 0", gaps[i])
      )
      file.rename(from = tempwav2, to = tempwav)

      # Concatenate
      t <- getduration(tempwav)

      if (t > total){
        # Truncate
        exitloop()
      }else{
        system2(
          command = "sox",
          args = paste(tempwav, sound, tempwav2)
        )
        file.rename(from = tempwav2, to = tempwav)
      }

      # Truncate
      if (t > total){
        exitloop()
      }
    }
  }

  t <- getduration(tempwav)

  if (t > total){
    # Truncate
    exitloop()
  }else{
    system2(
      command= "sox",
      args = paste(tempwav, tempwav2, "pad 0", total - t)
    )
    file.rename(from = tempwav2, to = output)
  }
}

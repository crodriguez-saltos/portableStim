#' Intercalate repeats of a block at random or constant intervals
#'
#' @keywords time series
#' @param int.type Type of interval.
#' @param block.length Length of the block
#' @param nblock Repeats of the block.
#' @param total Total length in seconds.
#' @param gap_start Logical. Should sequence start with a gap.
#'
#' @details A block is considered a time series classfied as signal. A gap is
#'   silence or noise.
#'
#'   Intercalates repeat of the blocks, alternating between block and silence. If the total
#'   duration of the sequence is less than that specified by the used in total,
#'   a truncated blokc is added at the end until the total length of the
#'   sequence is equal to that specified in total.
#'
#' @export

intblock <- function(
  int.type= "random", int.length= NA, block.length, nblock= NA, total, gap_start
){
  if (is.na(nblock)){
    # Interval and bouth lengths must be given.
    nblock <- ceiling((total - int.length) / (int.length + block.length))
  }

  if (is.na(total)){
    # This assignment for total is provisional
    totalwasna <- T
    total <- (int.length + block.length) * nblock * 10
  }else{
    totalwasna <- F
  }

  if (int.type == "random"){
    tgap <- total - block.length * nblock
    lambda <- tgap / (nblock + 1)
    gaps <- round(rpois(n = nblock + 1, lambda = lambda))
  }else if (int.type == "constant"){
    gaps <- rep(x = int.length, times= nblock + 1)
  }

  if (!gap_start){
    gaps <- c(0, gaps[1:nblock])
  }

  block.s <- cumsum(gaps[1:nblock] + c(0, rep(block.length, nblock - 1)))
  block.e <- block.s + block.length
  blockmat <- rbind(block.s, block.e)

  lastel <- blockmat["block.e", ncol(blockmat)]
  t <- lastel + gaps[length(gaps)]

  if (totalwasna){
    total <- t
  }

  if (t < total){
    blockmat <- cbind(
      blockmat, c(t, t + block.length)
    )
  }

  return(blockmat)
}

#' Adjust for compaction based on parameters
#'
#' @param origDepth unadjusted depth in cm. Can be negative so long as it's > -maxCompact
#' @param maxCompact Maximum amount of compaction in cm (i.e., the compaction observed at the surface)
#' @param compactOver Depth over which to compensate in the compaction
#' @param eEnd Where to end the exp function scale. Here, a parameter that controls the linearity of the the compaction. Lower values are more linear. Must be greater than 0.  (Default =3)
#' @importFrom glue glue
#' @return adjusted depth
#' @export
#'
#' @examples
#' depths <- seq(0,6,by = .1)
#' ad <- purrr::map_dbl(depths, adjustForCompaction, maxCompact = 0.5, compactOver = 5)
#'

adjustForCompaction <- function(origDepth,maxCompact,compactOver,eEnd = 3){

  #check inputs
  if(origDepth < -maxCompact){
    stop(glue::glue("The supplied depth ({origDepth}) is more negative than the amount of compaction ({maxCompact)} can accommodate"))
  }

  if(eEnd <= 0){stop("eEnd must be greater than 0")}

  if(compactOver <= maxCompact){
    stop(glue::glue("The distance over which to accommodate the compaction ({compactOver}) must be larger than the amount of compaction ({maxCompact})"))
  }

  #factor to scale to eEnd
  cf <- eEnd / (compactOver+maxCompact)


  if(origDepth < compactOver){
    compDepth <- origDepth+maxCompact*exp(-(maxCompact+origDepth)*cf)
  }else{
    compDepth <- origDepth
  }

return(compDepth)

}

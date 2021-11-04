#' Get core section depth from dblf
#'
#' @param core Name of the core (not the core section!) (e.g. "L380_OTOTO_LC4U")
#' @param dblf depth below the lake floor in cm
#' @importFrom purrr pmap_lgl
#' @importFrom dplyr between filter
#' @importFrom glue glue
#' @return a data.frame with core section and depth
#' @export
#'
#' @examples
#' dblf_to_coreSection("L380_OTOTO_LC4U",110)
#' dblf_to_coreSection("L380_OTOTO_LC1U",10)
dblf_to_coreSection <- function(core,dblf){
  #build a table for all cores

  theseCores <- dplyr::filter(finalKey,coreName == core)
  if(nrow(theseCores) < 2 | nrow(theseCores) > 6){
    stop(glue::glue("check your core name, we found {nrow(theseCores)} core sections with a core name of {core}. Did you enter a core and not a section name?"))
  }

  whichCore <- which(
    purrr::pmap_lgl(theseCores,
                    function(secTopDblf,secBotDblf,...){
                      dplyr::between(dblf,left = secTopDblf, right = secBotDblf)
                    }
    )
  )

  if(length(whichCore)<1){
    stop("Dblf is outside the possible range for these cores.")
  }
  if(length(whichCore)>1){
    warning("Multiple cores found with this dblf. This probably means the dblf is on a boundary. Taking the upper core")
    whichCore <- min(whichCore)
  }

  thisCore <- theseCores[whichCore,]
  sds <- seq(thisCore$roiTop,thisCore$roiBot,length.out = 100)
  sdblf <- coreSection_to_dblf(thisCore$`Section Name`,sds)

  secDepth <- approx(sdblf$dblf,sds,dblf)$y

  out <- data.frame(dblf,thisCore$`Section Name`,secDepth)
  out <- setNames(out,c("dblf (cm)","Core Section","Section Depth (cm)"))

  return(out)

}


#' Calculate depth below lake floor
#'
#' @param corename Name of the lakes 380 core section
#' @param cm section depth, from the top of the core liner, in cm
#' @importFrom glue glue
#' @importFrom dplyr filter
#'
#' @return depth below lake floor in cm
#' @export
#'
#' @examples
#'
#' coreSection_to_dblf("L380_DUNCA3_LC4U_1",50:60)
#'
coreSection_to_dblf <- function(corename,cm){

  if(all(is.na(cm))){
    return(NA)
  }

  if(!is.character(corename)){
    stop("corename should be of class character")
  }

  corename <- unique(corename)
  if(length(corename) > 1){
    stop("more than one corename was entered. To calculate depths from multiple sections, use multi_coreSection_to_dblf")
  }

  #find the relevant core section row
  section <- dplyr::filter(finalKey,tolower(corename) == tolower(`Section Name`))

  if(nrow(section) == 0){
    stop(glue::glue("Couldn't find a core section named {corename}. Search for corenames with `findCoreSectionName`, or for a list of known core sections run `listCoreSectionNames()`"))
  }

  if(nrow(section) > 1){
    stop("Multiple core section matches. This shouldn't happen")
  }

  # Get key metadata
  secTopDblf <- section$secTopDblf[1]
  secRoiTop <- section$roiTop[1]
  secRoiBot <- section$roiBot[1]

  #check for compaction adjustment
  compact <- FALSE
  if(!is.na(section$compact) & !is.na(section$compactOver)){
    compact <- TRUE
  }

  #adjust to bottom depth if within 1 cm.
  if(any(between(secRoiBot - cm,-1,0))){
    tc <- which(between(secRoiBot - cm,-1,0))
    cm[tc] <- secRoiBot
  }

  if(compact){#check for bottom depth
    if(is.numeric(secRoiBot)){
      if(any(secRoiBot < cm)){
        badDepth <- cm[which(secRoiBot < cm)]
        stop(glue::glue("At least one requested depth ({badDepth[1]} cm) is below the ROI range ({secRoiTop} to {secRoiBot} cm) for core {corename}"))
      }
    }
  }else{#check for both
    if(is.numeric(secRoiBot)){
      if(any(secRoiBot < cm | secRoiTop > cm)){
        badDepth <- cm[which(secRoiBot < cm | secRoiTop > cm)]
        stop(glue::glue("At least one requested depth ({badDepth[1]} cm) is outside the ROI range ({secRoiTop} to {secRoiBot} cm) for core {corename}"))
      }
    }
  }


  if(!is.numeric(secTopDblf) | !is.numeric(secRoiTop)){
    stop("missing metadata for core {corename}, cannot calculate depth below lake floor")
  }

  #then calculate
  dblf <- cm - secRoiTop + secTopDblf

  if(compact){
    compacted <- c()
    for(icm in 1:length(cm)){
      if(dblf[icm] > as.numeric(section$compactOver)){
        compactThis <- FALSE
      }else{
        compactThis <- TRUE
      }


      #compact if necessary
      if(compactThis){
        dblf[icm] <- adjustForCompaction(dblf[icm],
                                         maxCompact = as.numeric(section$compact),
                                         compactOver = as.numeric(section$compactOver)
        )
      }

      compacted[icm] <- compactThis
    }
  }else{
    compacted <- FALSE
  }

  return(data.frame(dblf = dblf,
                    topSource = section$topSource[1],
                    botSource = section$botSource[1],
                    coreName = corename,
                    compactionAdjusted = compacted))

}


#' Convert depths for multiple core sections
#'
#' @param corename a vector of corenames
#' @param cm a vector of corresponding depths that matches the length of corenames
#'
#' @importFrom purrr map2_dfr
#' @return a tibble
#' @export
#'
#' @examples
#'
#' multi_coreSection_to_dblf(c("L380_DUNCA3_LC4U_1","L380_DUNCA3_LC4U_2"),c(20,10))
#'
multi_coreSection_to_dblf <- function(corename,cm){


  if(is.list(corename)){
    corename <- unlist(corename)
  }


  if(is.list(cm)){
    cm <- unlist(cm)
  }

  return(purrr::map2_dfr(corename,cm,.f = coreSection_to_dblf))
}





#' Convert HSI depths for multiple core sections
#'
#' @param corename a vector of corenames
#' @param cm a vector of corresponding depths that matches the length of corenames
#'
#' @importFrom purrr map2_dfr
#' @return a tibble
#' @export
#'
#' @examples
#'
#' multi_hsi_to_dblf(c("L380_DUNCA3_LC4U_1","L380_DUNCA3_LC4U_2"),c(20,10))
#'
multi_hsi_to_dblf <- function(corename,cm){


  if(is.list(corename)){
    corename <- unlist(corename)
  }


  if(is.list(cm)){
    cm <- unlist(cm)
  }

  return(purrr::map2_dfr(corename,cm,.f = hsi_to_dblf))
}




#' List known core names
#'
#' @return a list of known core names
#' @export
#'
#' @examples
#' allNames <- listCoreSectionNames()
listCoreSectionNames <- function(){
  return(finalKey$`Section Name`)
}



#' Find a core section name
#'
#' @param corename_guess A string that is a guess at a corename
#'
#' @return Potential matches of core names given a guess
#' @export
#'
#' @examples
#' findCoreSectionName("ngano")
findCoreSectionName <- function(corename_guess){
  index <- agrep(pattern = corename_guess,x = finalKey$`Section Name`,ignore.case = TRUE)
  if(length(index) == 0){
    stop("No matches identified. Try the 5 or 6 character lake code name, e.g. `DUNCA`.")
  }
  if(length(index) > 50){
    warning("You found more than 50 matches, maybe narrow down your search?")
  }
  return(finalKey$`Section Name`[index])
}


#' Convert depths from hyperspectral imaging
#'
#' @param corename a vector of corenames
#' @param cm a vector of corresponding depths that matches the length of corenames
#'
#' @return
#' @export
#'
#' @examples
#'
#' hsi_to_dblf("L380_DUNCA3_LC4U_2",0:30)
#'
hsi_to_dblf <- function(corename,cm){

  if(all(is.na(cm))){
    return(NA)
  }

  if(!is.character(corename)){
    stop("corename should be of class character")
  }

  corename <- unique(corename)
  if(length(corename) > 1){
    stop("more than one corename was entered. To calculate depths from multiple sections, use multi_hsi_to_dblf")
  }

  #find the relevant core section row
  section <- dplyr::filter(finalKey,tolower(corename) == tolower(`Section Name`))

  if(nrow(section) == 0){
    stop(glue::glue("Couldn't find a core section named {corename}. Search for corenames with `findCoreSectionName()`, or for a list of known core sections run `listCoreSectionNames()`"))
  }

  if(nrow(section) > 1){
    stop("Multiple core section matches. This shouldn't happen")
  }

  # Get key metadata
  secTopDblf <- section$secTopDblf[1]
  secRoiTop <- section$roiTop[1]
  secRoiBot <- section$roiBot[1]


#convert to core liner
  clDepth <- cm + secRoiTop

  #adjust to bottom depth if within 1 cm.
  if(any(between(secRoiBot - clDepth,-1,0))){
    tc <- which(between(secRoiBot - clDepth,-1,0))
    clDepth[tc] <- secRoiBot
  }

  #convert back to HS depth
  cm <- clDepth - secRoiTop

  if(is.numeric(secRoiBot) & is.numeric(secRoiTop)){
    if(any((secRoiBot - secRoiTop) < cm)){
      badDepth <- cm[which((secRoiBot - secRoiTop) < cm)]
      stop(glue::glue("At least one requested depth ({badDepth[1]} cm on HSI scale, {badDepth[1] + secRoiTop} relative to the coreliner) is outside the ROI range ({secRoiTop} to {secRoiBot} cm) for core {corename}"))
    }
  }



  if(!is.numeric(secTopDblf)){
    stop("missing metadata for core {corename}, cannot calculate depth below lake floor")
  }

  #then calculate
  dblf <- cm + secTopDblf

  return(data.frame(dblf = dblf,
                    topSource = section$topSource[1],
                    botSource = section$botSource[1],
                    coreName = corename))

}


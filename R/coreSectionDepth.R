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

  if(all(is.na(dblf))){
    out <- data.frame(dblf,core,NA)
    out <- setNames(out,c("dblf (cm)","Core Section","Section Depth (cm)"))
    return(out)
  }

  theseCores <- dplyr::filter(finalKey,coreName == core)
  if(nrow(theseCores) < 1 | nrow(theseCores) > 6){
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

  secDepth <- stats::approx(sdblf$dblf,sds,dblf)$y

  out <- data.frame(dblf,thisCore$`Section Name`,secDepth)
  out <- setNames(out,c("dblf (cm)","Core Section","Section Depth (cm)"))

  return(out)

}






#' Calculate depth below lake floor
#'
#' @param corename Name of the lakes 380 core section
#' @param cm section depth, from the top of the core liner, in cm
#' @param extraAllowedBottom how many cm below the bottom of the ROI are allowed (converted to bottom of ROI) (default = 1)
#' @param extraAllowedTop how many cm above the top of the ROI are allowed (converted to top of ROI) (default = 0.25)
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
coreSection_to_dblf <- function(corename,cm,extraAllowedBottom = 1,extraAllowedTop = 0.25){

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

  whichSection <- rep(1,times = length(cm))

  #check to see if it's part of a master composite
  if(tolower(corename) %in% tolower(finalKey$`Original Section Name`)){
    isComposite <- TRUE
    #determine master corename by name and depth
    section <- dplyr::filter(finalKey,tolower(corename) == tolower(`Original Section Name`))
    whichSection <- c()
    for(r in 1:nrow(section)){
      ts <- which(dplyr::between(cm,section$roiTop[r],section$roiBot[r]))
      if(length(ts) > 0){
        whichSection[ts] <- r
      }
    }

    if(all(is.na(whichSection))){
      stop(glue::glue("Couldn't find any master core sections that match this name and depth range, perhaps you entered the wrong depth(s)"))
    }


  }else{
    #find the relevant core section row
    isComposite <- FALSE

    section <- dplyr::filter(finalKey,tolower(corename) == tolower(`Section Name`))


    if(nrow(section) == 0){
      stop(glue::glue("Couldn't find a core section named {corename}. Search for corenames with `findCoreSectionName`, or for a list of known core sections run `listCoreSectionNames()`"))
    }

    if(nrow(section) > 1){
      stop("Multiple core section matches. This shouldn't happen")
    }
  }

  #find which sections to use:
  uws <- as.numeric(na.omit(unique(whichSection)))
  alldblf <- matrix(NA,nrow = length(cm))
  for(tuws in uws){
    # Get key metadata
    secTopDblf <- section$secTopDblf[tuws]
    secRoiTop <- section$roiTop[tuws]
    secRoiBot <- section$roiBot[tuws]

    #check for compaction adjustment
    compact <- FALSE
    if(!is.na(section$compact[tuws]) & !is.na(section$compactOver[tuws])){
      if(is.numeric(section$compact[tuws]) & is.numeric(section$compactOver[tuws])){
        compact <- TRUE
      }
    }

    tcm <- cm[which(whichSection == tuws)]

    #adjust to top depth if within extraAllowedTop cm.
    if(any(between(tcm - secRoiTop,-extraAllowedTop,0))){
      tc <- which(between(tcm - secRoiTop,-extraAllowedTop,0))
      tcm[tc] <- secRoiTop
    }

    #adjust to bottom depth if within extraAllowedBottom cm.
    if(any(between(secRoiBot - tcm,-extraAllowedBottom,0))){
      tc <- which(between(secRoiBot - tcm,-extraAllowedBottom,0))
      tcm[tc] <- secRoiBot
    }

    if(compact){#check for bottom depth
      if(is.numeric(secRoiBot)){
        if(any(secRoiBot < tcm)){
          badDepth <- tcm[which(secRoiBot < tcm)]
          if(isComposite){
            warning(glue::glue("At least one requested depth ({badDepth[1]} cm) is below the ROI range ({secRoiTop} to {secRoiBot} cm) for core {corename}. This is a composite record, so we'll just ignore those depths for now."))
            tcm <- tcm[-which(secRoiBot < tcm)]
            if(length(tcm) == 0){
              stop("After removing depths outside the range, there were no depths left.")
            }

          }else{
            stop(glue::glue("At least one requested depth ({badDepth[1]} cm) is below the ROI range ({secRoiTop} to {secRoiBot} cm) for core {corename}"))
          }
        }
      }
    }else{#check for both
      if(is.numeric(secRoiBot)){
        if(any(secRoiBot < tcm | secRoiTop > tcm)){
          badDepth <- tcm[which(secRoiBot < tcm | secRoiTop > tcm)]
          if(isComposite){
            warning(glue::glue("At least one requested depth ({badDepth[1]} cm) is outside the ROI range ({secRoiTop} to {secRoiBot} cm) for core {corename}. This is a composite record, so we'll just ignore those depths for now."))
            inRange <- which(secRoiBot < tcm)
            tcm <- tcm[-inRange]

            if(length(tcm) == 0){
              stop("After removing depths outside the range, there were no depths left.")
            }

          }else{
            stop(glue::glue("At least one requested depth ({badDepth[1]} cm) is outside the ROI range ({secRoiTop} to {secRoiBot} cm) for core {corename}"))
          }
        }
      }
    }


    if(!is.numeric(secTopDblf) | !is.numeric(secRoiTop)){
      stop("missing metadata for core {corename}, cannot calculate depth below lake floor")
    }

    #then calculate
    dblf <- tcm - secRoiTop + secTopDblf #add in modifier for difference between HSI ROI and chron ROI?

    if(compact){
      compacted <- c()
      for(icm in 1:length(tcm)){
        if(any(is.na(suppressWarnings(as.numeric(section$compactOver[tuws]))))){
          compactThis <- FALSE
        }else{
          if(dblf[icm] > as.numeric(section$compactOver[tuws])){
            compactThis <- FALSE
          }else{
            compactThis <- TRUE
          }
        }

        #compact if necessary
        if(compactThis){
          dblf[icm] <- adjustForCompaction(dblf[icm],
                                           maxCompact = as.numeric(section$compact[tuws]),
                                           compactOver = as.numeric(section$compactOver[tuws])
          )
        }

        compacted[icm] <- compactThis
      }
    }else{
      compacted <- FALSE
    }
    alldblf[which(whichSection == tuws)] <- dblf

  }
  return(data.frame(corename = corename,
                    coreSectionDepth = cm,
                    dblf = alldblf,
                    topSource = section$topSource[1],
                    botSource = section$botSource[1],
                    coreName = corename,
                    compactionAdjusted = compacted,
                    compositeSequence = isComposite))

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
#' @param extraAllowedBottom how many cm below the bottom of the ROI are allowed (converted to bottom of ROI) (default = 1)
#' @return depth below lake floor in cm
#' @export
#'
#' @examples
#'
#' hsi_to_dblf("L380_DUNCA3_LC4U_2",0:30)
#'
hsi_to_dblf <- function(corename,cm,extraAllowedBottom = 1){

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
  #check to see if it's part of a master composite
  if(tolower(corename) %in% tolower(finalKey$`Original Section Name`)){
    isComposite <- TRUE
    #determine master corename by name and depth
    sectionComposite <- dplyr::filter(finalKey,tolower(corename) == tolower(`Original Section Name`))
    section <- dplyr::filter(finalKey,tolower(corename) == tolower(`Section Name`))

    # Get key metadata
    secTopDblf <- section$secTopDblf[1]
    secRoiTop <- section$roiTop[1]
    secRoiBot <- section$roiBot[1]
    # if(nrow(section) > 1){
    #   goodRow <- c()
    #   for(r in 1:nrow(section)){
    #     goodRow[r] <- all(between(cm,section$roiTop[r],section$roiBot[r]))
    #   }
    #
    #   if(sum(goodRow) == 1){#we found it!
    #     section <- section[goodRow,]
    #   }else if(sum(goodRow) == 0){
    #     stop(glue::glue("Couldn't find any master core sections that match this name and depth range, perhaps you entered the wrong depth(s)"))
    #   }else{
    #     stop(glue::glue("Found multiple master core sections that match this name and depth range, this seems like a problem with the depth table."))
    #   }
    #
    # }

  }else{
    #find the relevant core section row
    isComposite <- FALSE

    section <- dplyr::filter(finalKey,tolower(corename) == tolower(`Section Name`))

    # Get key metadata
    secTopDblf <- section$secTopDblf[1]
    secRoiTop <- section$roiTop[1]
    secRoiBot <- section$roiBot[1]
  }

  if(nrow(section) == 0){
    stop(glue::glue("Couldn't find a core section named {corename}. Search for corenames with `findCoreSectionName()`, or for a list of known core sections run `listCoreSectionNames()`"))
  }

  if(nrow(section) > 1){
    stop("Multiple core section matches. This shouldn't happen")
  }




  #convert to core liner
  clDepth <- cm + secRoiTop

  # #adjust to bottom depth if within 1 cm.
  # if(any(between(secRoiBot - clDepth,-extraAllowedBottom,0))){
  #   tc <- which(between(secRoiBot - clDepth,-extraAllowedBottom,0))
  #   clDepth[tc] <- secRoiBot
  # }


  #try to get dblf
  dblf <- coreSection_to_dblf(corename,clDepth,extraAllowedBottom = extraAllowedBottom)

  return(dblf)

  #
  #
  # #convert back to HS depth
  # cm <- clDepth - secRoiTop
  #
  # if(is.numeric(secRoiBot) & is.numeric(secRoiTop)){
  #   if(any((secRoiBot - secRoiTop) < cm)){
  #     badDepth <- cm[which((secRoiBot - secRoiTop) < cm)]
  #     stop(glue::glue("At least one requested depth ({badDepth[1]} cm on HSI scale, {badDepth[1] + secRoiTop} relative to the coreliner) is outside the ROI range ({secRoiTop} to {secRoiBot} cm) for core {corename}"))
  #   }
  # }
  #
  #
  #
  # if(!is.numeric(secTopDblf)){
  #   stop("missing metadata for core {corename}, cannot calculate depth below lake floor")
  # }
  #
  # #then calculate
  # dblf <- cm + secTopDblf
  #
  #   return(data.frame(dblf = dblf,
  #                     topSource = section$topSource[1],
  #                     botSource = section$botSource[1],
  #                     coreName = corename))

}


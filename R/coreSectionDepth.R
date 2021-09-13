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

if(is.numeric(secRoiBot)){
  if(any(secRoiBot < cm | secRoiTop > cm)){
    badDepth <- cm[which(secRoiBot < cm | secRoiTop > cm)]
    stop(glue::glue("At least one requested depth ({badDepth[1]} cm) is outside the ROI range ({secRoiTop} to {secRoiBot} cm) for core {corename}"))
  }
}


if(!is.numeric(secTopDblf) | !is.numeric(secRoiTop)){
  stop("missing metadata for core {corename}, cannot calculate depth below lake floor")
}

  #then calculate
  dblf <- cm - secRoiTop + secTopDblf


  return(data.frame(dblf = dblf,
                    topSource = section$topSource[1],
                    botSource = section$botSource[1],
                    coreName = corename))

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


#' List known core names
#'
#' @return a list of known core names
#' @export
#'
#' @examples
#' allNames <- listCoreSectionNames()
listCoreSectionNames <- function(){
  print(finalKey$`Section Name`)
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

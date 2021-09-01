library(dplyr)

getRoiTop <- function(secTop,foamTop,hsTop,hsRoiTop){
  if(is.na(hsRoiTop)){
    roiTop <- secTop + foamTop
    topSource <- "non-HSI"
  }else{
    if(is.na(hsTop)){
      roiTop <- hsRoiTop + secTop
      topSource <- "HSI"

    }else{
      roiTop <- hsRoiTop + hsTop
      topSource <- "HSI"

    }
  }

  return(bind_cols(roiTop = roiTop,topSource = topSource))
}

getRoiBot <- function(secTop,secLenField,secLenLab,foamBot,hsTop,hsRoiBot){
  if(is.na(foamBot)){foamBot <- 0}
  if(is.na(hsRoiBot)){
    if(is.na(secLenLab)){
    roiBot <- secTop + secLenField - foamBot
    botSource <- "non-HSI"
    }else{
      roiBot <- secTop + secLenLab - foamBot
      botSource <- "non-HSI"
    }
  }else{
    if(is.na(hsTop)){
      roiBot <- hsRoiBot + secTop
      botSource <- "HSI"

    }else{
      roiBot <- hsRoiBot + hsTop
      botSource <- "HSI"

    }
  }

  return(bind_cols(roiBot = roiBot,botSource = botSource))
}

#also extract which (HS or not) was used.

coreData <- readxl::read_xlsx(
  system.file("extdata", "Lakes380Cores.xlsx", package = "Lakes380CoreDepthTools"),
  col_types = "text"
)

roiTop <- select(coreData,
                 secTop = `Section Top`,
                 foamTop = `Foam Top`,
                 hsTop = `HS Core Liner Top`,
                 hsRoiTop = `HS ROI Top`) %>%
  mutate(across(.fns = as.numeric)) %>%
  purrr::pmap_dfr(.f = getRoiTop)

roiBot <- select(coreData,
                 secTop = `Section Top`,
                 secLenField = `Section Length (Field)`,
                 secLenLab = `Remeasured Section Length (Lab)`,
                 foamBot = `Foam Bottom`,
                 hsTop = `HS Core Liner Top`,
                 hsRoiBot = `HS ROI Bottom`) %>%
  mutate(across(.fns = as.numeric)) %>%
  purrr::pmap_dfr(.f = getRoiBot)




usethis::use_data(DATASET, overwrite = TRUE)

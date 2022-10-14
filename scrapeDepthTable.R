library(dplyr)
library(readr)
library(magrittr)
library(tidyr)

library(purrr)



dirWithHSIData <- "~/Download/DUNCA1 R Script HS Data/"




ff <- list.files(dirWithHSIData,
                 recursive = TRUE,
                 full.names = TRUE,
                 pattern = "depthTable.csv")

hp <- !str_detect(ff,"photos")

ff <- ff[hp]
pullDepthData <- function(path){
  dat <- readr::read_csv(path) %>%
    dplyr::select(-pixel) %>%
    tidyr::pivot_wider(names_from = position, values_from = cm)

  #parse path to get core name
  dat$corename <- path %>%
    dirname() %>%
    dirname() %>%
    basename()

  dat <- dplyr::select(dat,corename,everything())
  return(dat)
}


test <- purrr::map_dfr(ff,pullDepthData)

outpath <-""
readr::write_csv(test,path = outpath)

library(dplyr)

getRoiTop <- function(secTop,foamTop,hsTop,hsRoiTop){
  if(is.na(foamTop)){foamTop <- 0}
  if(is.na(hsRoiTop)){
    roiTop <- secTop + foamTop
    topSource <- "non-HSI"
  }else{
    if(is.na(hsTop)){
      roiTop <- hsRoiTop - secTop
      topSource <- "HSI"

    }else{
      roiTop <- hsRoiTop - hsTop
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
      roiBot <- hsRoiBot - secTop
      botSource <- "HSI"

    }else{
      roiBot <- hsRoiBot - hsTop
      botSource <- "HSI"

    }
  }

  return(bind_cols(roiBot = roiBot,botSource = botSource))
}

#also extract which (HS or not) was used.
m_to_cm <- function(m){
  return(as.numeric(m) * 100)
}

coreData <- readxl::read_xlsx(
  system.file("extdata", "Lakes380Cores.xlsx", package = "Lakes380CoreDepthTools"),
  col_types = "text",
) %>%
  mutate(across(contains("Section") & -ends_with("Section Name"),m_to_cm)) %>%
  rename(compact = `Compaction off set to correct [cm]`,
         compactOver = `Depth over which to correction compaction [cm]`)

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


key <- select(coreData,ends_with("Section Name"),starts_with("compact"),) %>%
  bind_cols(roiTop,roiBot) %>%
  mutate(sectionLength = roiBot - roiTop,
         coreName = stringr::str_remove(`Section Name`,"[_\\d{1,}]+$"),
         sectionNumber = as.numeric(stringr::str_extract(`Section Name`,pattern = "[\\d{1,}]+$"))) %>%
  arrange(sectionNumber)


secBotDblf <- secTopDblf <- matrix(NA, nrow = nrow(key))

for(i in 1:nrow(key)){
  if(key$sectionNumber[i] == 1){
    secTopDblf[i] <- 0
  }else{
    prevSecNum <- key$sectionNumber[i]-1
    prevI <- which(key$sectionNumber == prevSecNum & key$coreName == key$coreName[i])
    if(length(prevI) == 0){
      secTopDblf[i] <- NA
    }else{
    secTopDblf[i] <- secBotDblf[prevI]
    }
  }
  secBotDblf[i] <- key$sectionLength[i]+secTopDblf[i]
}

finalKey <- key %>%
  bind_cols(data.frame(secTopDblf = secTopDblf, secBotDblf = secBotDblf)) %>%
  arrange(coreName, sectionNumber)


usethis::use_data(finalKey, overwrite = TRUE,internal = TRUE)

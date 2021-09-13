#' Calculate mblf from a file
#'
#' @param filename Optionally enter the file name (default = NA, will let you pick)
#' @param outfile Optionally enter the output file path and name (default = NA, will append "-dblf" and save as csv
#' @param conv.type which conversion to use. For now the only option is coreliner
#' @importFrom crayon bold
#' @importFrom readxl read_xls read_xlsx
#' @importFrom readr read_csv write_csv
#' @imporFrom tools file_ext file_path_sans_ext
#' @importFrom dplyr bind_cols
#'
#' @return an updated file
#' @export
dblf_from_file <- function(filename = NA, outfile = NA, conv.type = "coreliner"){

  if(is.na(filename)){
    filename <- file.choose()
  }

  ext <- tools::file_ext(filename)
  name <- tools::file_path_sans_ext(filename)
  if(is.na(outfile)){
    outfile <- paste0(name,"-dblf.csv")
  }

  if(ext == "csv"){
    read <- readr::read_csv
  }else if(ext == "xls"){
    read <- readxl::read_xls
  }else if(ext == "xlsx"){
    read <- readxl::read_xlsx
  }else{
    stop("Only set up tp load csv, xls or xlsx files so far.")
  }


  #read in the data
  data_in <- read(filename)
  cat(crayon::bold("Select the core name variable:\n"))
  dn <- names(data_in)
  for(i in 1:length(dn)){
  cat(paste(i,"-",dn[i],"\n"))
  }
  n = readline(prompt="please type the number for the correct match, or a zero if none match: ")
  idi=as.numeric(n)

  if(idi == 0){
    stop("You said that none matched")
  }

  cn <- data_in[,idi]
  if(is.list(cn)){
    cn <- unlist(cn)
  }



  cat(crayon::bold("Select the depth below coreliner (in cm) variable:\n"))
  for(i in 1:length(dn)){
    cat(paste(i,"-",dn[i],"\n"))
  }
  n = readline(prompt="please type the number for the correct match, or a zero if none match: ")
  idi=as.numeric(n)

  if(idi == 0){
    stop("You said that none matched")
  }

  dp <- data_in[,idi]
  if(is.list(dp)){
    dp <- unlist(dp)
  }

  print(crayon::bold("This can take a few seconds to read/write"))

  newDepths <- multi_coreSection_to_dblf(cn,dp)

  data_out <- dplyr::bind_cols(data_in,newDepths)

  readr::write_csv(data_out,file = outfile)

  return(paste("Data written to",outfile))

}

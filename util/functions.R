#############################################
#
# functions.R
# 
# Helper functions for working with excel files in R
#
# Januar 2019
#
############################################

#' format an numeric-Excel-date as string-date
#'
#' \code{fmt_excel_date} returns a string representing the excel-numeric-date
#'
#' @param datenumber numericv vector representation of a date (as used in MS Excel)  for all cultures
#' @return string (date)
#'
#' @examples
#' date_as_string <- fmt_excel_date(28963)
fmt_excel_date <- function(datenumber){
  asdate <- as.Date(datenumber, origin = "1900-01-01")
  returnval <- format(asdate, "%d.%m.%Y")
  return(returnval)
}

#' write.excel wrapper function for openxlsx write procedure
#' This wrapper does not allow writing on existing sheets!
#'
#' @param data to data.frame convertable object containing the data
#' @param file charstring path and name of file to write to
#' @param sheet charstring name of sheet to write to
#' @param row integer number of row to start in, default = 1
#' @param col integer number of column to start in, default = 1
#' @param append boolean if NONE or FALSE check if sheet already exists is conducted an error passed
#'
#' @return NONE
#'
#'
#' @example write.excel(data = mtcars, file = "mtcars.xlsx", sheetName = "mtcarsSheet", append = FALSE, overwrite = FALSE)
#' 
write.excel <- function(data, file, sheetName, startRow = 1, startCol = 1, append = FALSE, overwrite = FALSE, rNames = FALSE){
  require(openxlsx)
  
  if(!append & file.exists(file) & !overwrite){
    stop(paste0("Die Excel Datei '", file , "' existiert bereits und overwrite = FALSE und append = FALSE. Es wurde keine Aktion durchgefuehrt!"))
  }
  
  if(append & file.exists(file)){
    wb <- loadWorkbook(file)
  } 
  
  if(!append | (append & !file.exists(file))){
    wb <- createWorkbook()
  }
  
  if(append & file.exists(file) & sheetName %in% names(wb) & !overwrite){
    stop(paste0("Das Blatt '", sheetName, "' existiert bereits in der Datei '", file , "' und overwrite  = FALSE - Es wurde keine Aktion durchgefuehrt!."))
  }
  
  data_as_df <- as.data.frame(data)
  
  if(append & file.exists(file) & sheetName %in% names(wb) & overwrite){
   removeWorksheet(wb, sheet = sheetName)
  }
  addWorksheet(wb, sheet = sheetName)
  
  writeData(wb, sheet = sheetName, x = data_as_df, startRow = startRow, startCol = startCol, rowNames = rNames)
  
  if(overwrite | append){
    saveWorkbook(wb, file = file, overwrite = TRUE)
  } else {
    saveWorkbook(wb, file = file, overwrite = FALSE)
  }
  
}




#' excel.sheets wrapper function for oepnxlsx names(wb) function
#'
#' @param file charstring path and name of file to read sheet names from
#'
#' @return charstring vector
#'
#' @example excel.sheets(file = "test/testdata.xlsx")
#' 
excel.sheets <- function(file){
  require(openxlsx)
  if(!file.exists(file)){
    stop(paste0("Die Excel Datei '", file , "' kann nicht gefunden werden"))
  }
  wb <- loadWorkbook(file)
  sheet_names <- names(wb)
  return(sheet_names)
}

#' read.excel wrapper function for xlconnect read procedure
#'
#' @param file charstring path and name of file to read from
#' @param sheet charstring name of sheet to read from. If no sheet name is given, the first sheet is imported
#'
#' @return data.frame
#'
#' @example read.excel(file = "test/testdata.xlsx", sheetName = "Sheet1")
#' 
read.excel <- function( file, sheetName = FALSE){
  require(openxlsx)
  if(!file.exists(file)){
    stop(paste0("Die Excel Datei '", file , "' kann nicht gefunden werden"))
  }
  wb <- loadWorkbook(file)
  wb_sheets <- names(wb)
  if(sheetName == FALSE){
    sheetName <- wb_sheets[1]
  }
  if(!(sheetName %in% names(wb))){
    stop(paste0("Das Blatt '", sheetName, "' wurde in der Datei '", file , "' nicht gefunden."))
  }
  value <- read.xlsx(wb, sheet = sheetName, detectDates = TRUE)
  
  return(value)
}


#' get better colors
#'
#' @param index integer index of color
#'
#' @return colorstring
#'
#' @example mc(index = 1)
#' 
mc <- function(index){
  
  better_colors <- c(
    `red`        = "#d11141",
    `green`      = "#00b159",
    `blue`       = "#00aedb",
    `orange`     = "#f37735",
    `yellow`     = "#ffc425",
    `light grey` = "#cccccc",
    `dark grey`  = "#8c8c8c")
  
  
  if(is.character(index)){
    index = which(names(better_colors) == index)
  }
  if(length(index) == 0 | index > length(better_colors)){
    stop("Index not found")
  }


  
  return(better_colors[[index]])
}

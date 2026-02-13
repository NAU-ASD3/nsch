parse_do <- function(year.do.path){
  if(!file.exists(year.do.path)){
    stop("year.do.path should be the path to a Stata do file, but this file does not exist: ", year.do.path)
  }
  do_patterns <- list(
    var=list(),
    define=list("_lab +", value=".*?"))
  do_list <- list()
  for(data_type in names(do_patterns)){
    do_list[[data_type]] <- nc::capture_all_str(
      year.do.path,
      "label ",
      data_type,
      " ",
      variable=".*?",
      do_patterns[[data_type]],
      ' +"',
      desc=".*?",
      '"')
  }
  do_list
}


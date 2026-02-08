do_patterns <- list(
  var=list(),
  define=list("_lab +", value=".*?"))
parse_do <- function(year.do){
  do_list <- list()
  for(data_type in names(do_patterns)){
    do_list[[data_type]] <- nc::capture_all_str(
      year.do,
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


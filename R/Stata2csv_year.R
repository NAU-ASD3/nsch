fwrite_list <- function(data_list, year_dir, verbose=FALSE){
  size_dt_list <- list()
  for(data_type in names(data_list)){
    type_dt <- data_list[[data_type]]
    out.csv <- file.path(
      year_dir,
      sprintf("%s.csv", data_type))
    if(verbose)message(sprintf(
      "writing %s %d×%d\n",
      out.csv, nrow(type_dt), ncol(type_dt)))
    data.table::fwrite(type_dt, out.csv)
    size_dt_list[[data_type]] <- data.table(
      out.csv,
      data_type,
      rows=nrow(type_dt),
      cols=ncol(type_dt))
  }
  rbindlist(size_dt_list)
}

Stata2csv_year <- function(year, Stata.path, csv.path, verbose=FALSE){
  file_list <- list(
    "nsch_%d_topical.do"=parse_do,
    "nsch_%de_topical.dta"=function(f)
      list(surveys=haven::read_stata(f)))
  year_dir <- file.path(csv.path, year)
  if(verbose)message(sprintf("converting %s to %s\n", Stata.path, year_dir))
  dir.create(year_dir, showWarnings=FALSE, recursive=TRUE)
  size_dt_list <- list()
  for(fmt in names(file_list)){
    read_fun <- file_list[[fmt]]
    in_file <- file.path(
      Stata.path,
      sprintf(fmt, year))
    if(verbose)message(sprintf("reading %s\n", in_file))
    data_list <- read_fun(in_file)
    fmt_sizes <- fwrite_list(data_list, year_dir, verbose)
    size_dt_list[[fmt]] <- data.table(
      in_file, fmt_sizes)
  }
  rbindlist(size_dt_list)
}

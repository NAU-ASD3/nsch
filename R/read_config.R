read_config <- function(config.path){
  if(!file.exists(config.path)){
    stop(
      "config.path should be the path to a JSON config file, ",
      "but this file does not exist: ", config.path)
  }
  ## RJSONIO::fromJSON signals an error for malformed JSON, but the
  ## message may be obscure.  Wrap in tryCatch so we can provide a
  ## friendlier prefix.
  config <- tryCatch(
    RJSONIO::fromJSON(config.path),
    error = function(e){
      stop(
        "config.path should contain valid JSON, ",
        "but parsing failed: ", conditionMessage(e))
    })
  config
}
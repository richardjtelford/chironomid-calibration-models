insist <- function(., test){
  if(!eval(substitute(test), envir = parent.frame())){
    stop(deparse(substitute(test)), " is not TRUE: \n. =  ", .)
  } 
  return(.)
}


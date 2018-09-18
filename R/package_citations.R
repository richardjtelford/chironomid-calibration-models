#append package citations to copy of main bibliography

package_citations <- function(packages, old_bib, new_bib){
  
  #copy original bib file
  fs::file_copy(old_bib, new_bib, overwrite = TRUE)
  
  #R citation
  Rcite <- citation()
  Rcite$key = "R"
  bibtex::write.bib(Rcite, new_bib, append = TRUE)
  
  #package citation
  bibtex::write.bib(packages, new_bib, append = TRUE)
}  
  
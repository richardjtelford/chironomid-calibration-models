#import package
library("drake")
library("tidyverse")
library("readr")
library("gridExtra")
library("broom")

#import scripts
source("R/performance_plots.R")
source("R/package_citations.R")
source("R/insist.R")


#construct drake plan
analyses <- drake_plan(
  
  #import & clean data
  chiron = read_csv(file_in("data/chironomidCalibration.csv")), 
  chiron_clean = clean_chiron(chiron), 
  chiron_air = filter(chiron_clean, AirWater != "water"),
  
  #make plots
  plot_calibrationTarget = calibrationTarget_plot(chiron_clean),
  plot_base = base_plot(chiron_air),
  plot_performance_vs_range = performance_vs_range_plot(plot_base),
  
  
  #get bibliography
  biblio = download.file("https://raw.githubusercontent.com/richardjtelford/Zabinskie/master/chironomid.bib", destfile = file_out("Rmd/extra/chironomid.bib")),
  
  #add extra packages to bibliography
  biblio2 = package_citations(
    packages = c("vegan", "rioja", "analogue", "palaeoSig"), 
    old_bib = file_in("Rmd/extra/chironomid.bib"), 
    new_bib = file_out("Rmd/extra/chironomid2.bib")),
  
  #knit manuscript
  manuscript = rmarkdown::render(input = knitr_in("Rmd/chironomidCalibration_MS.Rmd"), output_dir = "./output", output_file = file_out("output/chironomidCalibration_MS.pdf")),
  
  strings_in_dots = "literals"
)

#configure and make drake plan
config <- drake_config(analyses)
outdated(config)        # Which targets need to be (re)built?
make(analyses)          # Build the right things.

#voew dependency graph
vis_drake_graph(config, targets_only = TRUE)

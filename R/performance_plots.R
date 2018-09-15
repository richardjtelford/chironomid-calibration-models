

clean_chiron <- function(chiron){
  chiron %>% 
    select(-`Altitudinal gradient (m)`) %>% 
    mutate(year = as.numeric(gsub(".*(\\d{4}).*", "\\1", Study))) %>%
    mutate(minT = as.numeric(gsub("^(.*)–.*$", "\\1", `Tgradient (°C)`))) %>%
    mutate(maxT = as.numeric(gsub("^.*–(.*)$", "\\1", `Tgradient (°C)`))) %>%
    mutate(midT = (minT + maxT)/2) %>%
    mutate(Notes = ifelse(is.na(Notes), "", Notes)) %>%
    mutate(AirWater = factor(AirWater, levels = c("air", "air/time", "water")))
}

format_p <- function(p) {
  ifelse(p < 0.001, "< 0.001", paste("=", signif(p, 2)))
}



calibrationTarget_plot <- function(chiron){
  ggplot(chiron, aes(x = AirWater, y = `RMSEP (°C)`, fill = AirWater)) +
    geom_boxplot() +
    geom_jitter(height = 0, width = 0.4) +
    xlab("Calibration target")
}
  
  # ```{r}
  # mod <- lm(`RMSEP (°C)` ~ `Range of gradient (°C)`, data = chiron, subset = AirWater == "air")
  # gmod <- glance(mod)
  # 
  # rmod <- lm(r2jack ~ `Range of gradient (°C)`, data = chiron, subset = AirWater == "air")
  # grmod <- glance(rmod)
  # 
  # mod2 <- update(mod, . ~ . + I(`Range of gradient (°C)`^2))
  # #anova(mod, mod2)
  # 
  # ```

base_plot <- function(x){
  g1 <- ggplot(x, aes(x = `Range of gradient (°C)`, y = `RMSEP (°C)`, colour = AirWater)) +
  geom_point(show.legend = FALSE) +
  geom_smooth(data = filter(x, AirWater == "air"), method = "lm", formula = y ~ x, show.legend = FALSE)
}


performance_vs_range_plot <- function(base_plot){
  g2 <- base_plot + aes(x = `Range of gradient (°C)`, y = r2jack)

  grid.arrange(base_plot, g2, ncol = 2)
}

  # ```{r lakeDensity, fig.cap="Figure 3. Density of lakes as a function of temperature range."}
  # g1 + aes(x = `Range of gradient (°C)`, y = No_lakes/`Range of gradient (°C)`)
  # mod_a <-  lm(I(No_lakes/`Range of gradient (°C)`) ~ `Range of gradient (°C)`, data = chiron, subset = No_lakes < 400) 
  # gmod_a <- glance(mod_a)
  # ```
  # 
  # 
  # ```{r lakedensity}
  # mod_den <-  lm(`RMSEP (°C)` ~ I(No_lakes/`Range of gradient (°C)`), data = chiron, subset = No_lakes < 400) 
  # gmod_den <- glance(mod_den)
  # 
  # mod_no450 <-  lm(`RMSEP (°C)` ~ `Range of gradient (°C)`, data = chiron, subset = No_lakes < 400) 
  # gmod_no450 <- glance(mod_no450)
  # 
  # mod_den_r <-  lm(`RMSEP (°C)` ~ I(No_lakes/`Range of gradient (°C)`) + `Range of gradient (°C)`, data = chiron, subset = No_lakes < 400) 
  # gmod_den_r <- glance(mod_den_r)
  # ```
  # 
  # 
  # ```{r NoLakeRMSEP, fig.cap = "Figure 4. RMSEP against the number of lakes in each calibration set, omitting the anomalously large calibration set."}
  # g1  %+% filter(chiron, No_lakes < 400) + 
  #   aes(x = No_lakes,  y = `RMSEP (°C)`) + 
  #   geom_vline(xintercept = c(40, 70)) + 
  #   xlab("Number of lakes")
  # 
  # mod_nlakes <- lm(`RMSEP (°C)` ~ No_lakes, data = chiron, subset = No_lakes < 400)
  # mod_nlakes2 <- update(mod_nlakes, . ~ . + `Range of gradient (°C)`)
  # ```
  # 
  # 
  # ```{r taxonResolution, fig.cap="Figure 5. RMSEP against year of publication"}
  # g1 + aes(x = year, y = `RMSEP (°C)`)
  # 
  # mod_tx <- update(mod, . ~ . + year, data = chiron)
  # #summary(mod_tx)
  # ```
  # 
  # 
  # 
  # ```{r midpoint, fig.cap="Figure 6. RMSEP against mid-point temperature and mid-point temperature against temperature range"}
  # g3 <- g1 + aes(x = midT, y = `RMSEP (°C)`) + xlab("Mid-point temperature (°C)")
  # 
  # g4 <- g1 + aes(x = `Range of gradient (°C)`, y = midT) + ylab("Mid-point temperature (°C)")
  # grid.arrange(g3, g4, ncol = 2)
  # 
  # mod_mp <- update(mod, . ~ . + midT, data = chiron)
  # #summary(mod_mp)
  # ```
  # 
  # 
  # ```{r, eval = FALSE}
  # g1 + aes(x = `RMSEP as % of gradient`, y = r2jack) 
  # ```
  # 
  # ```{r}
  # table1 <- chiron %>% 
  #   select(-(year:midT)) %>%
  #   rename(`No lakes` = No_lakes, 
  #          `No taxa` = No_taxa, 
  #          `Gradient (°C)` = `Tgradient (°C)`, 
  #          `Range (°C)` = `Range of gradient (°C)`, 
  #          Model = `Best model`, 
  #          `RMSEP %` = `RMSEP as % of gradient`,
  #          Temperature = Parameter) %>% 
  #   mutate(
  #     Temperature = gsub("air", "", Temperature), 
  #     Temperature = gsub(" ?T", "", Temperature),
  #     Temperature = gsub("[Mm]ean|of the", "", Temperature),
  #     Temperature = stringi::stri_trim(Temperature),
  #     r2jack = if_else(Notes == "Bootstrap", paste0(r2jack, "*"), as.character(r2jack))
  #   ) %>% 
  #   select(-Notes)
  # 
  # 
  # table1 %>% 
  #   filter(AirWater == "water") %>% 
  #   select(-AirWater) %>% 
  #   pander::pander(caption = "Models calibrated against water temperature", split.cells = 25, split.tables = 180, digits = 2)
  # 
  # table1 %>% 
  #   filter(AirWater == "air/time") %>% 
  #   select(-AirWater, -`No lakes`) %>% 
  #   pander::pander(caption = "Calibration in time models ", split.cells = 25, split.tables = 190, digits = 2)
  # 
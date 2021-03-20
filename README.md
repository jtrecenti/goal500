
<!-- README.md is generated from README.Rmd. Please edit that file -->

# goal500

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/jtrecenti/goal500/workflows/R-CMD-check/badge.svg)](https://github.com/jtrecenti/goal500/actions)
<!-- badges: end -->

Esse repositório mostra os gols dos principais artilheiros ainda ativos,
com base nas estatísticas disponíveis no Wikipédia.

## Installation

``` r
if (!requireNamespace("goal500", quietly = TRUE))
  remotes::install_github("jtrecenti/goal500")
```

## Gráfico

``` r
library(ggplot2)
library(gganimate)
library(goal500)

da <- get_player_stats()

da_plot <- da %>% 
  dplyr::filter(!is.na(total)) %>% 
  dplyr::mutate(year = as.numeric(year)) %>% 
  dplyr::group_by(name, year) %>% 
  dplyr::summarise(total = sum(total), .groups = "drop_last") %>% 
  dplyr::arrange(year) %>% 
  dplyr::mutate(total_cumsum = cumsum(total)) %>% 
  dplyr::group_by(name) %>% 
  dplyr::mutate(total_player = sum(total), year = year - min(year)) %>% 
  dplyr::ungroup() %>% 
  dplyr::mutate(
    name = stringr::str_glue("{name} ({total_player})"),
    name = forcats::fct_reorder(name, total_player)
  )

gg <- da_plot %>% 
  ggplot(aes(x = year, y = total_cumsum, colour = name)) +
  geom_point(size = .8) +
  geom_line(size = .9) +
  geom_text(
    aes(label = name),
    data = da_plot %>% 
      dplyr::arrange(dplyr::desc(year)) %>% 
      dplyr::distinct(name, .keep_all = TRUE)
  ) +
  scale_colour_viridis_d(end = .9) +
  scale_x_continuous(breaks = 0:20 * 2) +
  scale_y_continuous(breaks = 0:10 * 100) +
  theme_minimal(14) +
  guides(colour = guide_legend(reverse = TRUE)) +
  labs(
    x = "Years active", 
    y = "Goals",
    colour = "Name",
    title = "Cumulative goals",
    subtitle = "Active players with most goals",
    caption = "Source: Wikipedia"
  ) +
  transition_reveal(year) +
  enter_grow()

# https://github.com/thomasp85/gganimate/issues/431#issuecomment-803363466
if (!requireNamespace("gifski", quietly = TRUE))
  install.packages('gifski', repos = 'https://cran.microsoft.com/snapshot/2021-02-28')

animate(
  gg, 
  nframe = 26,
  fps = 2,
  end_pause = 5,
  width = 1000, 
  height = 600
)
#> Rendering [=======>------------------------------------------------------------------------] at 4.5 fps ~ eta:  4sRendering [==========>---------------------------------------------------------------------] at 4.4 fps ~ eta:  4sRendering [==============>-----------------------------------------------------------------] at 4.3 fps ~ eta:  4sRendering [==================>-------------------------------------------------------------] at 4.2 fps ~ eta:  4sRendering [======================>---------------------------------------------------------] at 4.2 fps ~ eta:  4sRendering [==========================>-----------------------------------------------------] at 4.2 fps ~ eta:  3sRendering [=============================>--------------------------------------------------] at 4.2 fps ~ eta:  3sRendering [=================================>----------------------------------------------] at 4.2 fps ~ eta:  3sRendering [=====================================>------------------------------------------] at 4.2 fps ~ eta:  3sRendering [=========================================>--------------------------------------] at 4.1 fps ~ eta:  2sRendering [=============================================>----------------------------------] at 4.1 fps ~ eta:  2sRendering [=================================================>------------------------------] at 4.1 fps ~ eta:  2sRendering [======================================================>---------------------------] at 4 fps ~ eta:  2sRendering [==========================================================>-----------------------] at 4 fps ~ eta:  1sRendering [=============================================================>--------------------] at 4 fps ~ eta:  1sRendering [=================================================================>----------------] at 4 fps ~ eta:  1sRendering [====================================================================>-----------] at 4.1 fps ~ eta:  1sRendering [=======================================================================>--------] at 4.1 fps ~ eta:  0sRendering [===========================================================================>----] at 4.1 fps ~ eta:  0sRendering [================================================================================] at 4.1 fps ~ eta:  0s                                                                                                                  
#> Frame 1 (3%)Frame 2 (7%)Frame 3 (11%)Frame 4 (15%)Frame 5 (19%)Frame 6 (23%)Frame 7 (26%)Frame 8 (30%)Frame 9 (34%)Frame 10 (38%)Frame 11 (42%)Frame 12 (46%)Frame 13 (50%)Frame 14 (53%)Frame 15 (57%)Frame 16 (61%)Frame 17 (65%)Frame 18 (69%)Frame 19 (73%)Frame 20 (76%)Frame 21 (80%)Frame 22 (84%)Frame 23 (88%)Frame 24 (92%)Frame 25 (96%)Frame 26 (100%)
#> Finalizing encoding... done!
```

<img src="man/figures/README-gganimate-1.gif" width="100%" />

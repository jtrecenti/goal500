
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

No passado, o site do Wiki mostrava os jogadores ativos. Agora não
mostra mais. Então eu fiz a lista manualmente, mas com apenas 3
jogadores\!

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

da_plot %>% 
  dplyr::distinct(name, total_player) %>% 
  knitr::kable()
```

| name                    | total\_player |
| :---------------------- | ------------: |
| Cristiano Ronaldo (821) |           821 |
| Lionel Messi (786)      |           786 |
| Lewandowski (600)       |           600 |
| Neymar Jr (401)         |           401 |

``` r
gg <- da_plot %>% 
  ggplot2::ggplot(ggplot2::aes(x = year, y = total_cumsum, colour = name)) +
  ggplot2::geom_point(size = .8) +
  ggplot2::geom_line(size = .9) +
  ggplot2::geom_text(
    ggplot2::aes(label = name),
    data = da_plot %>% 
      dplyr::arrange(dplyr::desc(year)) %>% 
      dplyr::distinct(name, .keep_all = TRUE)
  ) +
  ggplot2::scale_colour_viridis_d(end = .9) +
  ggplot2::scale_x_continuous(breaks = 0:20 * 2) +
  ggplot2::scale_y_continuous(breaks = 0:10 * 100) +
  ggplot2::theme_minimal(14) +
  ggplot2::guides(colour = ggplot2::guide_legend(reverse = TRUE)) +
  ggplot2::labs(
    x = "Years active", 
    y = "Goals",
    colour = "Name",
    title = "Cumulative goals",
    subtitle = "Active players with most goals",
    caption = "Source: Wikipedia"
  ) +
  gganimate::transition_reveal(year) +
  gganimate::enter_grow()

gganimate::animate(
  gg, 
  nframe = 26,
  fps = 2,
  end_pause = 5,
  width = 1000, 
  height = 600
)
```

<img src="man/figures/README-gganimate-1.gif" width="100%" />

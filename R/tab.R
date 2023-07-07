#' Tabela
#'
#' Pega a tabela de gols dos jogadores
#'
#' @param year_start filtrar numero de linhas
#'
#' @export
g500_tab <- function(year_start = "1950") {
  wiki_url("/wiki/List_of_footballers_with_500_or_more_goals") %>%
    httr::GET() %>%
    xml2::read_html() %>%
    xml2::xml_find_first("//*[./span[@id='Ranking']]//following-sibling::table") %>%
    rvest::html_table() %>%
    dplyr::rename_with(~stringr::str_to_lower(stringr::str_replace(.x, ' ', "_"))) %>%
    dplyr::filter(stringr::str_extract(years, "^[0-9]{4}") >= year_start) %>%
    tibble::as_tibble()
}

wiki_url <- function(u) {
  paste0("https://en.wikipedia.org", u)
}

get_active_players <- function() {
  a <- wiki_url("/wiki/List_of_footballers_with_500_or_more_goals") %>%
    httr::GET() %>%
    xml2::read_html() %>%
    xml2::xml_find_all(stringr::str_glue(
      "//h2[span/@id='Active_players']/following-sibling::table",
      "/tbody/tr/th/parent::tr/td[1]/b//a"
    ))

  u <- a %>%
    xml2::xml_attr("href") %>%
    wiki_url()
  nm <- a %>%
    xml2::xml_text() %>%
    stringr::str_squish()

  tibble::tibble(
    name = nm, link = u
  )

  tibble::tibble(
    name = c(
      "Neymar Jr",
      "Lionel Messi",
      "Cristiano Ronaldo",
      "Lewandowski",
      "Haaland"
    ),
    link = c(
      "https://en.wikipedia.org/wiki/Neymar",
      "https://en.wikipedia.org/wiki/Lionel_Messi",
      "https://en.wikipedia.org/wiki/Cristiano_Ronaldo",
      "https://en.wikipedia.org/wiki/Robert_Lewandowski",
      "https://en.wikipedia.org/wiki/Erling_Haaland"
    )
  )

}

gols_ano_jogador <- function(u) {
  # message(u)

  h <- httr::GET(u) %>%
    xml2::read_html()

  club <- h %>%
    xml2::xml_find_first("//*[@id='Club']/parent::h3/following-sibling::table") %>%
    rvest::html_table(fill = TRUE) %>%
    janitor::clean_names() %>%
    dplyr::filter(stringr::str_detect(season, "[0-9]{4}")) %>%
    dplyr::transmute(
      year = stringr::str_extract(season, "[0-9]{4}"),
      total = as.numeric(total_2)
    ) %>%
    dplyr::group_by(year) %>%
    dplyr::summarise(total = sum(total))

  international <- h %>%
    xml2::xml_find_all("//*[@id='International']/parent::h3/following-sibling::table[@class='wikitable']") %>%
    rvest::html_table(fill = TRUE) %>%
    purrr::map_dfr(janitor::clean_names) %>%
    dplyr::filter(stringr::str_detect(year, "[0-9]{4}")) %>%
    dplyr::rename_with(function(x) {
      dplyr::case_when(
        x == "goals" ~ "goals",
        x == "total_2" ~ "goals",
        TRUE ~ x
      )
    }) %>%
    dplyr::transmute(
      year = year,
      total = as.numeric(goals)
    ) %>%
    dplyr::group_by(year) %>%
    dplyr::summarise(total = sum(total))

  dplyr::bind_rows(list(club = club, international = international), .id = "type")

}

#' Get all player stats
#'
#' @export
get_player_stats <- function() {
  get_active_players() %>%
    dplyr::filter(!stringr::str_detect(name, " Abreu$")) %>%
    dplyr::mutate(res = purrr::map(link, gols_ano_jogador)) %>%
    tidyr::unnest(res)
}

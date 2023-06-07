library(tidyverse)
library(rvest)
library(here)
library(fs)

fte <- read_html("https://projects.fivethirtyeight.com/soccer-predictions/nwsl/")

logos <- dir_ls(here("materials", "slides", "figure", "images", "nwsl")) |> 
  as_tibble() |> 
  mutate(team = path_file(value),
         team = path_ext_remove(team),
         path = str_replace(value, "^.*slides/", "")) |> 
  select(path, team)

html_table(fte) |>
  pluck(1) |> 
  janitor::clean_names() |> 
  select(team = x, spi = team_rating, off = team_rating_2, def = team_rating_3) |> 
  slice(-(1:2)) |> 
  mutate(team = str_replace_all(team, "[0-9].*$", ""),
         across(-team, as.double)) |> 
  mutate(match_team = str_replace_all(str_to_lower(team), " ", "-"),
         match_team = str_remove(match_team, "/")) |> 
  left_join(logos, join_by(match_team == team)) |> 
  select(team, logo = path, spi, off, def) |> 
  write_rds("data/nwsl.rds")

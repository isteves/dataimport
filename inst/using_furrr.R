library(furrr)
library(tidyverse)
library(tictoc)
library(dataimport)

# sequential
plan(sequential)
tic()
meta_full <- tibble(meta_pid = c("doi:10.18739/A22Z9V", 
                                 "doi:10.18739/A2ZG5K")) %>% 
  mutate(eml = future_map(meta_pid, get_object)) %>% 
  mutate(eml_df = future_map(eml, tidy_eml))
toc() #101.819 sec elapsed for 2 EML's, 23.521 on datateam

# multiprocess
plan(multiprocess)
tic()
meta_fullx <- tibble(meta_pid = c("doi:10.18739/A22Z9V", 
                                  "doi:10.18739/A2ZG5K")) %>% 
  mutate(eml = future_map(meta_pid, get_object)) %>% 
  mutate(eml_df = future_map(eml, tidy_eml))
toc() #12.248 seconds

# multiprocess with as = "raw" (to skip read_eml and write_eml)
plan(multiprocess)
tic()
meta_fullx <- tibble(meta_pid = c("doi:10.18739/A22Z9V", 
                                  "doi:10.18739/A2ZG5K")) %>% 
  mutate(eml = furrr::future_map(meta_pid, get_object, as = "raw")) %>% 
  mutate(eml_df = furrr::future_map(eml, tidy_eml))
toc() #7.64, 5.604

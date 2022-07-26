## Script to help convert scholar profile to md folders


library(scholar)
library(tidyverse)

prof <- scholar::get_profile("K6EVDoYAAAAJ")
publications <- scholar::get_publications("K6EVDoYAAAAJ")

pubs <- publications %>% filter(year > 2019)


pub <- pubs[1,]

scholar::get_complete_authors(id= "K6EVDoYAAAAJ", pubid = pub$pubid)

scholar::

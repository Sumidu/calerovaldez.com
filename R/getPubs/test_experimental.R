

for (i in 1:nrow(pubs)) {
  pub <- pubs[i,]
  diffmatrix <- utils::adist(str_to_lower(pub$title), str_to_lower(cross_ref_data$title))
  idx <-  diffmatrix %>% which.min()
  diff <- diffmatrix %>% min()
  cross_ref_data$title[idx]
  if (diff > 0 & diff < 10) {
    logging::loginfo("**************************************")
    logging::loginfo(paste("Distance ", diff))
    logging::loginfo(paste("Found ", cross_ref_data$title[idx]))
    logging::loginfo(paste("Original", pub$title))
  }
}

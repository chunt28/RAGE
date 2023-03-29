######################################

#   reads the processed data from the downloaded csv file and saves it in rds format in the cache.
#   Separate the patient characteristics and the expression data into different data frames linked by a shared id. 
#   Save them in rds format in the cache

# -----------------------------------

library(tidyverse)
library(fs)

# -----------------------------------
#   Data Folder 

cache   <-  "C:/Users/ch553/OneDrive - University of Leicester/project/RAGE/data/cache"
raw_data   <-  "C:/Users/ch553/OneDrive - University of Leicester/project/RAGE/data/rawData"


# -----------------------------------
#   Dependencies - input file

serRDS <- path(raw_data, "GSE210271_series_matrix.txt.gz")
patRDS <- path(cache,   "patients.rds")


# --------------------------------------------------
# Read the file as lines of text for exploration
#
lines <- readLines(serRDS )
substr(lines[1:15], 1, 30)


# --------------------------------------------------
# Making a list of patient IDs using row 14 of the data frame 
#

read.table(serRDS,  
           sep    = '\t', 
           header = FALSE, 
           skip   = 13, ## skipping the first 13 rows
           nrows  = 1) %>% # taking the first row (so row 14 )
  { strsplit(.$V2, " ")[[1]] } -> patientId



# --------------------------------------------------
# patient characteristics based on IDs
#

read.table(serRDS,  
           sep    = '\t', 
           header = FALSE, 
           skip   = 41, 
           nrows  = 5) %>%
  as_tibble() %>%
  select(-1) %>%
  mutate(across(everything(), ~ str_replace(., "Sex: ", ""))) %>%
  mutate(across(everything(), ~ str_replace(., "age: ", ""))) %>%
  mutate(across(everything(), ~ str_replace(., "smoking status: ", ""))) %>%
  mutate(across(everything(), ~ str_replace(., "fev1 % predicted: ", ""))) %>%
  mutate(across(everything(), ~ str_replace(., "cancer status: ", ""))) %>%  ## removing 
  mutate(var = c("sex", "age", "smoking", "fev1", "diagnosis")) %>% # coding them 
  pivot_longer(-var, names_to = "col", values_to = "data") %>%
  pivot_wider(names_from = var, values_from = data) %>%
  mutate(id = patientId ) %>%
  mutate(study = c(rep("AEGIS1", 375), rep("AEGIS2", 130))) %>%
  select(id, study, sex, age, smoking, diagnosis) %>%
  mutate(age = as.numeric(age)) %>%
  saveRDS(patRDS) 





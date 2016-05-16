library(rvest)
library(xml2)
library(dplyr)
library(gtools)
library(openxlsx)

library(xml2)

# read html content
webpage <- read_html("http://globalbigdataconference.com/64/dallas/big-data-bootcamp/schedule.html")

# extract all tables
tbls <- html_nodes(webpage, "table")

# inspect tables
head(tbls)

# fetch only 1, 3, 4 tables since 2nd and 5th are not useful
tbls_list <- tbls %>% .[c(1,3,4)] %>% html_table(fill=TRUE)

# structure of returned object
str(tbls_list)

# set up column names for each of the data frames representing tables
colnames(tbls_list[[1]]) <- c("time-slot", "session-info")
colnames(tbls_list[[2]]) <- c("time-slot", "session-info")
colnames(tbls_list[[3]]) <- c("time-slot", "session-info")

# smartly append three tables
agenda <- smartbind(tbls_list[[1]],tbls_list[[2]], tbls_list[[3]])

# inspect structure again
str(agenda)

# there is a row with NA, the following command shows how to filter complete rows
agenda <- agenda[complete.cases(agenda),]

# replace outputXLS 
# Example: outputXLS <- "/Users/akuntamu/test/agenda.xls"

# outputXLS <- "/Users/akuntamu/test/agenda.xls"

outputXLS <- "ReplaceWithFileNameIncludingPath"


# write it out
write.xlsx(agenda, outputXLS)
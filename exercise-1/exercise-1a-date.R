library(lubridate)  
library(dplyr)
library(tidyr)

# Replace this with file name where you want to download the raw file
rawfile <- "ReplaceWithFileNameIncludingPath"
# download the file containing dates 
download.file("https://docs.google.com/uc?authuser=0&id=0B6UoSlNMfxQOQ09oSjVMc3kwajQ&export=download", destfile = rawfile)

# read the file, since the file does not contain a header, it is false
dates <- read.csv(rawfile, header = FALSE, col.names = c("date"))

# there should be 22
length(dates$date)

# use mutate to transform content from dates, ignore the warnings. 
# the intelligence is embedded in useful functions in lubridate package
# create three separate columns based on date formats and then merge them all 
# into one column 
fixed <- mutate(dates, yyyymmdd = ymd(date), mmddyyyy = mdy(date), ddmmyyyy = dmy(date)) %>% unite("fixedup", yyyymmdd, ddmmyyyy, mmddyyyy, sep ="")
  
# replace NAs with blank strings
fixed$fixedup <- gsub("NA","", fixed$fixedup)


# identify those dates where month and day are both less than equal to 12
fixed %>% mutate(fixedup, month = month(fixedup), day = day(fixedup), to_be_reviewed = day(fixedup) <= 12 & month(fixedup) <= 12)

# load stringr package as we will be using one of the functions from it
library(stringr)

# Extension exercise: add three different dates

# read the file, since the file does not contain a header, it is false
dates <- read.csv(rawfile, header = FALSE, stringsAsFactors = FALSE, col.names = c("date"))

# there should be 22
length(dates$date)

# adding three more dates
dates[nrow(dates)+1,] <- c("01/02/2013")
dates[nrow(dates)+1,] <- c("12021010")
dates[nrow(dates)+1,] <- c("20021010")

# three turn in valid responses for more than one of yyyymmdd, ddmmyyyy, mmddyyyy!
# should be reviewed by someone who has domain knowledge about this data and 
# hence we need to flag such data accordingly


# use mutate to transform content from dates, ignore the warnings. 
fixed <- mutate(dates, yyyymmdd = ymd(date), mmddyyyy = mdy(date), ddmmyyyy = dmy(date))

# add a new column to know if a certain date observation has to be reviewed
fixed %>% mutate(to_be_reviewed = ifelse((!is.na(fixed$yyyymmdd)) + (!is.na(fixed$mmddyyyy))  + (!is.na(fixed$ddmmyyyy)) == 1, FALSE, TRUE))

#view contents
fixed

# extension to above, here we find those which seem to be valid and convert them 

fixed_md_dm <- fixed %>% mutate(to_be_reviewed = ifelse((!is.na(fixed$yyyymmdd)) + (!is.na(fixed$mmddyyyy))  + (!is.na(fixed$ddmmyyyy)) == 1, FALSE, TRUE)) %>% filter(to_be_reviewed==FALSE) %>%unite("fixedup", yyyymmdd, ddmmyyyy, mmddyyyy, sep ="") %>% mutate(fixedup = str_replace_all(fixedup, "NA","")) %>% select(date, fixedup)

fixed_md_dm
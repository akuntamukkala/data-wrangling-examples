# if you have loaded plyr, there are conflict with dplyr. 
# hence detaching it
detach("package:plyr", unload=TRUE)

library(openxlsx)

# specify input and output file as shown below in comments
# rawfile <- "/Users/akuntamu/temp/log.txt"
# outputFile <- "/Users/akuntamu/temp/text.xls"

#rawfile <- "ReplaceWithFileNameIncludingPath"
#outputFile <- "ReplaceWithFileNameIncludingPath"


# download log file from log file
download.file("https://docs.google.com/uc?authuser=0&id=0B6UoSlNMfxQOQWlGQzdvbzhNRG8&export=download", rawfile)

# read log file, each line is a row
logs <- readLines(rawfile)


# read 311 lines
length(logs)

# vector of characters
class(logs)

# convert into a data frame
logsdf <- as.data.frame(logs, stringsAsFactors = FALSE)

# find structure of the data frame
str(logsdf)

# add a new column with line number
logsdf$ID <- seq.int(nrow(logsdf))

# peek at first 6 lines 
head(logsdf)

# look at the class of columns of data frame
sapply(logsdf, class)

# function hacked to group exception lines together 
# feel silly hacking such a contrived function...bear with me here
groupLogs <- function(ID) {
  log_group <- c()
  i <- 1
  while (i <= length(ID)) {
    log_group[i] = ID[i]
    j <- i+1
    while(j <=length(ID)) {
      if(ID[j] - ID[j-1] == 1) {
        log_group[j] <- ID[i]
      } else {
        log_group[j] <- ID[j]
        i <- j
        break
      }
      j <- j+1
      if(j > length(ID))
        i <- j
    }
  }
  log_group
}

# find lines in log file that represent exceptions 
exception_logs <- logsdf[str_detect(logsdf$logs, "^[^\\d]"),]

# invoke function to group together exception lines part of the same stack trace
exception_logs$log_grp <- groupLogs(exception_logs$ID)

# group all the lines in the same exception into a single collapsed row separated # by carriage return
exception_logs <- exception_logs %>% select(logs, log_grp) %>% group_by(log_grp) %>% summarise(stacktrace = paste(logs, collapse = "\r"))


# little math trick to help merge the exception into a the log line previous to
# this exception
exception_logs$log_grp <- ifelse(exception_logs$log_grp == 1, 
                                 exception_logs$log_grp, exception_logs$log_grp - 1)

# log lines that begin with timestamp
proper_logs <- logsdf[str_detect(logsdf$logs, "^[\\d]"),]


# split the log message as a separate column using " - " separator 
proper_logs <- proper_logs %>% separate(logs, c("logs", "message" ), sep = "\\s-\\s") 

# split the log text into time, thread, level and class
proper_logs <- proper_logs %>% separate(logs, c("time", "thread", "level", "class" ), sep = "\\s+")


# left outer join to include exceptions by joining the two data frames created
# earlier
logs <- merge(proper_logs, exception_logs, by.x = c("ID"), by.y = c("log_grp"), all.x = TRUE)

# write the excel file, example /Users/akuntamu/temp/text.xls
write.xlsx(logs, outputFile)


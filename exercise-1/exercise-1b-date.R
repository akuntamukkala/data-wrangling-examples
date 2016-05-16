# read the file, since the file does not contain a header, it is false
dates <- read.csv(rawfile, header = FALSE, col.names = c("date"))

# there should be 22
length(dates$date)


#Define function
fixdates <- function(date) {
    # empty vector
    fixed <- c()
    # iterate over the vector containing raw dates
    for(i in 1:length(date)) {
        # is it yyyymmdd?
        if(is.na(ymd(date[i]))) {
            # is it mmddyyyy
            if(is.na(mdy(date[i]))) {
                # is it ddmmyyyy
                if(is.na(dmy(date[i]))) {
                    # none, then undertermined
                    fixed[i] <- NA
                } else {
                    # assign ddmmyyyy
                    fixed[i] <- dmy(date[i])
                }
            } else {
                # assign mmddyyyy
                fixed[i] <- mdy(date[i])
            }
        } else {
            # assign yyyymmdd
            fixed[i] <- ymd(date[i])
        }
    }
    # convert to date
    class(fixed) <- "Date"
    # return vector containing converted dates
    fixed
}

# invoke function to convert raw dates
dates$FixedDate <- fixdates(dates$date)

# view contents
dates

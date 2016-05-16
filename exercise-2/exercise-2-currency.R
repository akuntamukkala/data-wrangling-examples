# Replace this with file name where you want to download the raw file
rawfile <- "/Users/akuntamu/test/currency.txt"

# download sales file
download.file("https://docs.google.com/uc?authuser=0&id=0B6UoSlNMfxQONW01LXpUWTdmdXM&export=download", rawfile)

# read the file
sales <- read.csv(rawfile, stringsAsFactors = FALSE, header = T, sep = "\n")

# There is a lot going on here. 
# Create a separate column extracting the currency symbol
# Create another column containing numeric content by replacing comma, $ and £
# Convert to numeric values
# Normalize to USD by converting £ to USD using 1.44 conversion ratio

sales %>% mutate(currency = str_extract(sales,"\\$|£") ) %>% mutate(raw_amount = str_replace_all(sales, ",|\\$|£", "") ) %>% mutate(amount = as.numeric(raw_amount)) %>%mutate(convertedAmountInUSD = ifelse(currency == '$', amount, ifelse(currency == '£', round(amount*1.44,2), NA)))

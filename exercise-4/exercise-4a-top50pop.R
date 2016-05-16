library(rvest)
library(tidyr)
library(stringr)
library(gtools)


# Scrape the page listing top 50 pop hits in the last decade
scraping_top50_pop <- read_html("http://www.pastemagazine.com/blogs/lists/2009/11/the-best-albums-of-the-decade.html?a=1”)
                               
# If the above does not work, I have a cached copy of this page here.
scraping_top50_pop <- read_html("")

# Scraping using rvest page (which was inspired by BeautifulSoup, python library
top_50_pop <- html_nodes(scraping_top50_pop, ".big") %>% html_text %>% trimws(which ="both")

# split the rank and rest of the text
matrix_top_50_pop <- str_split_fixed(top_50_pop, "\\.", 2)

# supply column names
colnames(matrix_top_50_pop) <- c("rank", "text")

# convert to a data frame
top_50_pop_df <- as.data.frame(matrix_top_50_pop, stringsAsFactors = FALSE)

# convert rank from character to numeric
top_50_pop_df$rank <- as.numeric(top_50_pop_df$rank)

# split the artist based on : delimiter
top_50_pop_df <- top_50_pop_df %>% separate(col = text, into = c("artist", "text"), sep = ":")

# split lines that contains all three fields: title, company, year
top_50_pop_df1 <- top_50_pop_df[which(top_50_pop_df$text %>% str_detect("\\[.*\\]")),] %>% separate(col = text, into = c("title", "company", "year"), sep = "\\[|\\]")

# split lines that contain only title and year
top_50_pop_df2 <- top_50_pop_df[which(!top_50_pop_df$text %>% str_detect("\\[.*\\]")),] %>% separate(col = text, into = c("title",  "year"), sep = "\\s\\(")


# smartly combine the above data frames since company is not common column in both
top_50_pop_combined <- smartbind(top_50_pop_df1,top_50_pop_df2)

# edit the year field to trim and replace parantheses
top_50_pop_combined$year <- apply(top_50_pop_combined[,"year", drop = FALSE], 2, function(year) {
  str_replace_all(trimws(year, which = c("both")), "\\(|\\)", "")
}
)[,"year"]

# trim artist
top_50_pop_combined$artist <- trimws(top_50_pop_combined$artist, which = "both")

# trim title
top_50_pop_combined$title <- trimws(top_50_pop_combined$title, which = "both")

# sort the final data frame using rank in the descending order
top_50_pop_final <- arrange(top_50_pop_combined, -rank)

# print
top_50_pop_final

# export to a CSV 
write.table(top_50_pop_final, "/Users/akuntamu/test/top-50-pop.csv", row.names = FALSE, fileEncoding = "UTF-8", sep = "|")

### Data Analysis Process ###
# Import -> Tidy -> Transform
#                -> Visualise
#                -> Model -> Communicate

### Data Transformation ###
# http://r4ds.had.co.nz/transform.html

# Packages 
library(tidyverse)
library(nycflights13)

### nycflights13
flights
### dplyr basics
# Pick observations by their values (filter()).
# Reorder the rows (arrange()).
# Pick variables by their names (select()).
# Create new variables with functions of existing variables (mutate()).
# Collapse many values down to a single summary (summarise()).

### Filter rows with filter()
filter(flights, month == 1, day == 1, carrier == "UA")
# dplyr functions never modify their inputs
jan1 <- filter(flights, month == 1, day == 1)
# R either prints out the results, or saves them to a variable. If you want to do both, you can wrap the assignment in parentheses:
(dec25 <- filter(flights, month == 12, day == 25))


### Comparison
# There's another common problem you might encounter when using ==: floating point numbers. These results might surprise you!
sqrt(2) ^ 2 == 2
#> [1] FALSE
1 / 49 * 49 == 1
#> [1] FALSE

# Computers use finite precision arithmetic (they obviously can't store an infinite number of digits!) so remember that every number you see is an approximation. Instead of relying on ==, use near():
near(sqrt(2) ^ 2,  2)
#> [1] TRUE
near(1 / 49 * 49, 1)
#> [1] TRUE


### Logical operators
# The following code finds all flights that departed in November or December:
filter(flights, month == 11 | month == 12)
# Another way to use multiple matchings
filter(flights, month %in% c(11,12))
# Sometimes you can simplify complicated subsetting by remembering De Morgan's law: !(x & y) is the same as !x | !y, and !(x | y) is the same as !x & !y
filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120, dep_delay <= 120)


### Missing Values
NA == NA
# It's easiest to understand why this is true with a bit more context:
# Let x be Mary's age. We don't know how old she is.
x <- NA
# Let y be John's age. We don't know how old he is.
y <- NA
# Are John and Mary the same age?
x == y
#> [1] NA
# We don't know!

# If you want to determine if a value is missing, use is.na():
is.na(x)
#> [1] TRUE

# filter() only includes rows where the condition is TRUE; it excludes both FALSE and NA values. If you want to preserve missing values, ask for them explicitly:
df <- tibble(x = c(1, NA, 3))
filter(df, x > 1)
#> # A tibble: 1 x 1
#>       x
#>   <dbl>
#> 1     3
filter(df, is.na(x) | x > 1)
#> # A tibble: 2 x 1
#>       x
#>   <dbl>
#> 1    NA
#> 2     3

### Arrange rows with arrange()
arrange(flights, year, month, day)
# Use desc() to re-order by a column in descending order:
arrange(flights, desc(dep_delay))
# Missing values are always sorted at the end:


### Select columns with select()
select(flights, year, month, day)
select(flights, year:day)
select(flights, -(year:day))

# There are a number of helper functions you can use within select():
  # starts_with("abc"): matches names that begin with "abc".
  # ends_with("xyz"): matches names that end with "xyz".
  # contains("ijk"): matches names that contain "ijk".
  # matches("(.)\\1"): selects variables that match a regular expression. This one matches any variables that contain repeated characters. You'll learn more about regular expressions in strings.
  # num_range("x", 1:3): matches x1, x2 and x3.

# select() can be used to rename variables, but it's rarely useful because it drops all of the variables not explicitly mentioned. 
# Instead, use rename(), which is a variant of select() that keeps all the variables that aren't explicitly mentioned:
rename(flights, tail_num = tailnum)

# Another option is to use select() in conjunction with the everything() helper. This is useful if you have a handful of variables you'd like to move to the start of the data frame.
select(flights, time_hour, air_time, everything())


### Add new variables with mutate()
# mutate() always adds new columns at the end of your dataset so we'll start by creating a narrower dataset so we can see the new variables.
flights_sml <- select(flights, 
                      year:day, 
                      ends_with("delay"), 
                      distance, 
                      air_time)
mutate(flights_sml,
       gain = dep_delay - arr_delay,
       speed = distance / air_time * 60
)
# Note that you can refer to columns that you've just created:
mutate(flights_sml,
       gain = dep_delay - arr_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours)
# If you only want to keep the new variables, use transmute():
transmute(flights,
          gain = dep_delay - arr_delay,
          hours = air_time / 60,
          gain_per_hour = gain / hours)
# Useful creation functions
  # Arithmetic operators: +, -, *, /, ^. 
  # Modular arithmetic: %/% (integer division) and %% (remainder), where x == y * (x %/% y) + (x %% y).
  # Logs: log(), log2(), log10(). Logarithms are an incredibly useful transformation for dealing with data that ranges across multiple orders of magnitude. 
  # Offsets: lead() and lag() allow you to refer to leading or lagging values. This allows you to compute running differences (e.g. x - lag(x)) or find when values change (x != lag(x)). They are most useful in conjunction with group_by()
  # Cumulative and rolling aggregates: R provides functions for running sums, products, mins and maxes: cumsum(), cumprod(), cummin(), cummax(); and dplyr provides cummean() for cumulative means.
  # Logical comparisons, <, <=, >, >=, !=, which you learned about earlier.
  # Ranking: there are a number of ranking functions, but you should start with min_rank(). It does the most usual type of ranking (e.g. 1st, 2nd, 2nd, 4th). The default gives smallest values the small ranks; use desc(x) to give the largest values the smallest ranks.
    y <- c(1, 2, 2, NA, 3, 4)
    min_rank(y)
    #> [1]  1  2  2 NA  4  5
    min_rank(desc(y))
    #> [1]  5  3  3 NA  2  1

    
### Grouped summaries with summarise()
# The last key verb is summarise(). It collapses a data frame to a single row:
summarise(flights, delay = mean(dep_delay, na.rm = TRUE))
# For example, if we applied exactly the same code to a data frame grouped by date, we get the average delay per date:
by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))
# Together group_by() and summarise() provide one of the tools that you'll use most commonly when working with dplyr: grouped summaries. 

### Missing values
# You may have wondered about the na.rm argument we used above. 
flights %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay))

delays <- flights %>% 
  group_by(dest) %>% 
  summarise(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  filter(count > 20, dest != "HNL")

### Counts
# Whenever you do any aggregation, it's always a good idea to include either a count (n()), or a count of non-missing values (sum(!is.na(x)))
# custom function to check NA percentage in a data column
checkna <- function(data) {
  list <- names(data)
  names = c()
  total_n = c()
  percent_n = c()
  for(i in 1:length(data)){
    names[i] <- list[i]
    na_n[i] <- sum(is.na(data[list[i]]))
    total_n[i] <- nrow(data[list[i]])
    percent_n[i] <- ifelse(round(na_n[i]/total_n[i],digits = 4) == 0, "good",round(na_n[i]/total_n[i],digits = 4))
    #print(paste(na_n[i],total_n[i],percent_n[i]))
  }
  df <- data.frame(col_name = names, NAs = na_n, total_count = total_n, na_percent = percent_n)
  print(df)
}

# https://sebastiansauer.github.io/sum-isna/
checkna(flights) #equvilant to:
sapply(flights, function(x) mean(is.na(x)))    
flights %>% #equvilant to:
  select(everything()) %>%  
  summarise_all(funs(sum(is.na(.))))


# For example, let's look at the planes (identified by their tail number) that have the highest average delays:
not_cancelled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay))

delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay)
  )

ggplot(data = delays, mapping = aes(x = delay)) + 
  geom_freqpoly(binwidth = 10)
# The story is actually a little more nuanced. We can get more insight if we draw a scatterplot of number of flights vs. average delay:
delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )

ggplot(data = delays, mapping = aes(x = n, y = delay)) + 
  geom_point(alpha = 1/10)
# it's often useful to filter out the groups with the smallest numbers of observations, so you can see more of the pattern and less of the extreme variation in the smallest groups. 
delays %>% 
  filter(n > 25) %>% 
  ggplot(mapping = aes(x = n, y = delay)) + 
  geom_point(alpha = 1/10)

### Useful summary functions
#Just using means, counts, and sum can get you a long way, but R provides many other useful summary functions:
  # Measures of location: we've used mean(x), but median(x) is also useful. The mean is the sum divided by the length; the median is a value where 50% of x is above it, and 50% is below it.
    not_cancelled %>% 
      group_by(year, month, day) %>% 
      summarise(
        avg_delay1 = mean(arr_delay),
        avg_delay2 = mean(arr_delay[arr_delay > 0]) # the average positive delay
      )
  # Measures of spread: sd(x), IQR(x), mad(x). The root mean squared deviation, or standard deviation or sd for short, is the standard measure of spread. The interquartile range IQR() and median absolute deviation mad(x) are robust equivalents that may be more useful if you have outliers.
    # Why is distance to some destinations more variable than to others?
    not_cancelled %>% 
      group_by(dest) %>% 
      summarise(distance_sd = sd(distance)) %>% 
      arrange(desc(distance_sd))
  # Measures of rank: min(x), quantile(x, 0.25), max(x). Quantiles are a generalisation of the median. For example, quantile(x, 0.25) will find a value of x that is greater than 25% of the values, and less than the remaining 75%.
    # When do the first and last flights leave each day?
    not_cancelled %>% 
      group_by(year, month, day) %>% 
      summarise(
        first = min(dep_time),
        last = max(dep_time)
      )
  # Measures of position: first(x), nth(x, 2), last(x). These work similarly to x[1], x[2], and x[length(x)] but let you set a default value if that position does not exist (i.e. you're trying to get the 3rd element from a group that only has two elements).
    #For example, we can find the first and last departure for each day:
    not_cancelled %>% 
      group_by(year, month, day) %>% 
      summarise(
        first_dep = first(dep_time), 
        last_dep = last(dep_time)
      )
    #Filtering gives you all variables, with each observation in a separate row:
    not_cancelled %>% 
      group_by(year, month, day) %>% 
      transmute(r = min_rank(desc(dep_time))) %>%
      filter(r %in% range(r))
  # Counts: You've seen n(), which takes no arguments, and returns the size of the current group. To count the number of non-missing values, use sum(!is.na(x)). To count the number of distinct (unique) values, use n_distinct(x).
    #Which destinations have the most carriers?    
    not_cancelled %>% 
      group_by(dest) %>% 
      summarise(carriers = n_distinct(carrier)) %>% 
      arrange(desc(carriers))
    #Counts are so useful that dplyr provides a simple helper if all you want is a count:
    not_cancelled %>% 
      count(dest)
    #You can optionally provide a weight variable. For example, you could use this to "count" (sum) the total number of miles a plane flew:
    not_cancelled %>% 
      count(tailnum, wt = distance)
    #Counts and proportions of logical values: sum(x > 10), mean(y == 0). When used with numeric functions, TRUE is converted to 1 and FALSE to 0. This makes sum() and mean() very useful: sum(x) gives the number of TRUEs in x, and mean(x) gives the proportion.
    #How many flights left before 5am? (these usually indicate delayed
    # flights from the previous day)
    not_cancelled %>% 
      group_by(year, month, day) %>% 
      summarise(n_early = sum(dep_time < 500))    
    # What proportion of flights are delayed by more than an hour?
    not_cancelled %>% 
      group_by(year, month, day) %>% 
      summarise(hour_perc = mean(arr_delay > 60))
    
### Grouping by multiple variables
# When you group by multiple variables, each summary peels off one level of the grouping. That makes it easy to progressively roll up a dataset
  daily <- group_by(flights, year, month, day)
  (per_day   <- summarise(daily, flights = n()))  
  (per_month <- summarise(per_day, flights = sum(flights)))
  (per_year  <- summarise(per_month, flights = sum(flights)))
# it's OK for sums and counts, but you need to think about weighting means and variances, and it's not possible to do it exactly for rank-based statistics like the median. In other words, the sum of groupwise sums is the overall sum, but the median of groupwise medians is not the overall median.
  
### Ungrouping
  daily %>% 
    ungroup() %>%             # no longer grouped by date
    summarise(flights = n())  # all flights
# why do you need ungroup() function

### Grouped mutates (and filters)
# Grouping is most useful in conjunction with summarise(), but you can also do convenient operations with mutate() and filter()
  # Find the worst members of each group:
  flights_sml %>% group_by(year, month, day) %>% filter(rank(desc(arr_delay)) < 10)
  # Find all groups bigger than a threshold:
  popular_dests <- flights %>% 
    group_by(dest) %>% 
    filter(n() > 365)
  # Standardise to compute per group metrics:
  popular_dests %>% 
    filter(arr_delay > 0) %>% 
    mutate(prop_delay = arr_delay / sum(arr_delay)) %>% 
    select(year:day, dest, arr_delay, prop_delay)
    
    
    

    
    

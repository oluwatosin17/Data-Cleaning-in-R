# Data-Cleaning-in-R
##
In Data Cleaning With R,
1. I performed data cleaning operations that primarily involved numeric data: Changing data types from character to numeric and creating new variables by performing calculations with existing numeric variables.. 

## MANIPULATING COLUMNS USING THE DPLYR PACKAGE:
> Converting a single column to numeric:

`data_frame <- data_frame %>%
mutate(`col name` = as.numeric(`col name`))`

>Converting multiple columns to numeric with column names:

`data_frame <- data_frame %>%
mutate_at(vars(`col name 1`: `col name 5`), as.numeric)`

> Converting multiple columns to numeric with column indexes:

`data_frame <- data_frame %>%
mutate_at(`beginning index`: `ending index`), as.numeric)`

> Filtering a data frame:

`data_frame <- data_frame %>%
filter(`col name` > condition)`

> Grouping a data frame:

`data_frame <- data_frame %>%
group_by(`col name 1`, `col name 2`)`

> Summing up columns:

` data_frame <- data_frame %>%
mutate(`col name` = `col name 1` + `col name 2`)`

> Padding character strings:

`data_frame <- data_frame %>%
str_pad(`col name`, width = 6, side = 'left', pad = "0")`

> Selecting variables from a data frame:

`graduation <- graduation %>%
filter(Cohort == "2006" & Demographic == "Total Cohort") %>%
select(`col name 1`, `col name 2`, `col name 3`)`

> Removing a column from a data frame:

`graduation <- graduation %>%
select(-the_name_of_column_to_remove) #note the presence of the symbol -`

> Renaming a column in a data frame:

`data_frame %>%
rename(new_column_name = old_column_name)`

> Identifying duplicated values:

`duplicated(data_frame)`

> Identifying duplicatated values using purrr and dplyr:

`list %>%
map(mutate, is_dup = duplicated(`col name 1`))`


## String Manipulation and Relational Data

**FINDING NUMBERS IN A STRING**

Extracting numbers in a string:

`Total Grads - % of cohort` <- parse_number(`Total Grads - % of cohort`)

**Extracting numbers from multiple variables at once:**

`data_frame %>%
mutate_at(vars(`first column in range`:`last column in range`), parse_number)`

**SUBSETTING STRINGS**

Subsetting a character string from left to right:

`Vector_2  <- Vector_1 %>%
str_sub(5, 7)`

Subsetting a character string from right to left:

`Vector_2  <- Vector_1 %>%
str_sub(-4, -6)`

**JOINING DATA FRAMES**

Combining two data frames using an inner join:

`sat_results %>%
inner_join(class_size, by = "DBN")`

**Combining two data frames using a left join:**

`sat_results %>%
left_join(class_size, by = "DBN")`

**Combining two data frames using a right join:**

`sat_results %>%
right_join(class_size, by = "DBN")`

**Combining two data frames using a full join:**

`sat_results %>%
full_join(class_size, by = "DBN")`


- Performing a left join keeps all observations in the data frame on the left and drops observations from the data frame on the right that have no key match.
- Performing a right join keeps all observations in the data frame on the right and drops observations from the data frame on the left that have no key.
- Performing a full join keeps all observations from both data frames and fills in missing variables with NA.

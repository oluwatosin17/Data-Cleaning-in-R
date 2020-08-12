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


## Correlations and Reshaping Data

**RESHAPING DATA FOR VISUALIZATION**
Reshaping a dataframe so that variable names are values of a new variables:

`combined_socio_longer <- combined %>%
  pivot_longer(cols = c(frl_percent, ell_percent, sped_percent),
           names_to = "socio_indicator",
           values_to = "percent")`

Reshaping a dataframe so that a variable values are variable names of a new variables:

`combined_socio_wider <- combined %>%
  pivot_wider(names_from = socio_indicator,
              values_from = percent)`

**CALCULATING PEARSON'S CORRELATION COEFFICIENT**

Calculating Pearson's correlation coefficient for a pair of variables:

`cor(combined$avg_sat_score, combined$asian_per, use = "complete.obs")`

Creating a correlation matrix to calculate Pearson's correlation coefficient for multiple pairs of variables:

`cor_mat <- combined %>%
  select_if(is.numeric) %>%
  cor(use = "pairwise.complete.obs")`

Converting a correlation matrix to a tibble:

`cor_tib <- cor_mat %>%
  as_tibble(rownames = "variable")`

Indexing a tibble to identify moderate to strong correlations:

`apscore_cors <- cor_tib %>%
  select(variable, high_score_percent) %>%
  filter(high_score_percent > 0.25 | high_score_percent < -0.25)`

- Calculating correlation coefficients (Pearson's r) allows us to measure the strength of a relationship between a pair of variables.
  - Correlation coefficients have a value between +1 and −1.
  - The closer a correlation coefficient is to zero, the weaker the relationship between the two variables is.
  - The closer a correlation coefficient is to -1 or 1, the stronger the relationship is.
  - Positive values indicate a relationships where both variables' values increase.
  - Negative values indicate a relationship where one variable decreases as another increases.
  - Values above 0.25 or below -0.25 are enough to qualify a correlation as potentially interesting and worthy of further investigation.
  - Values above 0.75 or below -0.75 indicate strong relationships.

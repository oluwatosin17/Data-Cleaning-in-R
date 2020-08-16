---
  title: "String Manipulation And Relational Data"
author: "Tosin"
date: "08/09/2020"
output: html_document
---
  
library(readr)
library(tidyverse)

sat_results <- read_csv("sat_results_1.csv")
ap_2010 <- read_csv("ap_2010_1.csv")
class_size <- read_csv("class_size_1.csv")
demographics <- read_csv("demographics_1.csv")
graduation <- read_csv("graduation_1.csv")
hs_directory <- read_csv("hs_directory_1.csv")


#According to the tidy data concept, for a dataset to be tidy:
#Each variable must have its own column
#Each observation must have its own row
#Each value must have its own cell

head(sat_results)
head(ap_2010)
head(class_size)
head(demographics)
head(graduation)
head(hs_directory)


#Parsing Numbers from Strings
colnames(graduation)
graduation <- graduation %>% mutate_at(vars(`Total Grads - % of cohort`: `Dropped Out - % of cohort`), parse_number)
head(graduation,3)


# Extracting Numeric Data From String: Creating New Variables
view(hs_directory)
#There are two instances of character sequence "\n"
hs_directory <- hs_directory %>% mutate(lat_long = (str_split(`Location 1`, "\n",simplify = T)[,3]))

#Splitting Strings
hs_directory <- hs_directory %>% mutate(lat = (str_split(lat_long,",",simplify = T)[,1])) 
hs_directory <- hs_directory %>% mutate(long = (str_split(lat_long,",",simplify = T)[,2]))

# Subsetting strings
vector <- c("abcde1223","bhdkh6933")
vector_1 <- vector %>% str_sub(5,7)
vector_1
vector_1 <- vector %>% str_sub(-6,-4)

hs_directory <- hs_directory %>% mutate(lat = str_sub(lat,2)) 
hs_directory <- hs_directory %>% mutate(long = str_sub(long, ,-2)) 
hs_directory <- hs_directory %>% mutate_at(vars(lat:long),as.numeric)
hs_directory <- hs_directory %>% mutate(lat = str_sub(lat,2)) %>% mutate(long = str_sub(long,,-2)) %>% mutate_at(vars(lat:long),as.numeric)
head(hs_directory,2) 

# Inner Join

sat_class_size <- sat_results %>% inner_join(class_size, by = "DBN")
view(sat_class_size)
ggplot(data = sat_class_size, aes(x = avg_class_size, y = avg_sat_score))+geom_point()+theme(panel.background = element_rect(fill = "white")) 


#Outer Join 
demo_sat_left <- sat_results %>% left_join(demographics, by = "DBN")
demo_sat_right <- sat_results %>% right_join(demographics, by = "DBN")
demo_sat_full <- sat_results %>% full_join(demographics, by = "DBN")

view(demo_sat_right)

#Using join to create a single dataframe 
#We are using data that provides information about the student academic performance
# sat result and ap_2010 . some schools may have data for only sat or ap_2010
# so we use full_join  we use left join for the rest because we want to retain info in the ap_2010 and sat_results

combined <- sat_results %>% full_join(ap_2010, by = "DBN")
combined <- combined %>% left_join(class_size, by ="DBN") %>% left_join(demographics, by ="DBN") %>% left_join(graduation, by ="DBN") %>% left_join(hs_directory, by ="DBN")

view(combined)

combined <- read_csv("combined.csv")
combined <- combined %>% select(-c(SchoolName,`SCHOOL NAME.y`,Name,`School Name`,school_name,`Location 1`))
combined <- combined %>% rename(school_name = `SCHOOL NAME.x`)

# Visualizing Relationships Between Variables Using Scatter Plots

ggplot(data = combined, aes(x = frl_percent, y = avg_sat_score)) + geom_point()
ggplot(data = combined, aes(x = ell_percent, y = avg_sat_score)) + geom_point()
ggplot(data = combined, aes(x = sped_percent, y = avg_sat_score)) + geom_point()


# Generally as frl_percent increases, avg_sat_score decreases.
# The relationship between ell_percent and avg_sat_score is interesting. As ell_percent
# increases, avg_sat_scores very rapidly dcreases. There are a few schools with ell_percent between 50 percent and 75 percent
# There some number of schools with ell_percent greater than 75% those schools have low values of avg_sat_score 
# for sped_percent and avg_sat_score; as avg_sat_score decreases as sped_percent increases

library(tidyr)


#Pivoting a DataFrame into a Longer one
#The pivot_longer() function takes targeted columns and collapse them into key value pairs, duplicating all other columns as needed. 

combined_socio_longer <- combined %>% pivot_longer(cols = c(frl_percent,ell_percent,sped_percent), names_to = "socio_indicator",values_to = "percent")
view(combined_socio_longer)
# Using the reshaped data, we could then create a scatter plot that shows the points that represent the relationship between avg_sat_score and the different socioeconomic indicators using different colors

ggplot(data = combined_socio_longer, aes(x = percent , y = avg_sat_score, color = socio_indicator))+geom_point()


combined_race_longer <- combined %>% pivot_longer(cols = c(asian_per,black_per,hispanic_per,white_per), names_to = "race", values_to = "percent")
ggplot(data = combined_race_longer, aes(x = percent, y = avg_sat_score, color = race))+geom_point()

# Pivoting a DataFrame into a wider one
combined_socio_wider <- combined_socio_longer %>% pivot_wider(names_from = socio_indicator, values_from = percent)
view(combined_socio_wider)

combined_race_wider <- combined_race_longer %>% pivot_wider(names_from = race , values_from = percent)
view(combined_race_wider)

#Comparing the Strength of Relationships Among Pairs of Variables
ggplot(data = combined_race_longer, aes(x = percent, y = avg_sat_score, color = race))+geom_point() + facet_wrap(~race)

# It seems that while the percentage of white and asian students display positiv relationship with SAT score, the percentage of black and hispanic student display a negative relationship with sat score 

#Correlation Analysis: Measuring the strength of relationship between Variables
#Pearson's r has a value between +1 and -1. The closer a correlation coefficent is to zero, the weaker the relationship between the two variable is. vice -versa
# r values between .25 and -.25 are enough to qualify correlation as potentially interesting and worthy of further investigation

round(cor(combined$asian_per,combined$avg_sat_score, use = "pairwise.complete.obs"),7)
 
#An r value of 0.57 indicates a moderately strong, positive relationship between asian_per and avg_sat_score

combined %>% select(avg_sat_score,black_per,hispanic_per,white_per,asian_per) %>% cor(use = "pairwise.complete.obs") 

#Creating and Interpreting Correlation Matrices
cor_mat <- combined %>% select_if(is.numeric) %>% cor(use = "pairwise.complete.obs")
view(cor_mat)

#Identifying Interesting Relationship
cor_tib <- cor_mat %>% as_tibble(rownames = "variables")
sat_cors <- cor_tib %>% select(variables,avg_sat_score) %>% filter(avg_sat_score > 0.25 | avg_sat_score < -0.25)

view(sat_cors)


aps_cors <- cor_tib %>% select(variables,high_score_percent) %>% filter(high_score_percent > 0.25 | high_score_percent < -0.25)
view(aps_cors)

#The demographic variables that display positive correlations with SAT scores are ones that are generally associated with wealthier areas with better-funded schools, such as variables that describe the number of students who have the opportunity to take AP exams (AP Test Takers, Total Exams Taken, Number of Exams with scores 3 4 or 5, and high_score_percent) and the percentage of students who successfully graduate (grads_percent).
# Those that display negative correlations with SAT scores are ones that tend to be associated with less wealthy areas and poorly funded schools, such as percentage of students who qualify for free or reduced lunch (frl_percent) and are English language learners (ell_percent).
# The correlations also highlight racial inequality of SAT scores, and show that schools with higher percentages of asian and white students tend to have higher average SAT scores, while schools with higher percentages of hispanic and black students tend to have lower SAT scores.
# analysis suggests that students who come from communities with certain demographic and socioeconomic features may be at a disadvantage when it comes to performance on standardized tests.


#Dealing with Missing Data
view(combined)
unique(combined$boro)
summary <- combined %>% group_by(boro) %>% summarise(avg = mean(avg_sat_score))
summary

summary <- combined %>% group_by(boro) %>% summarise(avg = mean(avg_sat_score, na.rm = T))

#Dropping Rows with Missing Values for one Variable

summary <- combined %>% drop_na(boro) %>% group_by(boro) %>% summarise(avg = mean(avg_sat_score, na.rm = T))

#Complete Cases: Dropping All Rows With Missing Data 
summary_3 <- combined %>% drop_na() %>% group_by(boro) %>% summarise(avg = mean(avg_sat_score))
summary_3



#Using Complete Cases: When to Avoid
colSums(is.na(combined))

# Understanding Effects of Different Techniques for HANDLING Missing Data
summary_4 <- combined %>% drop_na(boro) %>% group_by(boro) %>% summarise(mean(avg_sat_score,na.rm = T),mean(frl_percent, na.rm = T),mean(`AP Test Takers`, na.rm = T))
view(summary_4)

combined_2 <- combined %>% mutate(AP_Test_Taker = replace_na(`AP Test Takers`,2.5))
combined_2 <- combined_2 %>% drop_na(boro)
view(combined_2)

ggplot(data = combined_2, aes(x = boro , y = AP_Test_Taker))+geom_boxplot()
head(combined_2,2)
combined_2  %>% group_by(boro) %>% summarise(min(AP_Test_Taker))



---
  title: "Data Cleaning in R"
author: "Tosin"
date: "08/07/2020"
output: html_document
---
library(readr)
library(tidyverse)

sat_results <- read_csv("sat_results.csv")
ap_2010 <- read_csv("ap_2010.csv")
class_size <- read_csv("class_size.csv")
demographics <- read_csv("demographics.csv")
graduation <- read_csv("graduation.csv")
hs_directory <- read_csv("hs_directory.csv")

#Cleaning the New York City School Data
head(sat_results)
head(ap_2010)
head(class_size)
head(demographics)
head(graduation)
head(hs_directory)

#SAT Data: Changing Data Types and Creating New Variables
colnames(sat_results)
sat_results <- sat_results %>% mutate(`Num of SAT Test Takers` = as.numeric(`Num of SAT Test Takers`))
sat_results <- sat_results %>% mutate(`SAT Critical Reading Avg. Score` = as.numeric(`SAT Critical Reading Avg. Score`))
sat_results <- sat_results %>% mutate(`SAT Math Avg. Score` = as.numeric(`SAT Math Avg. Score`))
sat_results <- sat_results %>% mutate(`SAT Writing Avg. Score` = as.numeric(`SAT Writing Avg. Score`))

#Adding by row
sat_results <- sat_results %>% rowwise() %>% mutate(avg_sat_score =  sum(c(`SAT Writing Avg. Score`,`SAT Math Avg. Score`,`SAT Critical Reading Avg. Score`),na.rm = F))

view(sat_results)
colnames(sat_results)

#AP Exam Data: Changing Data Types and Creating a New Variable
colnames(ap_2010)
head(ap_2010)
#Calculating the average number of AP exams taken by each student
ap_2010 <- ap_2010 %>% mutate_at(3:5, as.numeric)
ap_2010 <- ap_2010 %>% mutate(exams_per_student = `Total Exams Taken`/ `AP Test Takers`)
view(ap_2010)
# The percentage of all exams with scores of three, four or five.
ap_2010 <- ap_2010 %>% mutate(high_score_percent = (`Number of Exams with scores 3 4 or 5`/`Total Exams Taken`)*100)


#Class Size Data: Simplifying the dataframe 
colnames(class_size)
for (col in colnames(class_size)) {
  print(typeof(class_size[[col]]))
}
view(class_size)
class_size <- class_size %>% filter(GRADE == "09-12" & `PROGRAM TYPE` == "GEN ED")


#Class Size Data: Calculating School Averages

class_size <-  class_size %>% group_by(CSD,`SCHOOL CODE`,`SCHOOL NAME`)  %>% summarise(avg_class_size = mean(`AVERAGE CLASS SIZE`), avg_largest_class= mean(`SIZE OF LARGEST CLASS`), avg_smallest_class = mean(`SIZE OF SMALLEST CLASS`))

view(class_size)

# Class Size Data: Creating a Key Using String Manipulation
head(class_size,3)
class_size <- class_size %>% mutate(CSD =  as.character(CSD))
class_size <- class_size %>% mutate(DBN = paste0(CSD,`SCHOOL CODE`))

class_size$DBN <- str_pad(class_size$DBN, 6, side ="left",pad = "0")

#Graduation Data: Simplifying the Data Frame
head(graduation,3)
view(graduation)
unique(graduation$Cohort)

graduation <- graduation %>% filter(Demographic == "Total Cohort") %>% filter(Cohort == "2006" & Cohort != "2006 Aug") %>% select(DBN,`School Name`,`Total Grads - % of cohort`,`Dropped Out - % of cohort`)


#Demographics Data: Simpifying the Data Frame
head(demographics,3)
view(demographics)
demographics <- demographics %>% filter(schoolyear == "20112012" & grade9 != "NA") %>% select(DBN,Name, frl_percent,total_enrollment,ell_percent,sped_percent,asian_per,black_per,hispanic_per,white_per,male_per,female_per)


#Demographics Data: Removing Variables to Simply DataFrame
demographics_clean <- demographics %>% select(DBN:male_per)
view(demographics_clean)

demographics_clean <- demographics_clean %>% select(-Name)


#High School Directory: Simplifying the DataFrame
head(hs_directory,3)
hs_directory <- hs_directory %>% select(dbn,school_name,`Location 1`)
hs_directory <- hs_directory %>% rename("DBN"= "dbn")
view(hs_directory)

# Confirm that DataFrames are Prepared for Joining
vector <- c(1,2,3,4,5,5,6)
duplicated(vector)
duplicated(sat_results$DBN)

ny_schools <- list(sat_results,ap_2010,class_size,demographics_clean,graduation,hs_directory)
names(ny_schools) <- c("sat_results","ap_2010","class_size","demographics_clean","graduation","hs_directory")
duplicate_DBN <- ny_schools %>% map(mutate, is_dup = duplicated(DBN)) %>% map(filter,is_dup == T)


#Removing Duplicate Rows
ap_2010 %>% filter(DBN == "04M610")

ap_2010 <- ap_2010 %>% filter(SchoolName != "YOUNG WOMEN'S LEADERSHIP SCH")

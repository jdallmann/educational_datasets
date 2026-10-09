# educational_datasets
Repo for open datasets to assist with teaching and learning data science.

## nightmare_data.csv
This dataset is used to teach or practice dataset cleaning. It is a log of nightmares with columns `Nightmare type` (i.e. falling, being chased, forgetting your homework... with 5% including typos), `Date` (should be encoded as yyymmdd, but include Unix and Excel integers), `Panic inducing` (one-hot-encoding incorrectly encoded as a real), and counts `duration0005`, `duration0610`, `duration1120`. `duration2130`, `duration3160`, `duration60+` (with missing values coded either as N/A or "" and with censored values set to 10000). 

## online_retail_data_for_cleaning.csv
This data set is based on a random sample of the UCI online+retail dataset with columns added to practise data cleaning. https://archive.ics.uci.edu/dataset/352/online+retail DOI:10.24432/C5BW33

## online_retail_data_for_clustering.csv
This data set is based on the UCI online+retail dataset with columns engineered for data clustering. https://archive.ics.uci.edu/dataset/352/online+retail DOI:10.24432/C5BW33

## white_wine_data_for_regression.csv
This data set is based on the UCI wine+quality white wine dataset with an additional engineered column for regression. https://archive.ics.uci.edu/dataset/186/wine+quality DOI:10.24432/C56S3T

## wine_data_for_cleaning.csv
This data set is based on the UCI wine+quality dataset with columns added to practise data cleaning. https://archive.ics.uci.edu/dataset/186/wine+quality DOI:10.24432/C56S3T


## Hypothesis testing data sets
### iris.csv
From the R documentation: iris is a data frame with 150 cases (rows) and 5 variables (columns) named Sepal.Length, Sepal.Width, Petal.Length, Petal.Width, and Species. 
It is originally from:
Fisher, R. A. (1936) The use of multiple measurements in taxonomic problems. Annals of Eugenics, 7, Part II, 179–188. doi:10.1111/j.1469-1809.1936.tb02137.x, with data collected by Anderson, Edgar (1935). The irises of the Gaspe Peninsula, Bulletin of the American Iris Society, 59, 2–5. See Becker, R. A., Chambers, J. M. and Wilks, A. R. (1988) The New S Language. Wadsworth & Brooks/Cole.

### paired_sleep.csv
From the R documentation: Student [the creator of the T-test]'s Sleep Data which show the effect of two soporific drugs (increase in hours of sleep compared to control) on 10 patients. A data frame with 20 observations on 3 variables.

[, 1]	extra	numeric	increase in hours of sleep
[, 2]	group	factor	drug given
[, 3]	ID	factor	patient ID

The group variable name may be misleading about the data: They represent measurements on 10 persons, not in groups.

It is originally from:
Student (1908) The probable error of the mean. Biometrika, 6, 20. 
See also: Cushny, A. R. and Peebles, A. R. (1905) The action of optical isomers: II hyoscines. The Journal of Physiology 32, 501–510. Scheffé, Henry (1959) The Analysis of Variance. New York, NY: Wiley.

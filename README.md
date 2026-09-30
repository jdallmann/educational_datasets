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

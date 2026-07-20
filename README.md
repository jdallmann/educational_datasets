# educational_datasets
Repo for open datasets to assist with teaching and learning data science.

## nightmare_data.csv
This dataset is used to teach or practice dataset cleaning. It is a log of nightmares with columns `Nightmare type` (i.e. falling, being chased, forgetting your homework... with 5% including typos), `Date` (should be encoded as yyymmdd, but include Unix and Excel integers), `Panic inducing` (one-hot-encoding incorrectly encoded as a real), and counts `duration0005`, `duration0610`, `duration1120`. `duration2130`, `duration3160`, `duration60+` (with missing values coded either as N/A or "" and with censored values set to 10000). 


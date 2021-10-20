install.packages("abcrf") # To install the abcrf package (version 1.7.1)
library(abcrf) # To load the package.

outSS <- read.delim("/home/becheler/dev/OSG_EGGS_CRUMBS/DAG/sumstats.txt")
head(outSS)
outSS$X <- c()
head(outSS)

params <- read.csv("/home/becheler/dev/OSG_EGGS_CRUMBS/DAG/param_table.txt", sep="")
head(params)
# These parameters are unique values
params$K_max. <- c()
params$K_min. <- c()
# Model index
index <-  rep(1, nrow(params))
data <- cbind(index, params, outSS)
head(data)

# Convert to suitable data for ABC-RF
# data is a matrix. The first column is the model indices, the next p are
# the p parameters, the last k are the summary statistics.
data <- as.matrix(data)
# To store the model 1 indexes.
index1 <- data[ , 1] == 1 
# We then create a data frame composed of the parameter of interest poi and
# the summary statistics of model 1. p and k have to be defined.
p = ncol(params)
k = ncol(outSS)
data.poi <- data.frame(poi = data[index1, "scale_tree"], data[index1, (p+2):(p+k+1)])

#data.poi <- data.poi[1:10000, ]
# If you are interest in the 10000 first datasets.

model.poi <- regAbcrf(formula = poi~., data = data.poi, ntree = 500,
                      min.node.size = 5, paral = TRUE)
# The used formula means that we are interested in explaining the parameter
# poi thanks to all the remaining columns of data.poi (i.e. all the
# summary statistics).
# The paral argument determine if parallel computing will be activated
# or not.

errorOOB <- err.regAbcrf(object = model.poi, training = data.poi, paral = TRUE)

plot(x = model.poi, n.var = 30)
# The contributions of the 25 most important summary statistics are
# represented (e.g. Figure S5).

# Reading the observed dataset with
obs.poi <- read.table("statobs.txt", skip=2)
obs.poi <- read.delim("~/Documents/Articles/decrypt_publication/obsSS")
obs.poi$X <- c()

# If obs.poi is not a dataframe or the column names do not match,
# you can use the following lines:
obs.poi <- as.data.frame(obs.poi)
colnames(obs.poi) <- colnames(data.poi[ ,-1])
# Prediction is complete by
pred.obsPoi <- predict(object = model.poi, obs = obs.poi,
                       training = data.poi, quantiles = c(0.025,0.975),
                       paral = TRUE)
# The 2.5 and 97.5 order quantiles are computed by specifying
# quantiles = c(0.025,0.975).
# pred.obsPoi is a list containing predictions of interest.
# Posterior mean can be retrieved by
pred.obsPoi$expectation
# Posterior variance by
pred.obsPoi$variance
# Posterior quantiles by
pred.obsPoi$quantiles
densityPlot(object = model.poi, obs = obs.poi, training = data.poi, paral = TRUE)


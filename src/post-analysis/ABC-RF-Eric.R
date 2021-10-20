# SHORT ABCRF SCRIPT
#############################################################################################################
#############################################################################################################
#############################################################################################################
rm(list=ls())
library(abcrf)

# Long duration
outSS <- read.delim("/home/becheler/dev/OSG_EGGS_CRUMBS/DAG/sumstats.txt")
outSS$X <- c()
head(outSS)

params <- read.csv("/home/becheler/dev/OSG_EGGS_CRUMBS/DAG/param_table.txt", sep="")
# Remove constant values
params$K_max. <- c()
params$K_min. <- c()
df_1 <- data.frame(modindex = as.factor(1), outSS)
head(df_1)

obsSS <- read.delim("~/Documents/Articles/decrypt_publication/obsSS")
obsSS$X <- c()
statobs <- obsSS

######### Exploration 

library(abc)
library(ggplot2)

### Plot the simulation cloud  https://towardsdatascience.com/principal-component-analysis-pca-101-using-r-361f4c53a9ff
pca_res <- prcomp(outSS, center = TRUE, scale. = TRUE)
summary(pca_res)
# Draw the envelop
gfitpca(target = obsSS, sumstat = outSS, index = rep("EGG1", nrow(outSS)))
# Add points PCA
points(pca_res$x[,1],pca_res$x[,2], xlab="PC1 (14%)", ylab = "PC2 (8%)", main = "PC1 / PC2 - plot", pch="+", col="blue")

### Plot the distribution of simulated statistics with observed statistics (red vertical bar)
my_plots <- lapply(names(outSS), function(var_x){
  p <- ggplot(outSS) + aes_string(var_x) +
    geom_density() +
    geom_vline(xintercept=obsSS[1,var_x], size=1, color="red")
})

require(cowplot) # plot_grid
plot_grid(plotlist = my_plots[1:8])
plot_grid(plotlist = my_plots[9:15])
plot_grid(plotlist = my_plots[16:23])
plot_grid(plotlist = my_plots[24:30])
plot_grid(plotlist = my_plots[31:37])

#############################################################################################################
#############################################################################################################
#############################################################################################################
### MODEL CHOICE (i.e. you have several scenario, and you want to know which one is the most likely)
#############################################################################################################
#############################################################################################################
#############################################################################################################

# Number of tree for the random forest (classical values = between 500 and 1000) :
TREE <- 1000

# We compute the classification forest:
mc.rf <- abcrf(data1$modindex~.,data1,paral=TRUE,ntree=TREE)
## Here, "modindex" contain the index (i.e. scenario number) of all your simulated datasets
## Here, "data1" is a dataframe with "modindex" as a first column, and then, all your n summary statistics in n columns

# If you want the prior error rate of your forest (and the confusion matrix):
mc.rf

# some figures (importance of each of your statistcis + first 2 axes of a LDA including a black cross representing your true dataset)
plot(mc.rf, data1, obs=statobs, pdf=TRUE)
## Here "statobs" is a dataframe containing the summary statistics of your true dataset. Same header than "data1" (but of course without the modindex column)

## We assign the statobs to a model, and we compute the posterior probability of the selected model through a regression forest :
post_proba<-predict(mc.rf, statobs, data1, ntree=TREE, paral=TRUE)
# Model choice results (including the number of the selected scenario, the number of "votes" of each scenario, and the posterior probability of the selected scenario) :
post_proba


### Extra interesting information:
# A list with the "importance stats" (high value = the stat is very important in the decision forest) :
mc.rf$model.rf$variable.importance
# We compute the out-of-bag errors for different number of trees (to see whether the chosen number of trees seems sufficient) :
err.rf <- err.abcrf(mc.rf,data1,paral=TRUE) 





#############################################################################################################
#############################################################################################################
#############################################################################################################
### PARAMETER ESTIMATION
#############################################################################################################
#############################################################################################################
#############################################################################################################

# Number of tree for the random forest (classical values = between 500 and 1000) :
TREE <- 1000

### Below :
# "PARAM_S" is a dataframe with m parameters in m columns (only for the scenario of interest)
# "STAT_S" is a dataframe with n summary statistics in n columns (only for the scenario of interest)
# "statobs" contain the summary statistics of your true dataset
PARAM_S <- read.csv("/home/becheler/dev/OSG_EGGS_CRUMBS/DAG/param_table.txt", sep="")
# Remove constant values
PARAM_S$K_max. <- c()
PARAM_S$K_min. <- c()
head(PARAM_S)

STAT_S <- read.delim("/home/becheler/dev/OSG_EGGS_CRUMBS/DAG/sumstats.txt")
STAT_S$X <- c()

statobs <- read.delim("~/Documents/Articles/decrypt_publication/obsSS")
statobs$X <- c()

par(mfrow=c(1,3),oma = c(0, 0, 2, 0))

layout(matrix(c(1,2,1,3), 2, 2, byrow = TRUE),
       widths=c(2,3), heights=c(1,1))

#Estimation of all parameters with RF method :
for(i in 1:length(PARAM_S[1,]))
{
  # We create a data frame composed of the parameter of interest "poi" and the summary statistics of the simulated scenario
  param <- colnames(PARAM_S[i])
  data.poi <- data.frame(poi = PARAM_S[, param], sumsta = STAT_S)
  
  # TRAINING A RANDOM FOREST
  model.poi <- regAbcrf(formula = poi~., data = data.poi, ntree = TREE, min.node.size = 5, paral = TRUE)

  # THE CONTRIBUTION OF SUMMARY STATISTICS in ABC-RF estimation for the parameter of interest:
  plot(x = model.poi, n.var = 16)
  
  # GRAPHICAL REPRESENTATIONS TO ACCESS THE PERFORMANCE OF THE METHOD
  # The evolution of the out-of-bag mean squared error depending on the number of tree:
  errorOOB <- err.regAbcrf(object = model.poi, training = data.poi, paral = TRUE)
  
  # If obs.poi is not a dataframe or the column names do not match,
  # you can use the following lines:
  statobs <- as.data.frame(statobs)
  colnames(statobs) <- colnames(data.poi[ ,-1])
  
  # Prediction:
  # If obs.poi is not a dataframe or the column names do not match,
  # you can use the following lines:
  pred.obsPoi <- predict(object = model.poi, obs = statobs, training = data.poi, quantiles = c(0.05,0.500,0.95), paral = TRUE, post.err.med = FALSE)
  pred.obsPoi
  
  # A GRAPHICAL REPRESENTATION OF THE APPROXIMATE POSTERIOR DENSITY of poi given statobs can be obtained using the densityPlot function
  densityPlot(object = model.poi, obs = statobs, training = data.poi, paral = TRUE)
  
  mtext(param, outer = TRUE, cex = 1.5)
}



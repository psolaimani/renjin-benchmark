print("LINE[1]")
# RPPA classification
# ieuan.clay@gmail.com
# April 2015
### set up session
rm(list=ls())
set.seed(8008)
## packages
require(stats)
require(rjson)
## global vars
rppa <- read.csv("./data_20160126_rppa.csv", header=T, stringsAsFactors=F,
                   sep=",", row.names=NULL, blank.lines.skip = TRUE)

print("LINE[15]")

# drop non-numeric columns
rows <- rppa$TCGA_ID
rppa <- rppa[, sapply(rppa, is.numeric)]
row.names(rppa) <- rows

# check it
# str(rppa)
# dim(rppa) # 3467  131

cat("Loading Data: complete\n")

do.dist <- function(input_data){
  cat("Calculating Distance Matrix\n")
  dist_mat <- as.dist((1-cor(t(input_data), method="pearson"))/2)
  cat("Calculating Distance Matrix: complete\n")
}


print("LINE[35]")
## unsupervised clustering
do.within.ss <- function(d = NULL, clustering){
  cluster.size <- numeric(0)
  dmat <- as.matrix(d)
  within.cluster.ss <- 0
  di <- list()

  # iterate thought distance matrix
  for (i in 1:max(clustering)) {
    cluster.size[i] <- sum(clustering == i)
    di <- as.dist(dmat[clustering == i, clustering == i])
    if (i <= max(clustering)) {
      within.cluster.ss <- within.cluster.ss + sum(di^2)/cluster.size[i]
    }
  }
  return(within.cluster.ss)
}


print("LINE[55]")
do.elbow <- function(df){
  df <- df[ order(df$cluster, decreasing = FALSE) ,]
  df$delta <- c(df[1:(nrow(df) -1),"within_ss"] - df[2:nrow(df),"within_ss"],0)
  df$k <- df$cluster-1
  df$smooth <- predict(lm(delta ~ poly((cluster), 4, raw=TRUE), data=df), data.frame(cluster=df$k))
  return(min(which(df$smooth < df[1,"smooth"]/10)))
}
do.hc <- function(dist_mat){
  cat("Calculating Hierarchical clustering\n")
  require(stats)
  res <- hclust(d = dist_mat, method="ward")
  cat("Calculating Hierarchical clustering: cutting tree\n")
  cuts <- lapply(2:25, FUN = function(i){ print(paste("    >", i, "clusters"))
        return(data.frame(cluster = i, within_ss = do.within.ss(dist_mat, cutree(res, k=i))))})
  best_cut <- do.elbow(do.call("rbind", cuts)) # 8 according to paper
  res <- cutree(res, best_cut)
  res <- data.frame(id=attr(dist_mat, which = "Labels"), cluster=res)
  cat("Calculating Hierarchical clustering: complete\n")
  return(res)}
print("LINE[75]")
# kmeans
do.km <- function(dist_mat){
  cat("Calculating K-means clustering\n")
  require(stats)
  res <- lapply(2:25, FUN = function(i){
      cat(paste("    >", i, "clusters\n"))
      kmeans(dist_mat, algorithm="Hartigan-Wong", centers=i)
    }
  )
  cuts <- lapply(res, function(x){data.frame(
                                              cluster = max(x$cluster),
                                              within_ss = sum(x$withinss)
                                              )})
  best_cut <- do.elbow(do.call("rbind", cuts)) # 8 according to paper
  res <- res[[best_cut]]
  res <- data.frame(id=attr(dist_mat, which = "Labels"), cluster=res$cluster)
  cat("Calculating K-means clustering: complete\n")
  return(res)
}
print("LINE[95]")


cat("start: do.dist()\n")
do.dist(input_data=rppa)
cat("end: do.dist()\n")
cat("start: do.hc()\n")
#do.hc(dist_mat=dist_mat)
cat("end: do.hc()\n")
cat("start: do.km()\n")
#do.km(dist_mat=dist_mat)
cat("end: do.km()\n")

# final clean up
rm(list=ls())
gc()




print("LINE[115]")

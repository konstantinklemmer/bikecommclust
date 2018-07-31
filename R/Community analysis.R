library('ggplot2') # visualization
library('ggthemes') # visualization
library('scales') # visualization
library('dplyr') # data manipulation
library('tidyr') # data manipulation
library('chron') # contains the is.weekend function
library("lubridate") # contains functions related to dates
library('NbClust') #contains function to select optimum number of clusters
library('igraph')

# Data Loading and Cleaning 
# Data base loading
setwd("/Users/Fer/Documents/trabajo") #set the proper directory here
# June-Jul 2014 - change to data.table::fread() for larger samples.
df <- rbind(read.csv('20Jul14-31Jul14.csv'),read.csv('22Jun14-19Jul14.csv'))

df$Bike.Id[is.na(df$Bike.Id)] <- 0
df$EndStation.Id[is.na(df$EndStation.Id)] <- 0

# Reading dates
df$Start.Date <- strptime(df$Start.Date, "%d/%m/%Y %H:%M")
df$End.Date <- strptime(df$End.Date, "%d/%m/%Y %H:%M")


# Order the data by date
df <- df[order(df$Start.Date),]


# Remove end.id == 0 and Bike.ID == 0
df <- df[!df$EndStation.Id==0,]
df <- df[!df$Bike.Id==0,]

# Maintenance station detection
nostart <- setdiff(unique(df$EndStation.Id),unique(df$StartStation.Id))

# Removal them from the data set
for (i in 1:NROW(nostart)){
  
  df <- df[!df$EndStation.Id==nostart[i],]
}

# Removing weekends - optional
df <- df[!is.weekend(df$Start.Date),] #we remove the weekends


# Community Analisys

od.e <- as.data.frame(table(df$StartStation.Id,df$EndStation.Id))
names(od.e) <- c("Origin","Destination","weight")


# removing edges with less than one trip a day on average.
od.e <- od.e[od.e$weight >= 1,]

od.e.txt <- data.matrix(od.e)

# ouptut for visualisation in Gephi or similar software
write.csv(od.e,"edges.csv")

# Output for infomap
write.table(od.e.txt,"edges.txt",row.names = FALSE,col.names = FALSE,sep = " ")

#Directed and undirected graphs to use with diferent algorithms
g <- graph_from_data_frame(od.e,directed = F)
gd <- graph_from_data_frame(od.e,directed = T)

g <- simplify(g)

set.seed(42)

# does not work if we don't simplify the data 
fc <- (cluster_fast_greedy(g, merges = TRUE, modularity = TRUE,
                                              membership = TRUE, weights = E(g)$weight))

# fc2 <- edge.betweenness.community(g) # Does not scale for this network

# creating membership matrix to save results
membership <- matrix(0,NROW(fc$membership),1)
membership <- data.frame(membership)
membership$fast_greedy <- fc$membership
membership$membership <- NULL

fc3 <- cluster_walktrap(g, weights = E(g)$weight, steps = 4,
                        merges = TRUE, modularity = TRUE, membership = TRUE)

membership$walks <- fc3$membership

fc4 <- cluster_infomap(gd, e.weights = NULL, v.weights = E(gd)$weight, nb.trials = 20,
                modularity = TRUE)

membership$infomap <- fc4$membership

fc5 <- cluster_louvain(g, weights = E(g)$weights)


membership$louvain <- fc5$membership

membership$id <- V(g)$name
membership <- membership[,c(5,1,2,3,4)]

write.csv(membership,"communities.csv")


# Not run - Infomap command used
infomapcommand <- paste0("./Infomap ","edges.txt"," output/ -N 20 --tree --map --directed")
system(command = infomapcommand)
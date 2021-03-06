#Library dump
library('ggplot2') # visualization
library('ggthemes') # visualization
library('scales') # visualization
library('dplyr') # data manipulation
library('tidyr') # data manipulation
library('chron') # contains the is.weekend function
library("lubridate") # contains functions related to dates
library('NbClust') #contains function to select optimum number of clusters
library(stringr)

# Data base loading
setwd("~/Dropbox/Transport MSc/Dissertation/Rstudio") #set the directory to tfl santander data here
# June-Jul 2014
df <- rbind(read.csv('20Jul14-31Jul14.csv'),read.csv('22Jun14-19Jul14.csv')) #June-July data

# removing NAs
df$Bike.Id[is.na(df$Bike.Id)] <- 0
df$EndStation.Id[is.na(df$EndStation.Id)] <- 0

# Reading date
df$Start.Date <- strptime(df$Start.Date, "%d/%m/%Y %H:%M")
df$End.Date <- strptime(df$End.Date, "%d/%m/%Y %H:%M")


# order the data by date
df <- df[order(df$Start.Date),]


# remove end.id == 0 and Bike.ID == 0
df <- df[!df$EndStation.Id==0,]
df <- df[!df$Bike.Id==0,]

# maintenance station detection and removal
nostart <- setdiff(unique(df$EndStation.Id),unique(df$StartStation.Id))

# removal them from the data set (a match function should be more efficient for bigger data sets)
for (i in 1:NROW(nostart)){
  
  df <- df[!df$EndStation.Id==nostart[i],]
}


df <- df[!is.weekend(df$Start.Date),] #we remove the weekends

# Community detection algorithm

setwd("/Users/Fer/Downloads/Infomap") # Folder with the infomap executable

# Set working directory to edges.

for (h in 0:23){
  
  df_h <- df[hour(df$Start.Date)==h,]
  
  od.e <- as.data.frame(table(df_h$StartStation.Id,df_h$EndStation.Id))
  names(od.e) <- c("Origin","Destination","weight")
  
  od.e <- od.e[od.e$weight > 0,]
  
  od.e.txt <- data.matrix(od.e)
  
  write.table(od.e.txt,paste0("edges",h,".txt"),row.names = FALSE,col.names = FALSE,sep = " ")
  
  infomapcommand <- paste0("./Infomap ","edges",h,".txt"," outputH/ -N 20 --tree --map --directed")
  
  system(command = infomapcommand)

}

# Summarising the results

setwd("~/Downloads/Infomap/outputH")

temp <- list.files(pattern = "*.tree")

outputs <- lapply(temp,function(x){
  imapResults <- read.table(x,header=F,sep=" ") #Read output treee file from infomap
  imapResults <- cbind(imapResults,str_split_fixed(imapResults$V1,":",2)) 
  #Split cluster and index column
  imapResults <- imapResults[ -c(1)] #Delete redundant column
  name <- str_replace(x,"edges","hour")
  name <- str_replace(name,".tree","")
  colnames(imapResults) <- c("flow","name1","ID",name,"clusterID") #Name columns
  imapResults <- imapResults[,c("ID",name)]
  return(imapResults)
})


results <- data.frame("ID" = seq(1,750))

for (i in seq_along(outputs)){
  results <- results %>%
    left_join(outputs[[i]], by="ID")
}

results <- results[,order(names(results))]

results <- results %>%
  select(ID, everything())


write.csv(results,"results.csv")


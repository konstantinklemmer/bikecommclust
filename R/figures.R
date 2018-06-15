## Prepare libraries
pkgs <- c("igraph","ggplot2","stringr","data.table","mapproj","bit64","ggmap","plyr","gridExtra",
          "sna","RColorBrewer","dplyr","ggraph","ggalluvial","alluvial","forcats","grDevices")
for (pkg in pkgs) {
  if(pkg %in% rownames(installed.packages()) == FALSE) {install.packages(pkg)
    lapply(pkgs, require, character.only = TRUE)}
  else {
    lapply(pkgs, require, character.only = TRUE)}
}
rm(pkg,pkgs)


## Set wd
#setwd("~/YOUR_WD") #Set working directory if needed


## Preparing output data
imapResults <- read.table("https://raw.githubusercontent.com/konstantinklemmer/bikecommclust/master/data/edges.tree",header=F,sep=" ") #Read output tree file 
imapResults <- cbind(imapResults,str_split_fixed(imapResults$V1,":",2)) #Split cluster and index column
imapResults <- imapResults[ -c(1)] #Delete redundant column
colnames(imapResults) <- c("flow","name1","ID","cluster","clusterID") #Name columns
results <- fread("https://raw.githubusercontent.com/konstantinklemmer/bikecommclust/master/data/results.csv",header=TRUE) #Read output of time interval analysis
imapResults <- merge(imapResults,results,by="ID")
imapResults <- imapResults[-c(6)]


## Preparing station data
stations <- fread("https://raw.githubusercontent.com/konstantinklemmer/bikecommclust/master/data/stations.csv",header=TRUE) #Read stations data
stationID <- fread("https://raw.githubusercontent.com/konstantinklemmer/bikecommclust/master/data/stationID.csv",header=TRUE) #Read stations ID 
imapResults <- merge(imapResults,stationID,by.x="ID",by.y="id2",all.x=T) #Merge with community analysis results according to ordering
data <- merge(imapResults,stations,by.x="id1",by.y="id",all.x=TRUE) #Merge final infomap results dataset


## Preparing output data from other community detection methods
communities <- fread("https://raw.githubusercontent.com/konstantinklemmer/bikecommclust/master/data/communities.csv",header=TRUE)
communities$id <- as.numeric(communities$id)
data2 <- merge(data,communities,by.x="id1",by.y="id",all.x=TRUE) #Merge full dataset including infomap and other algorithms


## Figure 1. Location of bikesharing stations in London
box <- c(left=-0.248494683,bottom=51.45038,right=0.009449747,top=51.54651) #Define London boundary box
te <- ggmap(get_googlemap(center=c(lon=-0.118092,lat=51.509865),scale=2,size=c(360,360),zoom=11,maptype="roadmap")) + #Plot stations on Googlemaps
  geom_point(data=data2,alpha=0.7,aes(long,lat),color="red") + #Stations only
  coord_map("mercator") +
  scale_colour_brewer(palette="Set2",name="Infomap") +
  theme_bw()
#ggsave(file="loc.pdf", te)


## Figure 2. Comparison of community detection algorithms: BSS stations are colored according to their respective community assignment across the four techniques
p1 <- ggplot(data2, aes(long,lat)) + #Plot Infomap results
  geom_point(alpha=0.8,aes(color=as.factor(total))) +
  scale_color_brewer(palette="Set2",name="Infomap") +
  scale_fill_brewer(palette="Set2",name=NA) +
  coord_map("mercator") +
  theme_bw()
p2 <- ggplot(data2, aes(long,lat)) + #Plot Louvain results
  geom_point(alpha=0.8,aes(colour=as.factor(louvain))) +
  scale_colour_brewer(palette="Set2",name="Louvain") +
  coord_map("mercator") +
  theme_bw()
p3 <- ggplot(data2, aes(long,lat)) + #Plot Random Walks results
  geom_point(alpha=0.8,aes(colour=as.factor(walks))) +
  scale_colour_brewer(palette="Set2",name="Walks") +
  coord_map("mercator") +
  theme_bw()
p4 <- ggplot(data2, aes(long,lat)) + #Plot Greedy results
  geom_point(alpha=0.8,aes(colour=as.factor(fast_greedy))) +
  scale_colour_brewer(palette="Set2",name="Greedy") +
  coord_map("mercator") +
  theme_bw()

p_comp <- arrangeGrob(p1,p2,p3,p4, nrow=2)  #Arrange plots together
#ggsave(file="comp.pdf", p_comp,width = 10.74, height = 6.1)


## Figure 3.  Interactions and volume of London BSS communities: clusters are mapped at their geographic centroids. 
temp <- tempfile()
download.file("https://raw.githubusercontent.com/konstantinklemmer/bikecommclust/master/data/trips.zip","temp.zip") #Download compressed trip data (35MB)
unzip("temp.zip","trips.csv")
trips <- fread("trips.csv",header=TRUE) #Load all observed trips into R
unlink(temp)
comm_start <- as.data.frame(cbind(data2$id1,data2$total)) #Create community datasets for left_join
colnames(comm_start) <- c("id","StartCluster")
comm_start$id <- as.integer(as.character(comm_start$id))
comm_end <- as.data.frame(cbind(data2$id1,data2$total))
colnames(comm_end) <- c("id","EndCluster")
comm_end$id <- as.integer(as.character(comm_end$id))

trips <- left_join(trips,comm_start,by=c("StartStation Id"="id")) #Left join community information to trip data
trips <- left_join(trips,comm_end,by=c("EndStation Id"="id"))

trips_clust <- as.data.frame(table(trips$StartCluster,trips$EndCluster)) #Table from trips between clusters
clust <- as.data.frame(cbind(unique(trips$StartCluster),trips_clust$Freq[trips_clust$Var1==trips_clust$Var2])) #Unique clusters
colnames(clust) <- c("cluster","self") #Names for cluster attributes

trips_clust <- trips_clust[-c(as.numeric(rownames(trips_clust[trips_clust$Var1==trips_clust$Var2,]))),] #Remove self-link rows
trips_clust$Start <- as.character(trips_clust$Var1)
trips_clust$End <- as.character(trips_clust$Var2)

xy <- data2[,c("total","long","lat")] #Get lat / long of cluster centroids
xy <- na.omit(xy)
xy <- data.table(xy)
x_coord <- xy[,list(long=mean(long)),by="total"] 
y_coord <- xy[,list(lat=mean(lat)),by="total"]
xy <- merge(x_coord,y_coord,by="total")
xy <- xy[order(xy$total)]

g <- graph_from_data_frame(trips_clust, directed=TRUE, vertices=clust) #Create graph from data frames

V(g)$color <- V(g)
V(g)$color=gsub(1,"1",V(g)$color) #Provide cluster colors
V(g)$color=gsub(2,"2",V(g)$color) 
V(g)$color=gsub(3,"3",V(g)$color) 
V(g)$color=gsub(4,"4",V(g)$color) 
V(g)$color=gsub(5,"5",V(g)$color) 
V(g)$color=gsub(6,"6",V(g)$color) 

V(g)$x <- xy$long #Set cluster centroids as coordinates
V(g)$y <- xy$lat

p_comm <- ggraph(g) + #Create community interaction plot
  geom_edge_fan(aes(width=Freq,color=End),alpha=0.5,arrow = arrow(length = unit(2, 'mm'))) + 
  geom_node_point(aes(size=self),color=c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F")
                  ,alpha=0.7) +
  scale_size(range = c(3, 80)) +
  geom_node_text(aes(label=c("Central / East","West","Regents Park","Hyde Park","Notting Hill","Canary Wharf")),lwd=5) +
  scale_edge_width(range = c(0.1, 7)) +
  scale_edge_colour_manual(values = c("#66C2A5", "#8DA0CB", "#FC8D62", "#A6D854","#E78AC3", "#FFD92F")) +
  theme_bw() +
  xlab("long") +
  ylab("lat") +
  theme(legend.position="none")
#ggsave(file="comm.pdf", p_comm,width = 16, height = 6.74)


## Figure 4. Community evolution over time: cluster assignment for each station and hour-of-day is given using color codes

commev <- data2[-c(2:6,31:35,37:49)] #Crop dataset
commev <- commev[,c(26,1:3,14,19:25,4:13,15:18)]
colnames(commev) <- c("long","id1","0h","1h","2h","3h","4h","5h","6h","7h","8h","9h","10h","11h","12h","13h","14h","15h","16h","17h","18h","19h","20h","21h","22h","23h")

comm <- as.data.frame(matrix(ncol=4,nrow=0))
colnames(comm) <- c("long","id","cluster","time")
for (i in 3:ncol(commev)) { #Convert into desired format for plotting
  a <- commev[,c(1:2,i)]
  a$time <- colnames(a)[3]
  colnames(a) <- c("long","id","cluster","time")
  comm <- rbind(comm,a)
}
comm$time <- fct_inorder(comm$time) #Adapt ordering of factor variables
comm$cluster <- as.numeric(as.character(comm$cluster))

p_dyn <- ggplot(data = comm,aes(x = time, stratum = cluster, alluvium=id,fill=cluster)) + #Create alluvial diagram of dynamic cluster assignment
          geom_flow(color = "darkgray",width = 1/1000,linetype="blank") +
          ylab("Station ID") +
          xlab("Time") +
          #scale_fill_manual(palette="rainbow") +
          theme_bw() +
          theme(legend.position="bottom")
#ggsave(file="allu4.pdf", p_dyn,width = 16, height = 6.74)
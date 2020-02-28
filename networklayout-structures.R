library(dtplyr)
library(reshape2)
library(magrittr)
library(igraph)
library(ggplot2)
library(ggraph)

data <- read.csv(file="W:/data/sow2.2-LAAL/MITxPRO-LASERxB1-1T2019/course/MITxPRO+LASERxB1+1T2019-module-lookup.csv",header=T)
data <- data[,c("mod_hex_id","order","treelevel","mod_type","parent","name")]
names(data) <- c("id","order","depth","type","parent","name")

edges <- data[-1,c("parent","id")]
names(edges) <- c("source","target")

g <- graph_from_data_frame(edges,directed=T,vertices=data)


ggraph(g, layout = 'kk') + 
  geom_edge_link() + 
  geom_node_point(aes(colour = factor(type)))

lay <- create_layout(g, layout="partition", circular=T)


#Chord Graph
lay <- create_layout(g, layout="partition", circular=T)
ggraph(lay, 'partition') + 
  geom_node_arc_bar(aes(fill = factor(type)), size = 0.25)


#Circle pack
lay <- create_layout(g, layout="dendrogram")
ggraph(lay, 'dendrogram') + 
  geom_edge_elbow()



# library(dtplyr)
# library(reshape2)
# library(forcats)
# Environment for R
library(magrittr)
library(igraph)
library(ggplot2)
library(ggraph)
library(stringr)
library(colorspace)
library(qualpalr)
library(showtext)

# Load course structure data
data <- read.csv(file="W:/data/sow2.2-LAAL/MITxPRO-LASERxB1-1T2019/course/MITxPRO+LASERxB1+1T2019-module-lookup-n.csv",header=T)
data <- data[,c("mod_hex_id","order","treelevel","mod_type","parent","name")]
names(data) <- c("id","order","depth","type","parent","name")
edges <- data[-1,c("parent","id")]
names(edges) <- c("source","target")

#Network graph and layout
g <- graph_from_data_frame(edges,directed=T,vertices=data)
lay <- create_layout(g, layout="partition",circular=F)
lay$type <- factor(lay$type,levels(factor(lay$type))[c(2,1,9,11,12,4,8,10,3,6,5,7)])

#Enables show text functionality
showtext_auto(enable=T)
#Adds fonts
font_add_google("Nunito","nunito")
font_add_google("Lato","lato")

#Course palette: combine sequential pal for course structure, and qualitative pal for content modules
pal_qual <- qualpal(n=length(levels(data$type)[-c(1:4)]), 
                    colorspace = list(h = c(300,40), 
                                      s = c(0.28, 0.9), 
                                      l = c(0.30, 0.80)))
pal_str <- c(pal_seq_och(6)[4:1],pal_qual$hex[c(1,3,2,4:length(pal_qual$hex))])

#Visualization
ggraph(lay, 'partition') + 
  geom_edge_elbow() +
  geom_node_tile(aes(y = y, fill = type), color="#f5f7ff") +
  geom_text(data=lay[lay$type == c("chapter"),], 
            aes(label = stringr::str_replace(stringr::str_replace(name, "\\: ", "\\:\n"), "\\(.*",""),
                y=y-1.17, 
                x=x-round(width*.499-1.5,0),
                family="nunito"),
            vjust=0.1, hjust=0, size=3.5, colour="#102e47") +
  geom_text(data=lay[lay$type == c("course"),], 
            aes(label = name,
                y=y-.85, 
                x=x-round(width*.499-1.65,0),
                family="nunito"),
            vjust=.01, hjust=0, size=6, colour="#102e47") +
  scale_fill_manual(values=pal_str,
                    labels=c(paste0(c("Course","Chapter","Sequential","Vertical"),rep("\nStr.", 4)),                                    #Structural Modules
                             paste0(stringr::str_to_title(levels(lay$type)[-c(1:4)]),rep("\nMod.", length(levels(lay$type)[-c(1:4)])))) #Content Modules
                    ) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_sqrt(expand = c(0, 0)) +
  guides(fill = guide_legend(title = "Module\nType", 
                             title.position = "left",
                             title.hjust = 0, title.vjust = .8,
                             title.theme = element_text(size = 12, color="#05050b",
                                                        family="nunito", face="bold"),
                             label.hjust = 0.01, label.vjust = 1,
                             label.theme = element_text(size = 9, color="#05050b",
                                                        family="nunito", face="plain"),
                             
                             keyheight = 1.75, keywidth = 1,
                             nrow = 2)) +
  theme(
    plot.background = element_rect("#fafbff"),
    plot.margin = margin(t=10,b=10,l=10,r=10,"pt"),
    panel.background = element_rect("#fafbff"),
    panel.border =  element_rect(color ="#102e47", size = .5, fill = NA),
    legend.background = element_rect("#fafbff"),
    legend.margin = margin(t=0,b=5,l=5,r=0,"pt"),
    legend.text = element_text(size=10),
    legend.position = "bottom",
    legend.justification = c(0,0)
  )
#' print niche network
#'
#' @param nnt    a list contains connectome information of all niches, the result of Dnichenetwork
#' @param file    file names to be saved
#' @param vsize    vertex size
#' @param esize    edge size
#' @param vertex.label.cex    vertex label size
#' @param axes   TorF, if or not draw axes
#' @param width    file size
#' @param height    file size
#' @param weighted    layout caculation parameter
#' @param direction    layout caculation parameter
#'
#' @return    pdf file
#' @import igraph
#' @importFrom scales hue_pal
#' @export
#'
#' @examples
#' print_nichenet(nnt,file="nichenet-w2.pdf",vsize = 10)
print_nichenet<-function(nnt,file="nichenet.pdf",vsize=1,esize=1,
                         vertex.label.cex =1, axes=FALSE,
                         width=7,height=7,weighted=FALSE,direction=FALSE){

  niche.size=nnt[["niche_size"]]
  niche_share=nnt[["niche_interaction"]]
  g <- graph_from_data_frame(niche_share[,1:2], directed = direction)
  # 设置顶点大小
  V(g)$size <- log10(1+niche.size[V(g)$name])  # 通过节点名称匹配大小
  E(g)$size <- log10(1+niche_share[,3])

  nicheID=1:length(V(g)$name)
  names(nicheID)=V(g)$name

  #library(matlab)
  #color_pallete=jet.colors(length(V(g)$name))
  #library(scales)
  color_pallete=hue_pal()(length(V(g)$name))

  pdf(file,width = width,height = height)
  #E(g)$curved <- seq(-0.5, 0.5, length.out=ecount(g))
  #E(g)$curved <- rep( 1, ecount(g))
  # 绘制网络图
  set.seed(666)
  if(weighted){
    lo=layout_with_fr(g,  grid = "nogrid", niter = 100000, weights = E(g)$size)
    #print(lo)
    #print(norm_coords(lo))
  }else{
    lo=layout_with_fr(g, grid = "nogrid", niter = 100000)
  }
  plot(g,
       axes = axes,
       layout = lo,
       vertex.frame.width = 0.5,
       vertex.label = V(g)$name,
       vertex.label.cex = vertex.label.cex,
       edge.arrow.size = 0.2,
       edge.width = esize*E(g)$size,  # 使用 size 作为边的宽度
       vertex.size = vsize*V(g)$size, # 使用 vector 作为顶点大小
       edge.color = "grey",
       vertex.color = color_pallete)
  dev.off()
}

#' print clone network
#'
#' @param nnt a list contains connectome information of all niches, the result of Dnichenetwork
#' @param file pdf file name to be saved
#' @param file_layout file name to save layout of clones
#' @param ilayout file used to set external layout
#' @param highlight whether to hightlight clones for each tag in pdf file
#' @param seed seed for random clone colour setting
#' @param mark_groups igrap parameter
#' @param margin igraph parameter
#' @param vertex.label.cex vertex label size
#' @param vsize vertex size
#' @param esize edge size
#' @param ecolor edge color
#' @param width file size
#' @param height file size
#' @param weighted layout parameter
#' @param direction layout parameter
#' @param niter layout parameter
#' @param axes TorF, if or not draw axes
#'
#' @return df.niche2cloneID
#' @import igraph
#' @importFrom Polychrome createPalette
#' @importFrom scales hue_pal
#' @importFrom stringr str_split_fixed str_split
#' @export
#'
#' @examples
#' print_nichenetwork(nnt,file="nichenetwork-w3-26.pdf",vertex.label.cex=0.1,vsize=1.3,esize=1,ecolor=adjustcolor("grey80", alpha.f = 0.5),mark_groups = T)
#' print_nichenetwork(nnt,file="nichenetwork-w3-27.pdf",vertex.label.cex=0.1,vsize=1.3,esize=1,ecolor=NA,mark_groups = T)
#' print_nichenetwork(nnt,file="nichenetwork-w3-28.pdf",vertex.label.cex=0.1,vsize=1.3,esize=1,ecolor=NA)
#' print_nichenetwork(nnt,file="nichenetwork-w3-29.pdf",vertex.label.cex=0.1,vsize=1.3,esize=1)

print_nichenetwork<-function(nnt,file="nichenetwork.pdf",
                             file_layout="layout.csv",ilayout=NULL,
                             highlight=FALSE,seed=888,
                             mark_groups = FALSE,margin = c(0, 0, 0, 0),
                             vertex.label.cex=1,vsize=1,esize=1,ecolor="grey80",
                             width=7,height=7,
                             weighted=FALSE,direction=FALSE,niter = 100000,
                             axes=FALSE){
  shareData2=nnt[["clone_interaction"]]
  clone.size=nnt[["clone_size"]]
  celltypes=nnt[["code2celltype"]]
  niche=nnt[["niche"]]
  #将互作clone分开
  shareCloneAB=as.data.frame(str_split_fixed(shareData2$clonePair,"-",n=2))
  #shareData3=data.frame(c1=shareCloneAB[,1],c2=shareCloneAB[,2],edge)
  #取出所有包含交叉的clone,无互作的克隆不在igraph图中显示
  #shareCloneID=unique(c(shareCloneAB[,1],shareCloneAB[,2]))#correction2
  #包含交叉的clone的size用其中的细胞数表示
  #shareCloneSize=clone.size[shareCloneID]#correction2
  #将shareCloneID，shareCloneSize等作为输出结果输出到list
  #使用igraph画clone互作network，input是shareCloneAB，shareData2$share，shareCloneSize
  # 创建图对象
  g <- graph_from_data_frame(d=shareCloneAB, vertices=names(nnt[["cloneID"]]),directed = direction)#correction1
  if(identical(V(g)$name,names(nnt[["cloneID"]]))){
     print("Identical")
     cloneID=nnt[["cloneID"]]
   }else{
     cloneID=nnt[["cloneID"]][V(g)$name]
   }
  #cloneID=1:length(V(g)$name)
  #names(cloneID)=V(g)$name
  #niche2cloneID=lapply(niche,function(x){cloneID[intersect(names(x),names(cloneID))]})
  #newniche=lapply(niche,function(x){x[intersect(names(x),names(cloneID))]})
  # 设置顶点大小
  V(g)$size <- vsize*log10(1+clone.size[V(g)$name])  # 通过节点名称匹配大小correction3
  #E(g)$size <- log2(1+shareData2$share)
  E(g)$size <- shareData2$share

  pdf(file,width = width,height = height)
  last_code<- str_split_fixed(V(g)$name, "_",n=2)[,2]
  set.seed(seed)
  color_pallete <- createPalette(nchar(last_code[1]),
                                 seedcolors = c("#E69F00" ,"#56B4E9" ,"#009E73", "#F0E442", "#0072B2", "#D55E00","#CC79A7"))
  char_vectors <- strsplit(last_code, split = "")
  #print(char_vectors)
  clone_df=sapply(char_vectors,as.integer)
  vcolors=apply(clone_df,2,function(x){color_pallete[as.logical(x)]})
  #clone_cluster=apply(clone_df,2,function(x){nnt[["code2celltype"]][as.logical(x)]})
  # 绘制网络图
  if(is.null(ilayout)){
    set.seed(seed)
    if(weighted){
      lo=layout_with_fr(g,  grid = "nogrid", niter = niter, weights = E(g)$size)
      #print(lo)
      #print(norm_coords(lo))
    }else{
      lo=layout_with_fr(g, grid = "nogrid", niter = niter)
    }
  }else{
    lo=as.matrix(ilayout)
  }
  write.csv(lo,file = file_layout,row.names=F)
  if(mark_groups){
    #library(Polychrome)
    first_code <-str_split_fixed(V(g)$name, "_",n=2)[,1]
    char_vectors <- strsplit(first_code, split = "")
    clone_df=as.data.frame(sapply(char_vectors,as.integer))
    colnames(clone_df)=1:ncol(clone_df)
    clone_1tag=clone_df[,which(apply(clone_df,2,sum)==1)]
    clone_tag=apply(clone_1tag,2,function(x){nnt[["code2tag"]][as.logical(x)]})
    clone1tag_list=list()
    for(tag in nnt[["code2tag"]]){
      clone1tag_list[[tag]]=as.integer(names(clone_tag[clone_tag==tag]))
    }
    mark.groups=clone1tag_list[sapply(clone1tag_list,length)>0]
    #library(scales)
    mark.col=hue_pal()(length(clone1tag_list))
  }else{
    mark.groups = list()
    mark.col = rainbow(length(mark.groups), alpha = 0.3)
  }

  plot(g,
       axes = axes,
       layout = lo,
       mark.groups = mark.groups,
       mark.col=mark.col,
       #mark.border=mark.colors,
       mark.shape =1/2,
       vertex.frame.width = 0.5,
       vertex.label = cloneID,
       vertex.label.cex = vertex.label.cex,
       edge.arrow.size = 0.2,
       edge.width = esize*log10(1+E(g)$size),  # 使用 size 作为边的宽度
       vertex.size = V(g)$size, # 使用 vector 作为顶点大小
       edge.color = ecolor,
       vertex.color = vcolors,
       margin = margin
  )

  legend("topleft", legend = celltypes,col = color_pallete,pch = 21, pt.bg = color_pallete, pt.cex = 1,cex = 0.5,bty = "n")

  if(mark_groups){legend("topright", legend = names(clone1tag_list),col = mark.col,
                         pch = 21, pt.bg = mark.col, pt.cex = 1,cex = 0.5,bty = "n")}
  if(highlight==T){
    nichetags=names(nnt$niche)[sapply(nnt$niche,length)>0]
    for(tag in nichetags){
      vcolors2=vcolors
      vcolors2[!(V(g)$name %in% names(nnt[["niche"]][[tag]]))]="grey80"
      subtitle=paste(cloneID[(V(g)$name %in% names(nnt[["niche"]][[tag]]))],collapse=",")
      #print(tag)
      #print(sum(V(g)$name %in% names(nnt[["niche"]][[tag]])))
      plot(g,
	   main=tag,sub=subtitle,
           axes = axes,
           layout = lo,
           mark.groups = mark.groups,
           mark.col=mark.col,
           #mark.border=mark.colors,
           mark.shape =1/2,
           vertex.frame.width = 0.5,
           vertex.label = cloneID,
           vertex.label.cex = vertex.label.cex,
           edge.arrow.size = 0.2,
           edge.width = esize*log10(1+E(g)$size),  # 使用 size 作为边的宽度
           vertex.size = V(g)$size, # 使用 vector 作为顶点大小
           edge.color = ecolor,
           vertex.color = vcolors2,
           margin = margin
      )
      legend("topleft", legend = celltypes,col = color_pallete,pch = 21, pt.bg = color_pallete, pt.cex = 1,cex = 0.5,bty = "n")
    }
  }
  dev.off()

  #df.niche2cloneID=data.frame()
  #for(name in names(niche2cloneID)){
   # if(length(newniche[[name]])>0){
    #  df=data.frame(tag=name,tagnum=newniche[[name]],
     #               cloneID=niche2cloneID[[name]],
      #              code=names(niche2cloneID[[name]]))
      #df.niche2cloneID=rbind(df.niche2cloneID,df)
    #}
  #}
  #rownames(df.niche2cloneID)=NULL
  #return(lo)
}



#' print tag vs cell number and types
#'
#' @param nnt a list contains connectome information of all niches, the result of Dnichenetwork
#' @param file pdf
#'
#' @return pdf
#' @import ggplot2
#' @import cowplot
#' @export
#'
#' @examples
#' print_nichetag(nnt)
print_nichetag<-function(nnt,file="nichetag.pdf"){
  #library(cowplot)
  niche2tagnum=nnt[["niche_tags"]]
  niche2cellnum=nnt[["niche_size"]]
  niche2typenum=nnt[["niche_celltypes"]]
  data0=data.frame(celltag=names(niche2tagnum),tagnumber=log10(niche2tagnum))
  data0$celltag=factor(data0$celltag,levels = data0$celltag)
  data1=data.frame(celltag=names(niche2cellnum),cellnumber=niche2cellnum)
  data1$celltag=factor(data1$celltag,levels = data1$celltag)
  data2=data.frame(celltag=names(niche2typenum),celltypes=niche2typenum)
  data2$celltag=factor(data2$celltag,levels = data2$celltag)
  p0 <- ggplot(data0, aes(x = celltag, y =tagnumber)) +
    geom_bar(stat = "identity", fill = "skyblue") +
    theme_minimal(base_size = 7) + ylab("log10(tagnumber)")+
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  p1 <- ggplot(data1, aes(x = celltag, y =cellnumber)) +
    geom_bar(stat = "identity", fill = "skyblue") +
    theme_minimal(base_size = 7) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  p2 <- ggplot(data2, aes(x = celltag, y =celltypes)) +
    geom_bar(stat = "identity", fill = "skyblue") +
    theme_minimal(base_size = 7) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  pg=plot_grid(p0,p1,p2,ncol=1,nrow = 3,hjust = "hv")
  ggsave(plot = pg,filename=file)
}


#' print cluster vs tag number and types
#'
#' @param nnt a list contains connectome information of all niches, the result of Dnichenetwork
#' @param file pdf
#'
#' @return pdf
#' @import ggplot2
#' @import cowplot
#' @export
#'
#' @examples
#' print_clustertag(nnt)
print_clustertag<-function(nnt,file="clustertag.pdf"){
  tag_expression=nnt[["tag_matrix"]]
  cell_clusters=droplevels(nnt[["cell_type"]])
  plot.list=list()
  for (cluster_id in unique(cell_clusters)){
    print(cluster_id)
    cluster_cells <- names(cell_clusters)[cell_clusters == cluster_id]
    tag_expression_cluster <- tag_expression[cluster_cells, ]
    tag_counts_per_cell <- rowSums(tag_expression_cluster)
    unique_tag_counts  <- rowSums(tag_expression_cluster > 0)
    tag_counts_df <- data.frame(
      tag_count = tag_counts_per_cell,
      unique_tag_count = unique_tag_counts)
    tag_count_plot <- ggplot(tag_counts_df, aes(x = tag_count)) +
      geom_density(fill = "blue", alpha = 0.5) +
      labs(title = cluster_id,
           x = "Number of Tags per Cell",
           y = "Density") +
      theme_minimal()
    plot.list[[paste0(cluster_id,"_1")]]=tag_count_plot
    unique_tag_count_plot <- ggplot(tag_counts_df, aes(x = unique_tag_count)) +
      geom_density(fill = "red", alpha = 0.5) +
      labs(title = cluster_id,
           x = "Kinds of Tags per Cell",
           y = "Density") +
      theme_minimal()
    plot.list[[paste0(cluster_id,"_2")]]=unique_tag_count_plot
  }
  #library(cowplot)
  pg=plot_grid(plotlist = plot.list,ncol=2,align = "hv")
  ggsave(plot = pg,filename = file,height = 1.5*length(unique(cell_clusters)),limitsize = F)
}


#' print cancer and non-maligant cell numbers for each tag
#'
#' @param nnt a list contains connectome information of all niches, the result of Dnichenetwork
#' @param file pdf
#'
#' @return pdf
#' @importFrom stringr str_detect
#' @importFrom reshape2 melt
#' @import ggplot2
#' @export
#'
#' @examples
#' tag_cancer_noncancer(nnt)
tag_cancer_noncancer<-function(nnt,file="tag2celltypes.pdf"){
  tag_expression=nnt[["tag_matrix"]]
  cell_clusters=droplevels(nnt[["cell_type"]])
  niche=apply(tag_expression,2,function(x){x[x>0]})
  #cancer_noncancer=ifelse(str_detect(tolower(cell_clusters),"cancer"),"cancer","noncancer")
  cancer=names(cell_clusters)[str_detect(tolower(cell_clusters),"cancer")]
  noncancer=names(cell_clusters)[!str_detect(tolower(cell_clusters),"cancer")]
  corn=function(x){
    a=sum(names(x) %in% cancer)
    b=sum(names(x) %in% noncancer)
    c=c(a,b)
    names(c)=c("cancer","noncancer")
    c
  }
  niche_celltype=as.data.frame(t(sapply(niche,corn)))
  niche_celltype$tag=rownames(niche_celltype)
  #library(reshape2)
  #library(ggplot2)
  data=melt(niche_celltype)
  data$tag=factor(data$tag,levels = niche_celltype$tag)
  gp=ggplot(data, aes(x = tag, y = value, fill =variable )) +
    geom_bar(stat = "identity") +theme_minimal(base_size = 7)+
    labs(x = "Tag Sequence", y = "Cell Count", fill = "Category") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),legend.position = "top")+
    scale_fill_manual(values = c("#0072B2","#009E73"))
  ggsave(plot=gp,filename=file,height = 3,width = 7)
}

#' print sender and receiver cell numbers for each tag, cutoff is 3
#'
#' @param nnt a list contains connectome information of all niches, the result of Dnichenetwork
#' @param file pdf
#'
#' @return pdf
#' @importFrom reshape2 melt
#' @import ggplot2
#' @export
#'
#' @examples
#' tag_cci(nnt)
tag_cci<-function(nnt,file="tag2ccitypes.pdf"){
  tag_expression=nnt[["tag_matrix"]]
  cell_clusters=droplevels(nnt[["cell_type"]])
  niche=apply(tag_expression,2,function(x){x[x>0]})
  #cancer_noncancer=ifelse(str_detect(tolower(cell_clusters),"cancer"),"cancer","noncancer")
  sorr=function(x){
    a=sum(x>3)
    b=sum(x<=3)
    c=c(a,b)
    names(c)=c("sender","receiver")
    c
  }
  niche_celltype=as.data.frame(t(sapply(niche,sorr)))
  niche_celltype$tag=rownames(niche_celltype)
  #library(reshape2)
  #library(ggplot2)
  data=melt(niche_celltype)
  data$tag=factor(data$tag,levels = niche_celltype$tag)
  gp=ggplot(data, aes(x = tag, y = value, fill =variable )) +
    geom_bar(stat = "identity") +theme_minimal(base_size = 7)+
    labs(x = "Tag Sequence", y = "Cell Count", fill = "Category") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),legend.position = "top")+
    scale_fill_manual(values = c("#009E73","#E69F00"))
  ggsave(plot=gp,filename=file,height = 3,width = 7)
}

#' print clone type distribution for each niche
#'
#' @param nnt a list contains connectome information of all niches, the result of Dnichenetwork
#' @param file pdf
#'
#' @return pdf
#' @import cowplot
#' @import ggplot2
#' @export
#'
#' @examples
#' clonetype(nnt)
clonetype<-function(nnt,file="clonetype.pdf"){
  niche2clone=nnt$niche
  niche2clone.vec=unlist(lapply(names(niche2clone),function(x){
    res=paste(x,names(niche2clone[[x]]),sep=":")
    res
  }))
  niche2clone.df=as.data.frame(stringr::str_split_fixed(niche2clone.vec,":",n=2))
  colnames(niche2clone.df) = c("niche","clone_code")
  niche2clone.df$clone_ID=nnt$cloneID[niche2clone.df$clone_code]
  niche2clone.df$celltype=codesplit(niche2clone.df$clone_code,nnt[["code2tag"]],nnt[["code2celltype"]])$types
  clone2celltype=as.data.frame(sort(table(niche2clone.df$celltype),decreasing=T))
  plot.list=list()
  for(tag in names(niche2clone)){  
    df=niche2clone.df[niche2clone.df$niche==tag,]
    data=as.data.frame(table(df$celltype))
    data2=data.frame(Var1=setdiff(clone2celltype$Var1,data$Var1),Freq=0)
    data=rbind(data,data2)
    data$Var1=factor(data$Var1,levels=clone2celltype$Var1)
    plot.list[[tag]]<- ggplot(data, aes(x = Var1, y =Freq)) +
      geom_bar(stat = "identity", fill = "skyblue") +
      theme_minimal(base_size = 6) + ylab("Number")+ xlab(tag)+
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  }
  pg=plot_grid(plotlist = plot.list,ncol=1,align = "hv")
  ggsave(plot=pg,filename=file,
         height =length(unique(niche2clone.df$niche)),
         width = length(levels(clone2celltype$Var1))/5,
         limitsize = FALSE)
}


#' print cell type and clone type distribution for each niche
#'
#' @param nnt a list contains connectome information of all niches, the result of Dnichenetwork
#' @param file pdf
#'
#' @return pdf
#' @import cowplot
#' @import ggplot2
#' @import reshape2
#' @export
#'
#' @examples
#' tag_cellclonetype(nnt)
tag_cellclonetype<-function(nnt,file="tag2celltype_clonetype.pdf",seed=888){
  tag_expression=nnt[["tag_matrix"]]
  #tag_expression=tag_expression[apply(tag_expression,1,sum)>0,]
  cell_clusters=droplevels(nnt[["cell_type"]])
  set.seed(seed)
  color_pallete <- createPalette(length(levels(cell_clusters)),
                                 seedcolors = c("#E69F00" ,"#56B4E9" ,"#009E73", "#F0E442", "#0072B2", "#D55E00","#CC79A7"))
  names(color_pallete)=NULL
  niche=apply(tag_expression,2,function(x){x[x>0]})
  niche_celltype=as.data.frame(t(sapply(niche,function(x){table(cell_clusters[names(x)])})))
  niche_celltype$tag=rownames(niche_celltype)
  #library(reshape2)
  #library(ggplot2)
  #library(cowplot)
  data=melt(niche_celltype)
  data$tag=factor(data$tag,levels = niche_celltype$tag)
  gp1=ggplot(data, aes(x = tag, y = value, fill =variable )) +
    geom_bar(stat = "identity") +theme_minimal(base_size = 7)+
    labs(x = "Tag Sequence", y = "Cell Count", fill = "Category") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),legend.position = "top")+
    scale_fill_manual(values = color_pallete)+
    theme(
      legend.text = element_text(size = 6),        # 图例文字大小
      legend.title = element_text(size = 7),       # 图例标题大小（可选）
      legend.key.size = unit(0.2, "cm")            # 图例图形大小
    )

  clones=names(nnt$cloneID)
  clone_types=codesplit(clones,nnt[["code2tag"]],nnt[["code2celltype"]])$types
  clone_types=factor(clone_types,levels =nnt[["code2celltype"]])
  names(clone_types)=clones

  set.seed(seed)
  color_pallete <- createPalette(length(levels(clone_types)),
                                 seedcolors = c("#E69F00" ,"#56B4E9" ,"#009E73", "#F0E442", "#0072B2", "#D55E00","#CC79A7"))
  names(color_pallete)=NULL
  niche=nnt$niche
  niche_clonetype=as.data.frame(t(sapply(niche,function(x){table(clone_types[names(x)])})))
  niche_clonetype$tag=rownames(niche_clonetype)
  data=melt(niche_clonetype)
  data$tag=factor(data$tag,levels = niche_clonetype$tag)
  gp2=ggplot(data, aes(x = tag, y = value, fill =variable )) +
    geom_bar(stat = "identity") +theme_minimal(base_size = 7)+
    labs(x = "Tag Sequence", y = "Clone Count", fill = "Category") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),legend.position = "top")+
    scale_fill_manual(values = color_pallete)+
    theme(
      legend.text = element_text(size = 6),        # 图例文字大小
      legend.title = element_text(size = 7),       # 图例标题大小（可选）
      legend.key.size = unit(0.2, "cm")            # 图例图形大小
    )
  pg=plot_grid(gp1,gp2,ncol=1,align = "hv")
  ggsave(plot=pg,filename=file,height = 7,width = 7)
}

# nichetags install guide
you can install it from github:

```
install.packages(c("Seurat","Polychrome","stringdist","stringr","ggplot2","cowplot","igraph","openxlsx"))
if(!require(devtools)){
	install.packages("devtools")
}
if(!require(nichetag)){
	library(devtools)
	install_github("woshijiaomu/nichetag")
}
```

after installation，attach the package in R：

```
library(nichetag)
```

Quick Start Guide：

```
#attach R package,load sample data
library(nichetag)
data(example)

#calculate connectome
nnt=Dnichenetwork(scObject,groupby="cell_clusters")
summary(nnt)

#draw clone-clone network
print_nichenetwork(nnt,file="nichenetwork.pdf",vertex.label.cex=0.1,vsize=3,esize=1,margin=c(0,0.3,0,0))

#draw quanlity control figures
print_nichetag(nnt, file = "nichetag.pdf")
print_clustertag(nnt, file = "cluster.pdf")
tag_cancer_noncancer(nnt, file = "celltype.pdf")
tag_cci(nnt, file = "cci.pdf")
clonetype(nnt, file="clonetype.pdf")
tag_cellclonetype(nnt, file="tag2celltype_clonetype.pdf")
#draw niche-niche network
print_nichenet(nnt,file="niche2nichenetwork.pdf",vsize = 10)

#clones and the cells it contains
clone2cell=nnt$clone
clone2cell.vec=unlist(lapply(names(clone2cell),function(x){
  y=clone2cell[[x]]
  res=rep(x,nrow(y))
  names(res)=rownames(y)
  res
}))
clone2cell.df=data.frame(clone_code=clone2cell.vec,cell=names(clone2cell.vec))
clone2cell.df$clone_ID=nnt$cloneID[clone2cell.df$clone_code]
write.csv(clone2cell.df,file = "clone2cell.csv")

#niches and the clones it contains
niche2clone=nnt$niche
niche2clone.vec=unlist(lapply(names(niche2clone),function(x){
  res=paste(x,names(niche2clone[[x]]),sep=":")
  res
}))
niche2clone.df=as.data.frame(stringr::str_split_fixed(niche2clone.vec,":",n=2))
colnames(niche2clone.df) = c("niche","clone_code")
niche2clone.df$clone_ID=nnt$cloneID[niche2clone.df$clone_code]
write.csv(niche2clone.df,file = "niche2clone.csv")

#nnt=nichenetwork(tag_expression,cell_clusters,share_method="mean")
#dnnt=Dnichenetwork(tag_expression,cell_clusters,direction = T)




# nichetag: Reconstruction of Spatial and Lineage Relationships from CellTag-labeled Single-cell Data

**Author:** Dekang Lv  
**Date:** May 2025  

---

## Introduction

Thank you for your interest in the **nichetag** approach.  
This guide describes how to apply the package to your intercellular RNA-barcode delivery experiment (*Multiplexed Oligonucleotide Spatial Ancestry Interaction Coding*, **MOSAIC**).  

MOSAIC utilizes conditionally expressed, proximally transmissible `sLP-mCherry-MCP-MS2-CellTag` barcodes to trace the spatiotemporal lineages and communicating networks within intact tissues at single-cell resolution.  

The goal of the **nichetag** package is to use CellTag labels from single-cell transcriptomics data to reconstruct the lineage and spatial proximity relationships of mCherry-positive cells.  

To learn more about this type of experiment and details about the **nichetag** approach, please consult  
👉 *Bin et al., 2025* ([insert paper URL here]).

This vignette covers:

1. Package installation  
2. Setting up your input data  
3. Running the `nichetag` computational pipeline  
4. Exporting data and session information  

---

## 1. Package Installation

You can install the package and dependencies using:

```r
# Install dependencies
install.packages(c("Seurat", "Polychrome", "stringdist", "stringr",
                   "ggplot2", "cowplot", "igraph", "openxlsx"))

if (!require(devtools)) {
  install.packages("devtools")
}

# Install nichetag from GitHub
if (!require(nichetag)) {
  devtools::install_github("woshijiaomu/nichetag")
}


#draw clone expression matrix
clonematrix=Clone_expr(scObject,nnt,seurat_layer="counts")
write.csv(clonematrix,"clone_matrix.csv")

```

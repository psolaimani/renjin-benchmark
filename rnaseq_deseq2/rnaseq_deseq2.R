# Parham Solaimani
# This RNA-Seq analysis workflow has been published (DOI: 10.12688/f1000research.7035.1)
# and included as Bioconductor workflow: "RNA-Seq workflow: gene-level exploratory analysis and differential expression"

##### set up session #####
set.seed(1000)

##### loading packages #####
library("Rsamtools")
library("GenomicFeatures")
library("GenomicAlignments")
library("BiocParallel")
library("DESeq2")
library("pheatmap")
library("RColorBrewer")
library("PoiClaClu")
library("ggplot2")
library("genefilter")
library("AnnotationDbi")
library("org.Hs.eg.db")
#library("ReportingTools")
library("Gviz")
library("fission")
library("sva")
library("fission")

##### Set global vars #####
files = list.files(path = ".", pattern = "txt$")

##### Blocks for timing #####
do.load <-function(){

  # Read in bam-files
  csvfile     <- "sample_table.csv"
  sampleTable <- read.csv(csvfile,row.names=1)
  filenames   <- paste0(sampleTable$Run, "_subset.bam")
  file.exists(filenames)
  bamfiles    <- BamFileList(filenames, yieldSize=2000000)
  seqinfo(bamfiles[1])

  # Make annotation database summerized at gene level
  gtffile <- file.path(DATA_DIR,"Homo_sapiens.GRCh37.75_subset.gtf")
  txdb    <- makeTxDbFromGFF(gtffile, format="gtf", circ_seqs=character())
  ebg <- exonsBy(txdb, by="gene")

  # Compute fragment counts per gene per sample
  register(SerialParam())
  se <- summarizeOverlaps(features=ebg, reads=bamfiles,
                          mode="Union",
                          singleEnd=FALSE,
                          ignore.strand=TRUE,
                          fragments=TRUE )
  # Extrapolatory analysis of data
  if(EXPRESSIVE){
  dim(se)
  assayNames(se)
  head(assay(se), 3)
  colSums(assay(se))
  rowRanges(se)
  str(metadata(rowRanges(se)))
  colData(se)
  }

  # Add meta information to summary
  # Print forces Renjin to compute
  colData(se) <- DataFrame(sampleTable)

  return(se)
}

do.deseq2 <- function(DATA){
  se <- DATA
  if(EXPRESSIVE){
    se$cell
    se$dex
  }
  se$dex <- relevel(se$dex, "untrt")
  if(EXPRESSIVE){
    se$dex
    round( colSums(assay(se)) / 1e6, 1 )
    colData(se)
  }
  dds <- DESeqDataSet(se, design = ~ cell + dex)
  countdata <- assay(se)
  if(EXPRESSIVE){
    head(countdata, 3)
  }
  coldata <- colData(se)
  ddsMat <- DESeqDataSetFromMatrix(countData = countdata,
                                  colData = coldata,
                                  design = ~ cell + dex)

  return(list(se,dds,ddsMat))
}

do.deseq2.explr <- function(DATA){
  se <- DATA[[1]]
  dds <- DATA[[2]]
  ddsMat <- DATA[[3]]
   # Performs exploratory analysis using deseq2 output
   if(EXPRESSIVE){
     nrow(dds)
   }
   dds <- dds[ rowSums(counts(dds)) > 1, ]
   rld <- rlog(dds, blind=FALSE)
   head(assay(rld), 3)

   # Scatterplot of transformed counts from two samples
   par( mfrow = c( 1, 2 ) )
   dds <- estimateSizeFactors(dds)
   plot(log2(counts(dds, normalized=TRUE)[,1:2] + 1), pch=16, cex=0.3)
   plot(assay(rld)[,1:2], pch=16, cex=0.3)

   # Calculate sample distances
   sampleDists <- dist( t( assay(rld) ) )
   sampleDistMatrix <- as.matrix( sampleDists )
   rownames(sampleDistMatrix) <- paste( rld$dex, rld$cell, sep="-" )
   colnames(sampleDistMatrix) <- NULL
   colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
   pheatmap(sampleDistMatrix,
         clustering_distance_rows=sampleDists,
         clustering_distance_cols=sampleDists,
         col=colors)

  # Heatmap of sample-to-sample distances using the rlog-transformed values.
   poisd <- PoissonDistance(t(counts(dds)))
   samplePoisDistMatrix <- as.matrix( poisd$dd )
   rownames(samplePoisDistMatrix) <- paste( rld$dex, rld$cell, sep="-" )
   colnames(samplePoisDistMatrix) <- NULL
   pheatmap(samplePoisDistMatrix,
         clustering_distance_rows=poisd$dd,
         clustering_distance_cols=poisd$dd,
         col=colors)

   # PCA plot
   plotPCA(rld, intgroup = c("dex", "cell"))

   # PCA plot using the rlog-transformed values
   data <- plotPCA(rld, intgroup = c( "dex", "cell"), returnData=TRUE)
   percentVar <- round(100 * attr(data, "percentVar"))

   ggplot(data, aes(PC1, PC2, color=dex, shape=cell)) +
        geom_point(size=3) +
        xlab(paste0("PC1: ",percentVar[1],"% variance")) +
        ylab(paste0("PC2: ",percentVar[2],"% variance"))

  # MDS plot
  mdsData <- data.frame(cmdscale(sampleDistMatrix))
  mds <- cbind(mdsData, as.data.frame(colData(rld)))
  ggplot(mds, aes(X1,X2,color=dex,shape=cell)) + geom_point(size=3)

  #MDS plot using rlog-transformed values
  mdsPoisData <- data.frame(cmdscale(samplePoisDistMatrix))
  mdsPois <- cbind(mdsPoisData, as.data.frame(colData(dds)))
  ggplot(mdsPois, aes(X1,X2,color=dex,shape=cell)) + geom_point(size=3)
  return(list(dds,rld))
 }

do.deseq2.diffexp <- function(DATA){
   # Running the differential expression pipeline
   #
   dds <- DATA[[1]]
   rld <- DATA[[2]]
   dds <- DESeq(dds)
   res <- results(dds)
   mcols(res, use.names=TRUE)
   if(EXPRESSIVE){
     summary(res)
   }
   res.05 <- results(dds, alpha=.05)
   table(res.05$padj < .05)
   resLFC1 <- results(dds, lfcThreshold=1)
   if(EXPRESSIVE){
     table(resLFC1$padj < 0.1)
     results(dds, contrast=c("cell", "N061011", "N61311"))
     sum(res$pvalue < 0.05, na.rm=TRUE)
     sum(!is.na(res$pvalue))
     sum(res$padj < 0.1, na.rm=TRUE)
   }
   resSig <- subset(res, padj < 0.1)
   if(EXPRESSIVE){
     #head(resSig[ order(resSig$log2FoldChange), ])
     #head(resSig[ order(resSig$log2FoldChange, decreasing=TRUE), ])
   }

   ## Plotting results
   topGene <- rownames(res)[which.min(res$padj)]
   plotCounts(dds, gene=topGene, intgroup=c("dex"))
   data <- plotCounts(dds, gene=topGene, intgroup=c("dex","cell"), returnData=TRUE)

   # Normalized counts for a single gene over treatment group.
   ggplot(data, aes(x=dex, y=count, color=cell)) +
        scale_y_log10() +
        geom_point(position=position_jitter(width=.1,height=0), size=3)

   # Normalized counts indicating cell line with color.
   ggplot(data, aes(x=dex, y=count, fill=dex)) +
        scale_y_log10() +
        geom_dotplot(binaxis="y", stackdir="center")

   # Normalized counts using a more structural arrangement.
   ggplot(data, aes(x=dex, y=count, color=cell, group=cell)) +
  scale_y_log10() + geom_point(size=3) + geom_line()
  # Normalized counts with lines connecting cell lines.
  plotMA(res, ylim=c(-5,5))

  # An MA-plot of changes induced by treatment.
  if(EXPRESSIVE){
    plotMA(resLFC1, ylim=c(-5, 5))
  }
  topGene <- rownames(resLFC1)[which.min(resLFC1$padj)]
  with(resLFC1[topGene, ], {
    points(baseMean, log2FoldChange, col="dodgerblue", cex=2, lwd=2)
    text(baseMean, log2FoldChange, topGene, pos=2, col="dodgerblue")
  })

  # An MA-plot of a test for large log2 fold changes.
  hist(res$pvalue[res$baseMean > 1], breaks=0:20/20, col="grey50", border="white")

  # Gene clustering
  topVarGenes <- head(order(rowVars(assay(rld)),decreasing=TRUE),20)
  mat <- assay(rld)[ topVarGenes, ]
  mat <- mat - rowMeans(mat)
  df <- as.data.frame(colData(rld)[,c("cell","dex")])
  pheatmap(mat, annotation_col=df)

  # Independent filtering
  qs <- c(0, quantile(resLFC1$baseMean[resLFC1$baseMean > 0], 0:6/6))
  bins <- cut(resLFC1$baseMean, qs)
  levels(bins) <- paste0("~",round(signif(.5*qs[-1] + .5*qs[-length(qs)],2)))
  ratios <- tapply(resLFC1$pvalue, bins, function(p) mean(p < .05, na.rm=TRUE))
  barplot(ratios, xlab="mean normalized count", ylab="ratio of small p values")

  ## Annotating and exporting results
  columns(org.Hs.eg.db)

  res$symbol <- mapIds(org.Hs.eg.db,
                     keys=row.names(res),
                     column="SYMBOL",
                     keytype="ENSEMBL",
                     multiVals="first")

  res$entrez <- mapIds(org.Hs.eg.db,
                     keys=row.names(res),
                     column="ENTREZID",
                     keytype="ENSEMBL",
                     multiVals="first")

  # Exporting results
  resOrdered <- res[order(res$padj),]
  head(resOrdered)
  resOrderedDF <- as.data.frame(resOrdered)[1:100,]
  if(EXPRESSIVE){
    write.csv(resOrderedDF, file="results.csv")
    htmlRep <- HTMLReport(shortName="report", title="My report", reportDirectory="./report")
    publish(resOrderedDF, htmlRep)
    url <- finish(htmlRep)
    browseURL(url)
  }
  # Plotting fold changes in genomic space
  resGR <- results(dds, lfcThreshold=1, format="GRanges")
  resGR$symbol <- mapIds(org.Hs.eg.db, names(resGR), "SYMBOL", "ENSEMBL")
  window <- resGR[topGene] + 1e6
  strand(window) <- "*"
  resGRsub <- resGR[resGR %over% window]
  naOrDup <- is.na(resGRsub$symbol) | duplicated(resGRsub$symbol)
  resGRsub$group <- ifelse(naOrDup, names(resGRsub), resGRsub$symbol)
  sig <- factor(ifelse(resGRsub$padj < .1 & !is.na(resGRsub$padj),"sig","notsig"))
  g <- GenomeAxisTrack()
  a <- AnnotationTrack(resGRsub, name="gene ranges", feature=sig)
  d <- DataTrack(resGRsub, data="log2FoldChange", baseline=0, type="h", name="log2 fold change", strand="+")
  plotTracks(list(g,d,a), groupAnnotation="group", notsig="grey", sig="hotpink")


  # Removing hidden batch effects
  dat <- counts(dds, normalized=TRUE)
  idx <- rowMeans(dat) > 1
  dat <- dat[idx,]
  mod <- model.matrix(~ dex, colData(dds))
  mod0 <- model.matrix(~ 1, colData(dds))
  svseq <- svaseq(dat, mod, mod0, n.sv=2)
  svseq$sv
  # Surrogate variables 1 and 2 plotted over cell line
  par(mfrow=c(2,1),mar=c(3,5,3,1))
  stripchart(svseq$sv[,1] ~ dds$cell,vertical=TRUE,main="SV1")
  abline(h=0)
  stripchart(svseq$sv[,2] ~ dds$cell,vertical=TRUE,main="SV2")
  abline(h=0)

  ddssva <- dds
  ddssva$SV1 <- svseq$sv[,1]
  ddssva$SV2 <- svseq$sv[,2]
  design(ddssva) <- ~ SV1 + SV2 + dex
  ddssva <- DESeq(ddssva)
  str(ddssva)
  return(ddssva)
 }

do.deseq2.timecrs <- function(){
   ## Time course experiments
   data("fission")
   ddsTC <- DESeqDataSet(fission, ~ strain + minute + strain:minute)


   ddsTC <- DESeq(ddsTC, test="LRT", reduced = ~ strain + minute)
   resTC <- results(ddsTC)
   resTC$symbol <- mcols(ddsTC)$symbol
   head(resTC[order(resTC$padj),],4)

   data <- plotCounts(ddsTC, which.min(resTC$padj), intgroup=c("minute","strain"), returnData=TRUE)
   ggplot(data, aes(x=minute, y=count, color=strain, group=strain)) +
         geom_point() +
         stat_smooth(se=FALSE,method="loess") +
         scale_y_log10()

  resultsNames(ddsTC)

  betas <- coef(ddsTC)
  colnames(betas)

  topGenes <- head(order(resTC$padj),20)
  mat <- betas[topGenes, -c(1,2)]
  thr <- 3
  mat[mat < -thr] <- -thr
  mat[mat > thr] <- thr
  pheatmap(mat, breaks=seq(from=-thr, to=thr, length=101), cluster_col=FALSE)

 }

############################################################################
################### TIMING AND REPORTING ###################################
############################################################################

DATA <- do.load(DATA_DIR)

DATA <- do.deseq2(DATA)

DATA <- do.deseq2.explr(DATA)

DATA <- do.deseq2.diffexp(DATA)

do.deseq2.timecrs()

# final clean up
rm(list=ls())
gc()

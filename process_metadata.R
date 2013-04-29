# create filelist like this:
# find . -name "*.png" |cut -c3- >  flist.txt
# compare like this:
# comm -12 <(find ../input/raw_data/ -name "*.png"|cut -d"/" -f4-5) <(cat diffs.txt)


rm(list=ls())
library(foreach)
meta_fname = '../input/TIALP-B1/Metadatafile TopoChip_TiALP_array1_allunits.csv'
#meta_pruned_fname = '../input/TIALP-B1/Metadatafile TopoChip_TiALP_array1_allunits_pruned.csv'
meta_pruned_fname = '../input/TIALP-B1/Metadatafile TopoChip_TiALP_array1_allunits_pruned_fixedmetaproblem.csv'
flist_fname = '../input/flist.txt'
pathname <- "\\\\iodine\\imaging_analysis\\2012_08_20_TopoChipScreening_deBoerLab\\rawdataTiALPscreen\\"
fprefix <- list(FileName_Actin='alexa488', FileName_DNA='dapi', FileName_ALP='alexa594')
pathname_header_prefix <- c("PathName_Actin", "PathName_DNA", "PathName_ALP")
ndigits <- 10
extn = 'png'
# fname_idx1 <- 'Metadata_imageidxtop'
# fname_idx2 <- 'Metadata_imageidxbottom'
fname_idx1 <- 'Metadata_unitidxtop'
fname_idx2 <- 'Metadata_unitidxbottom'
exclude_pattern <- c('Pathname', 'FileName', 'Metadata_ArrayNumber')
array_list <- c(1,2,3,4,5,7,9,10)

fprefix_warrayname <- paste(names(fprefix), "w_array_name", sep="_")



meta <- read.csv(meta_fname)
cols <- names
exclude_cols <- unlist(lapply(exclude_pattern, function(x) unlist(grep(x, names(meta)))))
meta <- meta[,-exclude_cols]

fname_idxs <- c(fname_idx1, fname_idx2)
# make sure that doing unique halves the data
dim(unique(meta))[1] * 2 == dim(meta)[1]  

# prune it to uniques
meta <- unique(meta)

meta2 <- data.frame()
for (i in array_list) {
  array_name <- sprintf('array%d', i)
  meta1 <- data.frame()
  for (idx in fname_idxs) {
    imgnum <- sprintf('%010d', meta[,idx])
    df <- data.frame()
    df_ <- data.frame()
    for (fp in names(fprefix)) {
      df0_ <- data.frame(sprintf("%s/%s_%s.%s", array_name, fprefix[[fp]], imgnum, extn))
      df0 <- data.frame(sprintf("%s_%s.%s", fprefix[[fp]], imgnum, extn))
      names(df0_) <- c(paste(fp, "w_array_name", sep="_"))
      names(df0) <- c(fp)
      if (prod(dim(df))==0) {
        df <- df0
        df_ <- df0_
      } else {
        df <- cbind(df, df0)
        df_ <- cbind(df_, df0_)
      }
    }
    meta1_ <- cbind(df, df_, meta)
    if (prod(dim(meta1))==0) {
      meta1 <- meta1_
    } else {
      meta1 <- rbind(meta1, meta1_)
    }
  }
  # construct pathname
  pathname_ <- data.frame(sprintf('%s%s', pathname,  array_name))
  for(ip in seq_along(pathname_header_prefix)) {
    if (ip == 1) {
      pathname_d <- pathname_
    } else {
      pathname_d <- cbind(pathname_d, pathname_)      
    }
  }
  names(pathname_d) <- pathname_header_prefix
  array_idxf <- data.frame(Metadata_ArrayNumber=i)
  meta2_ <- cbind(array_idxf, pathname_d, meta1)
  if(prod(dim(meta2))==0) {
    meta2 <- meta2_
  } else {
    meta2 <- rbind(meta2, meta2_)
  }
}

# do some sanity checks
for (fp in fprefix_warrayname) {
  flag <- length(unique(meta2[,fp])) == length(meta2[,fp])
  print(fp)
  print(flag)
}

# find the files that are present in the directories
fc <- file(flist_fname)
flist <- readLines(fc)
close(fc)
flag_array <- foreach (fp = fprefix_warrayname, 
                       .combine=cbind) %do% (as.character(meta2[,fp]) %in% flist)

# sanity check
# if its present in one it is present in all?
all(apply(flag_array, 1, any) == apply(flag_array, 1, all))

# save only those files that are present in all (just in case the test above fails, play it safe)
flag_array_all <- apply(flag_array, 1, all)
meta2_pruned <- meta2[flag_array_all,]
write.csv(meta2_pruned, meta_pruned_fname, row.names = FALSE)

# print stats
print("number of files in the original metadata file")
print(length(flag_array_all)*dim(flag_array)[2])
print("number of files in the pruned metadata file")
print(sum(flag_array_all)*dim(flag_array)[2])
print("number of files in directories")
print(length(flist))
print("list of files present in directories but not in metadata")
print(setdiff(flist, as.vector(t(meta2_pruned[,fprefix_warrayname]))))

# do additional checks
print("checking if files are present in one channel but not the other")
flag_arrayf <- as.data.frame(flag_array)
names(flag_arrayf) <- fprefix_warrayname
diffs <- list()
for (fp in fprefix_warrayname) {
  diffs <- c(diffs, as.character(meta2[setdiff(which(flag_arrayf[,fp]), which(flag_array_all)), fp]))
}

head(unlist(diffs))
# fdiffs <- file("diffs.txt")
# writeLines(unlist(diffs), fdiffs)
# close(fdiffs)

# # 
# library(gplots)
# library(ggplot2)
# library(plyr)
# library(reshape)
# library(colorRamps)
# library(RColorBrewer)
# X <- unique(meta[,14:51])
# X <- scale(X)
# heatmap.2(abs(cor(X)),symm=TRUE, Colv=TRUE,scale="none", trace="none",
#            dendrogram = "column",
#            col = colorRampPalette(brewer.pal(9,"Blues"))(100))
# 
# ggplot(melt(as.data.frame(X)), aes(value)) + geom_histogram(binwidth=.5) + facet_wrap(~ variable, ncol=4)

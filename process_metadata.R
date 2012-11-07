# create filelist like this:
# find . -name "*.png" |cut -c3- >  flist.txt
# compare like this:
# comm -12 <(find ../input/raw_data/ -name "*.png"|cut -d"/" -f4-5) <(cat diffs.txt)

rm(list=ls())
library(foreach)
meta_fname = '../input/Metadatafile TopoChip_TiALP_array1_allunits.csv'
meta_pruned_fname = '../input/Metadatafile TopoChip_TiALP_array1_allunits_pruned.csv'
flist_fname = '../input/flist.txt'
fprefix <- list(FileName_Actin='alexa488', FileName_DNA='dapi', FileName_ALP='alexa594')
ndigits <- 10
extn = 'png'
fname_idx1 <- 'Metadata_imageidxtop'
fname_idx2 <- 'Metadata_imageidxbottom'
exclude_pattern <- c('Pathname', 'FileName', 'Metadata_ArrayNumber')
array_list <- c(1,2,3,4,5,7,9,10)


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
    for (fp in names(fprefix)) {
      df0 <- data.frame(sprintf("%s/%s_%s.%s", array_name, fprefix[[fp]], imgnum, extn))
      names(df0) <- c(fp)
      if (prod(dim(df))==0) {
        df <- df0
      } else {
        df <- cbind(df, df0)
      }
    }
    meta1_ <- cbind(df, meta)
    if (prod(dim(meta1))==0) {
      meta1 <- meta1_
    } else {
      meta1 <- rbind(meta1, meta1_)
    }
  }
  array_idxf <- data.frame(Metadata_ArrayNumber=i)
  meta2_ <- cbind(array_idxf, meta1)
  if(prod(dim(meta2))==0) {
    meta2 <- meta2_
  } else {
    meta2 <- rbind(meta2, meta2_)
  }
}

# do some sanity checks
for (fp in names(fprefix)) {
  flag <- length(unique(meta2[,fp])) == length(meta2[,fp])
  print(fp)
  print(flag)
}

fc <- file(flist_fname)
flist <- readLines(fc)
close(fc)

flag_array <- foreach (fp = names(fprefix), .combine=cbind) %do% (as.character(meta2[,fp]) %in% flist)

# sanity check
all(apply(flag_array, 1, any) == apply(flag_array, 1, all))
flag_array_all <- apply(flag_array, 1, all)
meta2_pruned <- meta2[flag_array_all,]
write.csv(meta2_pruned, meta_pruned_fname)

flag_arrayf <- as.data.frame(flag_array)
names(flag_arrayf) <- names(fprefix)
diffs <- list()
for (fp in names(fprefix)) {
  diffs <- c(diffs, as.character(meta2[setdiff(which(flag_arrayf[,fp]), which(flag_array_all)), fp]))
}

head(unlist(diffs))

# number of pruned files
print(sum(flag_array_all)*dim(flag_array)[2])
# number of files in directories
print(length(flist))

fdiffs <- file("diffs.txt")
writeLines(unlist(diffs), fdiffs)
close(fdiffs)
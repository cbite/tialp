# ---------------- BIGIMG-B1 -------------------
rm(list=ls())
meta_fname = '../input/BIGIMG-B1/Metadatafile_largesurfacesALP.csv'
meta_pruned_fname = '../input/BIGIMG-B1/Metadatafile_largesurfacesALP_pruned.csv'

flist_fname = '../input/BIGIMG-B1/flist.txt'
pathname <- "\\\\iodine\\imaging_analysis\\2012_08_20_TopoChipScreening_deBoerLab\\Pictureslargesurfaces"
fprefix <- list(FileName_Actin='ch2', FileName_DNA='ch1', FileName_ALP='ch3')
pathname_header_prefix <- c("PathName_Actin", "PathName_DNA", "PathName_ALP")
extn = 'tif'
exp_l <- c(1,2,3,4)
#exp_l <- c(1)
dirtag <- 'exp'
nimages <- 15

meta <- read.csv(meta_fname)
lsn_l <- unique(meta$Metadata_largesurfacenumber)
chs_l <- names(fprefix)
meta_full <- data.frame()
for (exp in exp_l) {
  for (lsn in lsn_l) {
    for (im in seq(nimages)) {
      r <- meta[meta$Metadata_largesurfacenumber == lsn,]
      r$Metadata_expnumber <- exp
      r[,pathname_header_prefix] <- sprintf('%s\\exp%s\\', pathname, exp)
      for (chs in chs_l) {
        r[,chs] <- sprintf('%04d_%s_%02d.tif', lsn, fprefix[[chs]], im)
        chsp <- sprintf('wp_%s', chs)
        r[,chsp] <- sprintf('exp%d/%04d_%s_%02d.tif', exp, lsn, fprefix[[chs]], im)
      }
      meta_full <- rbind(meta_full, r)
    }
  }
}

flist <- as.character(read.table(flist_fname)[,1])
flagv <- rep(TRUE, NROW(meta_full))

for (chsp in paste('wp', chs_l, sep='_')){
  flagv <- flagv & (meta_full[,chsp] %in% flist)
}

meta_full <- meta_full[flagv,]

fpnames <- c(pathname_header_prefix, names(fprefix))
header <- c(fpnames, names(meta_full)[!(names(meta_full) %in% fpnames)])
meta_full <- meta_full[,header]

write.csv(meta_full, meta_pruned_fname, row.names = F)

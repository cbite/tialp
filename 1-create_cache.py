import os
import fnmatch

ddir="../input/"
cache_tag="2012-11-28"
datasets=["TIALP-B1"]
for dataset in datasets:
    for i, fname in enumerate(os.listdir(os.path.join(ddir, dataset))):
        if fnmatch.fnmatch(fname, '*.properties'):
            prop_file = os.path.join(ddir, dataset, fname)
            cache_dir = os.path.join(ddir, dataset, "cache-" + cache_tag)
            cmd = "python -m cpa.profiling.cache -r %s %s %s" % \
                  (prop_file, cache_dir, '""')
            bsub="bsub -q week -J %s -o %s.out " % \
                  ("cache-" + dataset, "cache-" + dataset)

            print bsub + cmd

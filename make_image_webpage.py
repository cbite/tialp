#!/usr/bin/env python

from jinja2 import Template
from jinja2 import Environment, FileSystemLoader
import os
import shutil
from PIL import Image

imgpath = '../../../rawdataTiALPscreen'
outpath = '../output/TIALP-B1'
thumbpath = os.path.join(outpath, 'thumbs')
if not os.path.isdir(thumbpath):
    os.mkdir(thumbpath)
env = Environment(loader=FileSystemLoader('./jinja_templates'))
tmpl = env.get_template('image_montage.html')

with open('../results/alp_prediction/c59f290e/labels.csv', 'r') as f:
    f.readline()
    l = f.readlines()

l = [ll.strip().replace('"', '') for ll in l if ll.strip() != ""]

ll = []
lh = []
hl = []
hh = []

# import random
# random.shuffle(l)
# l = l[1:10]

for li in l:
    _, fname, gt, pred = li.split(",")
    fname = os.path.join(imgpath, fname)
    alexa488 = fname
    alexa594 = fname.replace("alexa488", "alexa594")
    dapi     = fname.replace("alexa488", "dapi")

    fname_l = [alexa488, alexa594, dapi]
    fname_th = []
    for f in fname_l:
        d = os.path.basename(os.path.dirname(f))
        f_ = "-".join([d, os.path.basename(f)])
        im = Image.open(f)#.convert('RGB')
        im.thumbnail((300,300),Image.ANTIALIAS)
        f_ = os.path.join(thumbpath, f_)
        im.save(f_)
        fname_th.append(f_)

    c = gt+pred
    if c == "ll" : ll.append(fname_th)
    if c == "lh" : lh.append(fname_th)
    if c == "hl" : hl.append(fname_th)
    if c == "hh" : hh.append(fname_th)


lst = dict({'ll':ll, 
            'lh':lh, 
            'hl':hl, 
            'hh':hh})

for lkn, lk in lst.items():
    images_comb = []
    for i in lk:
        i_ = [ii.replace(os.path.dirname(ii),
                         os.path.relpath(os.path.dirname(ii), outpath))
              for ii in i]
        images_comb.append(
            dict({'ch1' : i_[0],
                  'ch2' : i_[1],
                  'ch3' : i_[2]}))
    with open('%s/%s.html' % (outpath, lkn), 'w') as f:
        f.write(tmpl.render(images=images_comb))



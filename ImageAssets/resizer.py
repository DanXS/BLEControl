import os, sys
from PIL import Image

# portrait screen shots
# sizes = [(1536, 2048), (1242, 2208), (768, 1024), (750, 1334), (640, 1136), (640, 960)]

# watch icon sizes
sizes = [(196, 196),(180, 180),(172, 172),(167, 167),(152, 152),(120, 120),(88, 88),(87, 87),(80, 80),(76, 76),(60,60),(58, 58),(55, 55),(48, 48),(40, 40),(29, 29),(20,20)]

for infile in sys.argv[1:]:
    f, e = os.path.splitext(infile)
    im = Image.open(infile)
    print im.format, im.size, im.mode
    for s in sizes:
        outfile =  f + "_" + str(s[0]) + "x" + str(s[1]) + ".png"
        out = im.resize(s, Image.ANTIALIAS)
        out.save(outfile, "PNG")


#!/usr/bin/env python
# coding: utf-8

import sys
import skimage
import numpy as np
import k3proc

from skimage.metrics import structural_similarity

def usage():
    print("Calcuate similarity between two images.")
    print("It will resize b to the size of a before compare.")
    print("Usage:")
    print("    $0 a b")


def cmp_image(path_a, path_b):
    da = skimage.io.imread(path_a)
    db = skimage.io.imread(path_b)
    if da.shape != db.shape:
        k3proc.command_ex(
            'convert',
            # height then width
            '-resize', '%dx%d!' % (da.shape[1], da.shape[0]),
            path_b, path_b
        )
        db = skimage.io.imread(path_b)

    img1 = skimage.img_as_float(da)
    img2 = skimage.img_as_float(db)
    #  img1 = skimage.img_as_bool(da)
    #  img2 = skimage.img_as_bool(db)


    print("img1:-------------", path_a)
    print(img1.shape)
    print("img2:-------------", path_b)
    print(img2.shape)

    print(img1)
    print(img2)

    print("min:", img1.min(), img2.min())
    print("max:", img1.max(), img2.max())

    #  def mse(imageA, imageB):
    #
    # the 'Mean Squared Error' between the two images is the
    # sum of the squared difference between the two images;
    # NOTE: the two images must have the same dimension
    err = np.sum((img1.astype("float") - img2.astype("float")) ** 2)
    err /= float(img1.shape[0] * img1.shape[1])

    # return the MSE, the lower the error, the more "similar"
    # the two images are
    #  return err
    print("err:",  err)

    #  w = img1.shape[1]
    #  h = img1.shape[0]

    #  l1 = img1.tolist()
    #  l2 = img2.tolist()

    #  diff = []
    #  for (i, line) in enumerate(img1.tolist()):
    #      ll = []
    #      for (j, va) in enumerate(line):
    #          vb = l2[i][j]
    #          ll.append(va-vb)

    #      diff.append(ll)


    #  with open("f1", "w") as f1:
    #      for line in diff:
    #          f1.write(str(line))
    #          f1.write('\n')


    # shape is in form: (170, 270, 4): 4 channels
    #              or:  (170, 270):    1 channel

    if len(img1.shape) == 2:
        p = structural_similarity(img1, img2, data_range=1)
    else:
        # channel_axis=2 specifies img.shape[2] specifies the number of channels
        p = structural_similarity(img1, img2, channel_axis=2, data_range=1)

    print("p:", p)

    return p

if __name__ == "__main__":

    if sys.argv[1] in ('-h', '--help'):
        usage()
        sys.exit()


    cmp_image(sys.argv[1], sys.argv[2])

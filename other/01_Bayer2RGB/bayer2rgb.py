import os
import numpy as np
import cv2

file_path = "./raw8_1600x1200_RGGB.raw"
height = 1200
width = 1600
depth = 8
pattern = "rggb"

if __name__ == '__main__':

    if depth == 8:
        raw_data = np.fromfile(file_path, dtype="uint8")
    else:
        raw_data = np.fromfile(file_path, dtype="uint16")

    bayer_img = raw_data.reshape(height,width,1)

    if pattern == "rggb":
        rgb_img = cv2.cvtColor(bayer_img,cv2.COLOR_BAYER_RGGB2RGB)
    elif pattern == "bggr":
        rgb_img = cv2.cvtColor(bayer_img,cv2.COLOR_BAYER_RGGB2RGB)
    elif pattern == "gbrg":
        rgb_img = cv2.cvtColor(bayer_img,cv2.COLOR_BAYER_GBRG2RGB)
    elif pattern == "grbg":
        rgb_img = cv2.cvtColor(bayer_img,cv2.COLOR_BAYER_GRBG2RGB)
    else:
        rgb_img = np.empty((height,width,3))

    # set depth
    if depth == "uint8":
        rgb_img = np.uint8(rgb_img)
    elif depth == "uint16":
        rgb_img = np.uint8(rgb_img)
    cv2.imshow("image",rgb_img)
    cv2.waitKey(0)
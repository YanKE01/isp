import matplotlib.pyplot as plt
import numpy as np
import cv2

if __name__ == '__main__':
    raw_img = np.fromfile("../assets/connan_raw14.raw",dtype=np.uint16)

    raw_img = raw_img.reshape(4044,6080)
    fig = plt.figure()
    plt.imshow(raw_img)
    pos = fig.ginput(n=4)

    #划分网格
    (x,y)=np.meshgrid(np.arange(0.5,6.5),np.arange(0.5,4.5)/4)
    print(x)
    print(x/6)
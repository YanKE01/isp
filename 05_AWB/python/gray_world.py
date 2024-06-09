import cv2
import numpy as np
import matplotlib.pyplot as plt

if __name__ == '__main__':
    raw_img = cv2.imread("../images/NikonD5200_0001_G_AS.png")

    img_rgb = cv2.cvtColor(raw_img,cv2.COLOR_BGR2RGB)
    r_channel = img_rgb[:,:,0]
    g_channel = img_rgb[:,:,1]
    b_channel = img_rgb[:,:,2]

    r_channel_mean = np.mean(r_channel)
    g_channel_mean = np.mean(g_channel)
    b_channel_mean = np.mean(b_channel)

    r_channel_gain = g_channel_mean/r_channel_mean
    b_channel_gain = g_channel_mean/b_channel_mean

    new_img = np.zeros(raw_img.shape)
    new_img[:,:,0] = r_channel*r_channel_gain
    new_img[:,:,1] = g_channel
    new_img[:,:,2] = b_channel*b_channel_gain

    new_img[new_img>255] = 255
    new_img = new_img.astype(np.uint8)

    plt.figure()
    plt.subplot(121)
    plt.imshow(img_rgb)
    plt.subplot(122)
    plt.imshow(new_img)
    plt.show()
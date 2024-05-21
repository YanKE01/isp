clc;close all;clear;

%% 读取文件

img = imread("../images/NikonD5200_0001_G_AS.png");
[height,width,ch] = size(img);

r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);


r_mean = mean(mean(r));
g_mean = mean(mean(g));
b_mean = mean(mean(b));

%% 计算gain值
% 我们都是向g_mean靠

r_gain = g_mean/r_mean;
b_gain = g_mean/b_mean;

%% 还原
new_img = zeros(size(img));
new_img(:,:,1) = r*r_gain;
new_img(:,:,2) = g;
new_img(:,:,3) = b*b_gain;

new_img(new_img>255) = 255;
new_img = uint8(new_img);

%%  展示
figure;

subplot(1,2,1);
imshow(img);
title("org");

subplot(1,2,2);
imshow(new_img);
title("gw");
% 完美反射与灰度正交
clc;close all;clear;

%% 读取文件

img = imread("../images/NikonD5200_0001_G_AS.png");
[height,width,ch] = size(img);

r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);

%% 计算gain值
r_max = double(max(max(r)));
g_max = double(max(max(g)));
b_max = double(max(max(b)));

r_mean = double(mean(mean(r)));
g_mean = double(mean(mean(g)));
b_mean = double(mean(mean(b)));

k_mean = (r_mean+g_mean+b_mean)/3;
k_max = (r_max+g_max+b_max)/3;

%% 矫正
new_img = zeros(size(img));

x = [r_mean.*r_mean,r_mean;r_max.*r_max,r_max]\[k_mean;k_max];
u = x(1);
v = x(2);
new_img(:,:,1) = u*(r.*r)+v*r;

x = [g_mean.*g_mean,g_mean;g_max.*g_max,g_max]\[k_mean;k_max];
u = x(1);
v = x(2);
new_img(:,:,2) = u*(g.*g)+v*g;

x = [b_mean.*b_mean,b_mean;b_max.*b_max,b_max]\[k_mean;k_max];
u = x(1);
v = x(2);
new_img(:,:,3) = u*(b.*b)+v*b;

new_img(new_img>255) = 255;
new_img = uint8(new_img);

%%  展示
figure;

subplot(1,2,1);
imshow(img);
title("org");

subplot(1,2,2);
imshow(new_img);
title("pr");

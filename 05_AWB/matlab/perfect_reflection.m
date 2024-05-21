% 完美反射
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

max_value = double(max([r_max,g_max,b_max]));

r_gain = max_value / r_max;
g_gain = max_value / g_max;
b_gain = max_value / b_max;

%% 还原
new_img = zeros(size(img));
new_img(:,:,1) = r*r_gain;
new_img(:,:,2) = g*g_gain;
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
title("pr");
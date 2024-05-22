clc; clear; close all;

%% 读取图像
img = imread('../images/lena.bmp');
img_double = double(img);
[height,width] = size(img);

figure();
subplot(1,2,1);
imshow(img);
title("org");
img_noise = img_double + 10 * randn(size(img_double));
subplot(1,2,2);
imshow(uint8(img_noise));
title("noise");

%% 扩充图像
img_expand = padarray(img_double,[1,1],'symmetric','both');
new_img = zeros(size(img));

%% 多级中值去噪
for i=1:height
    for j=1:width
        roi = img_expand(i:i+2,j:j+2);
        middle_1 = median(median([roi(1,2),roi(2,1),roi(2,2),roi(2,3),roi(3,2)])); %十字形
        middle_2 = median(median([roi(1,1),roi(1,3),roi(2,2),roi(3,1),roi(3,3)])); % x形状
        new_img(i,j) = median(median([middle_1,roi(2,2),middle_2])); %结合中心点，再求一次中值
    end
end


figure();
imshow(uint8(new_img));
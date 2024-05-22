% 多级中值与平均值混合
clc;clear;close all;

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

%% 多级中值与平均值滤波

for i=1:height
    for j=1:width
        roi = img_expand(i:i+2,j:j+2);
        
        % 第一部分中值，水平均值+竖直均值+中间点
        mean_v = mean(mean(roi(:,2)));
        mean_h = mean(mean(roi(2,:)));
        middle_1 = median(median([mean_v,roi(2,2),mean_h]));

        % 第二部分中值，45度均值+135均值+中间点
        mean_45 = mean(mean([roi(1,3),roi(2,2),roi(3,1)]));
        mean_135 = mean(mean([roi(1,1),roi(2,2),roi(3,3)]));
        middle_2 = median(median([mean_45,roi(2,2),mean_135]));

        new_img(i,j) = median(median([middle_1,roi(2,2),middle_2]));
    end
end

figure();
imshow(uint8(new_img));

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

%% 中值有理滤波

h = 2;
k = 0.01;

for i = 1: height
    for j = 1: width
        roi = img_expand(i:i+2, j:j+2);
        median_HV = median([roi(1,2), roi(2,1), roi(2,2), roi(2,3), roi(3,2)]);
        median_diag = median([roi(1,1), roi(1,3), roi(2,2), roi(3,1), roi(3,3)]);
        CWMF = median(median([roi(1,2),roi(2,1),3*roi(2,2),roi(2,3),roi(3,2)]));
        
        new_img(i, j) = CWMF + (median_HV + median_diag - 2 * CWMF) / (h + k * (median_HV - median_diag));
    end
end

figure();
imshow(uint8(new_img));
title('denoise file');



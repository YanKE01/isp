clc;close all;clear;

ref_image = imread("../images/ref_image.jpg");

target_brightness = 0.8*max(max(ref_image));

gain = double(target_brightness)*ones(size(ref_image))./double(ref_image); %按照最大值的80%来矫正

calibration_image = uint8(double(ref_image).*gain);

figure;
subplot(121);
imshow(ref_image);
title('org');

subplot(122);
imshow(uint8(calibration_image));
title('cali');
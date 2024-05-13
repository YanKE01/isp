%% 双线性插值
clc;close all;clear;

%% 读取图像
org_image = imread("../images/lena.bmp");
figure;
imshow(org_image);
title("origin image");

%% 制作压缩图像
[width,height] = size(org_image);

comp_image_width =  width/2;
comp_image_height = height/2;
comp_image = zeros(comp_image_width,comp_image_height); 

for i=1:comp_image_height
    for j =1:comp_image_width
        comp_image(i,j) = org_image(2*i,2*j);
    end
end

figure;
imshow(uint8(comp_image));
title("compress image");

%% 双线性插值

%首先，我们需要对图像进行扩展一圈，因为算法需要判断4个点，但是对于定点而言，是缺少了三个点的，所以需要补一圈
head_row_mat = comp_image(1,:);
tail_row_mat = comp_image(comp_image_height,:);

left_col_mat = [comp_image(1,1);comp_image(:,1);comp_image(comp_image_height,1)];
right_col_mat = [comp_image(1,comp_image_width);comp_image(:,comp_image_width);comp_image(comp_image_height,comp_image_width)];

expand_image = [head_row_mat;comp_image;tail_row_mat]; %先补上下两条边
expand_image = [left_col_mat,expand_image,right_col_mat]; %后补左右两边

magnification = 2; %放大倍数

new_image_width = comp_image_width*magnification;
new_image_height = comp_image_height*magnification;

new_image = zeros(new_image_width,new_image_height);

% f(x,y) = [f(1,0)-f(0,0)]*x+[f(0,1)-f(0,0)]*y+[f(1,1)+f(0,0)-f(1,0)-f(0,1)]*xy+f(0,0)
% x乘上x的变化+y*y的变化+对角*xy+f(0,0),注意，这里x的变化是要归一化的rem/放大

for i=1:new_image_height
    for j=1:new_image_width
        deta_x = rem(i,magnification)/magnification;
        deta_y = rem(j,magnification)/magnification;
        floor_x = floor(i/magnification)+1;
        floor_y = floor(j/magnification)+1;

        new_image(i,j) = (expand_image(floor_x+1,floor_y)-expand_image(floor_x,floor_y))*deta_x...
                        +(expand_image(floor_x,floor_y+1)-expand_image(floor_x,floor_y))*deta_y...
                        +(expand_image(floor_x+1,floor_y+1)+expand_image(floor_x,floor_y) ...
                            -expand_image(floor_x,floor_y+1)-expand_image(floor_x+1,floor_y))*deta_x*deta_y...
                        +expand_image(floor_x,floor_y);
    end
end


%% 对比图
figure;
subplot(1,2,1);
imshow(org_image);
title("origin image");
subplot(1,2,2);
imshow(uint8(new_image));
title("result");


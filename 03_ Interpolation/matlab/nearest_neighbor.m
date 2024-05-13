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

%% 使用最近领插值算法

%首先，我们需要对图像进行扩展一圈，因为算法需要判断4个点，但是对于定点而言，是缺少了三个点的，所以需要补一圈
head_row_mat = comp_image(1,:);
tail_row_mat = comp_image(comp_image_height,:);

left_col_mat = [comp_image(1,1);comp_image(:,1);comp_image(comp_image_height,1)];
right_col_mat = [comp_image(1,comp_image_width);comp_image(:,comp_image_width);comp_image(comp_image_height,comp_image_width)];

expand_image = [head_row_mat;comp_image;tail_row_mat]; %先补上下两条边
expand_image = [left_col_mat,expand_image,right_col_mat]; %后补左右两边

%% 按照比例放大

magnification = 2; %放大倍数

new_image_width = comp_image_width*magnification;
new_image_height = comp_image_height*magnification;

new_image = zeros(new_image_width,new_image_height);

for i = 1:new_image_height
    for j = 1:new_image_width
        floor_x = floor(i/magnification)+1; %expand数组中的x坐标
        floor_y = floor(j/magnification)+1; %expand数组中的y坐标

        delt_x = rem(i,magnification)/magnification; %在x方向来求0-1的相对位置，因为我们已经模了放大倍数，所以只会在0-1
        delt_y = rem(j,magnification)/magnification;

        %先判断x方向，大于0.5就选右边，小于0.5就选左边，在判断y
        if delt_x<0.5 && delt_y<0.5
            %第一象限
            new_image(i,j)=expand_image(floor_x,floor_y);
        elseif delt_x<0.5 && delt_y>=0.5
            new_image(i,j)=expand_image(floor_x,floor_y+1);
        elseif delt_x>=0.5 && delt_y<0.5
            new_image(i,j)=expand_image(floor_x+1,floor_y);
        else
            new_image(i,j)=expand_image(floor_x+1,floor_y+1);
        end

    end
end

figure;
subplot(1,2,1);
imshow(org_image);
title("origin image");
subplot(1,2,2);
imshow(uint8(new_image));
title("result");

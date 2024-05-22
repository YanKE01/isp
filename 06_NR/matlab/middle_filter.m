clc;close all;clear;

%% 读取原图
img = imread('../images/test_pattern_blurring_orig.tif');
[height, width] = size(img);
figure;subplot(221);imshow(img);title('original image');

%% 扩充四周图片
top_row = img(1,:); %获取第一行
button_row = img(height,:); %获取最后一行
expand_img = [top_row;img;button_row]; %先扩充两行
left_col = expand_img(:,1);
right_col = expand_img(:,width);
expand_img = [left_col expand_img right_col];
expand_img = uint8(expand_img);
subplot(222);imshow(expand_img);title('expand image');

%% 均值滤波
new_img = zeros(size(img));

% 这里的i,j相对原图在expand图中的位置
for i=2:height+1
    for j= 2:width+1
        %先获取3*3的元素
        img_roi = [expand_img(i-1,j-1) expand_img(i-1,j) expand_img(i-1,j+1) ...
                   expand_img(i,j-1) expand_img(i,j) expand_img(i,j+1) ...
                   expand_img(i+1,j-1) expand_img(i+1,j) expand_img(i+1,j+1)];
        order_list = sort(img_roi);
        new_img(i-1,j-1) = median(order_list);
    end
end

new_img = uint8(new_img);
subplot(223);imshow(new_img);title('new image');
subplot(224);imshow(new_img-img);title('newImg-img');
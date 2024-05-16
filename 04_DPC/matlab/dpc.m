clc; clear; close all;
%% 设置参数

image_path = "../images/HisiRAW_4208x3120_8bits_RGGB.raw";
bayerFormat = 'RGGB';
row = 4208;
col = 3120;
bits = 8;

%% 读取文件
f = fopen(image_path, "r");

switch bits
    case 8
        formate = "uint8=>uint8";
    case 10
        formate = "uint16=>uint16";
    case 12
        formate = "uint16=>uint16";
    case 16
        formate = "uint16=>uint16";
end

i = fread(f, row * col, formate);
raw_data = reshape(i, row, col)';
fclose(f);

%% 扩充图片
% pinto算法需要8个方向的点，所以对于边缘的点，需要扩充
% 一定要注意的是，这里是相邻2个像素的点，不是相邻1个像素的点

[height,width] = size(raw_data);
expandNum=2; %这里的expandnum一侧加2个

img_expand = zeros(height+expandNum*2, width+expandNum*2);
img_expand(expandNum+1:height+expandNum, expandNum+1:width+expandNum) = raw_data(:,:); %raw原图的部分
img_expand(1:expandNum, expandNum+1:width+expandNum) = raw_data(1:expandNum,:); %扩充顶部
img_expand(height+expandNum+1:height+expandNum*2, expandNum+1:width+expandNum) = raw_data(height-expandNum+1:height,:); %扩充底部
img_expand(:,1:expandNum) = img_expand(:, expandNum+1:2*expandNum); %扩充左侧
img_expand(:,width+expandNum+1:width+2*expandNum) = img_expand(:, width+1:width+expandNum); %扩充右侧

%% pinto算法

th = 30;
dis_img = zeros(height, width);

for i = expandNum+1:2:height+expandNum
    for j = expandNum+1:2:width+expandNum
        %注意，此时的i和j在扩展前的图像中，并且，我们判断的点距离当前的点为2
        around_R_pixel = [img_expand(i-2, j-2) img_expand(i-2, j) img_expand(i-2, j+2) img_expand(i, j-2) img_expand(i, j+2) img_expand(i+2, j-2) img_expand(i+2, j) img_expand(i+2, j+2)];
        dis_img(i-expandNum,j-expandNum)=pinto(around_R_pixel,img_expand(i,j),th);
    
        %注意gr的四周八个点不一定是gr，gb也可以
        around_Gr_pixel = [img_expand(i-1, j) img_expand(i-2, j+1) img_expand(i-1, j+2)  img_expand(i, j-1) img_expand(i, j+3) img_expand(i+1, j) img_expand(i+2, j+1) img_expand(i+1, j+2)];
        dis_img(i-expandNum,j-expandNum+1)=pinto(around_Gr_pixel,img_expand(i,j+1),th);

        %b
        around_B_pixel = [img_expand(i-1, j-1) img_expand(i-1, j+1) img_expand(i-1, j+3) img_expand(i+1, j-1) img_expand(i+1, j+3) img_expand(i+3, j-1) img_expand(i+3, j+1) img_expand(i+3, j+3)];
        dis_img(i-expandNum+1,j-expandNum+1)=pinto(around_B_pixel,img_expand(i+1,j+1),th);

        %gb
        around_Gb_pixel = [img_expand(i, j-1) img_expand(i-1, j) img_expand(i, j+1) img_expand(i+1, j-2) img_expand(i+1, j+2) img_expand(i+2, j-1) img_expand(i+3, j) img_expand(i+2, j+1)];
        dis_img(i-expandNum+1,j-expandNum)=pinto(around_Gb_pixel,img_expand(i+1,j),th);

    end
end


figure();
imshow(raw_data);title('org');
figure();
imshow(uint8(dis_img));title('corrected');

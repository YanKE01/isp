clc;close all;clear;

ref_image = imread("../images/ref_image.jpg");
[height,width]= size(ref_image);
side_num = 17; %划分的步距

side_x = floor(width/side_num);
side_y = floor(height/side_num);

%%我们在原始的图像上把网格渲染出来，注意，我们是划分为17个块，所以在划线的时候只要16条
imshow(ref_image);
%先画每一列
for i = 1:side_num-1
    line([i*side_x,i*side_x],[1,height],'color','r');
    line([1,width],[i*side_y,i*side_y],'color','r');
end

image_point = zeros(side_num+1,side_num+1);%这个点是包括四个顶点，所以压缩后的图像大小为side_num+1
for i=0:side_num
    for j =0:side_num
        %在当前点的上下偏移side_y/2，左右偏移side_x/2，组成一个side_x*side_y的边界
        x_clip = floor([j*side_x - side_x/2, j*side_x + side_x/2]);
        y_clip = floor([i*side_y - side_y/2, i*side_y + side_y/2]);
        % make sure that the last point on the edge
        if(i==side_num && y_clip(2) ~= height) 
            y_clip(2) = height;
        end
        if(j==side_num && x_clip(2) ~= width) 
            x_clip(2) = width;
        end
        x_clip(x_clip<1) = 1;
        x_clip(x_clip>width) = width;
        y_clip(y_clip<1) = 1;
        y_clip(y_clip>height) = height; %如果点在顶点的时候，要确保x的边界问题，排除负值
        data_in = ref_image(y_clip(1):y_clip(2), x_clip(1):x_clip(2));
        image_point(i+1,j+1) = mean(mean(data_in)); %求每一点在side_x和side_y边界下的平均值
    end
end

%% 计算gain值，我们这里以image_point的中间亮度值作为我们的目标值
gain = zeros(size(image_point));
target_brightness = image_point(uint8(side_num/2) +1, uint8(side_num/2) +1);

for i=1:side_num+1
    for j=1:side_num+1
        gain(i,j) = target_brightness/image_point(i,j);
    end
end

%% 矫正 双线性插值法
gain_table = zeros(size(ref_image));
step_x=0;
step_y=0;


%现在是要放大了
for i = 1:height
    for j = 1:width 
        step_x = floor(j/side_x)+1;
        if step_x> 16
            step_x=16;
        end

        step_y = floor(i/side_y)+1;
        if step_y> 16
            step_y=16;
        end

        gain_table(i,j) = (gain(step_x+1,step_y)-gain(step_x,step_y))*(i-(step_x-1)*side_x)/side_x...
                           +(gain(step_x,step_y+1)-gain(step_x,step_y))*(j-(step_y-1)*side_y)/side_y...
                           +(gain(step_x+1,step_y+1)+gain(step_x,step_y)-gain(step_x,step_y+1)-gain(step_x+1,step_y))...
                           *((j-(step_y-1)*side_y)/side_y)*((i-(step_x-1)*side_x)/side_x)...
                           +gain(step_x,step_y);
    end
end

dis_img = double(ref_image) .* gain_table;

figure();
subplot(121);imshow(ref_image);title('org image');
subplot(122);imshow(uint8(dis_img));title('corrected image');


% [height, width] = size(ref_image);
% sideX = floor(height/side_num);
% sideY = floor(width/side_num);
% 
% gainStepX = 0;
% gainStepY = 0;
% gainTab = zeros(size(ref_image));
% for i = 1:height
%     for j = 1:width
%         gainStepX = floor(i / sideX) + 1;
%         if gainStepX > 16
%             gainStepX = 16;
%         end
%         gainStepY = floor(j / sideY) + 1;
%         if gainStepY > 16
%             gainStepY = 16;
%         end
%         % get tht gain of the point by interpolation(Bilinear interpolation)
%         % f(x,y) = [f(1,0)-f(0,0)]*x+[f(0,1)-f(0,0)]*y+[f(1,1)+f(0,0)-f(1,0)-f(0,1)]*xy+f(0,0)
%         gainTab(i, j) = (gain(gainStepX+1, gainStepY) - gain(gainStepX, gainStepY)) * (i - (gainStepX - 1) * sideX)/sideX +...
%                         (gain(gainStepX, gainStepY+1) - gain(gainStepX, gainStepY)) * (j - (gainStepY - 1) * sideY)/sideY +...
%                         (gain(gainStepX+1, gainStepY+1) + gain(gainStepX, gainStepY) - gain(gainStepX+1, gainStepY)- gain(gainStepX, gainStepY + 1)) *...
%                         (i - (gainStepX - 1) * sideX)/sideX * (j - (gainStepY - 1) * sideY)/sideY + gain(gainStepX, gainStepY);
%     end
% end
% disImg = double(ref_image) .* gainTab;
% 
% figure();
% subplot(121);imshow(ref_image);title('org image');
% subplot(122);imshow(uint8(disImg));title('corrected image');

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

%% 设置参数
ds = 2; %领域半径
Ds = 2; %滑动窗口大小

%% 扩充图片
img = [1 2 3 4 5;6 7 8 9 10; 11 12 13 14 15;16 17 18 19 20;21 22 23 24 25];

img_expand = padarray(img,[ds+Ds,ds+Ds],'symmetric','both');


%% NLM
for i = 1:height
    for j =1:width
        i1=i+ds+Ds;
        j1=j+ds+Ds;
        W1=img_expand(i1-ds:i1+ds,j1-ds:j1+ds);  % current window
        fprintf('=======current point: (%d, %d)\n', i, j);

        swmin = i1 - Ds;
        swmax = i1 + Ds;
        shmin = j1 - Ds;
        shmax = j1 + Ds;
        
        for r = swmin: swmax
            for s = shmin: shmax
                if(r==i1 && s==j1)
                    continue;
                end
                W2 = img_expand(r-ds:r+ds,s-ds:s+ds); % the window is to be compared with current window

            end
        end
    end
end
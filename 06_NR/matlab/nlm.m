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

DenoisedImg = zeros(size(img_noise));

%% 设置参数
ds = 2; %领域半径
Ds = 5; %滑动窗口半径
h=10; %NLM公式中的h
h2=h*h;

%% 扩充图片
img_expand = padarray(img_double,[ds+Ds,ds+Ds],'symmetric','both');

%% NLM
for i = 1:height
    for j =1:width
        num=0;
        i1=i+ds+Ds;
        j1=j+ds+Ds; %注意，此时i1和j1指向了expand图像中的原始图像
        W1=img_expand(i1-ds:i1+ds,j1-ds:j1+ds);  % 获取当前点以ds为半径的一圈图像，加上自己的话，图像大小为5x5
        fprintf('=======current point: (%d, %d)\n', i, j);
        wmax=0;
        average=0;
        sweight=0;

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
            num = num+1;
            Dist2 = sum(sum(sqrt((W1-W2).*(W1-W2)))); %计算l2范数，本质上就是各个元素的平方之和再开根号
            w = exp(-Dist2/h2);   % the weight of the compared window
            if(w > wmax)
                wmax = w;
            end
            sweight = sweight + w;  % 权重求和，计算Z
            average = average + w*img_expand(r,s);
            end
        end

        fprintf('num of win: %d\n', num);
        average = average + wmax*img_expand(i1,j1); %之前的点+最大值赋值给当前权重
        sweight = sweight+wmax;
        DenoisedImg(i,j) = average/sweight; %归一化
    end
end

figure();
imshow(uint8(DenoisedImg));
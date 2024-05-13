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
data = reshape(i, row, col)';
fclose(f);

%%  读取数据
switch bayerFormat
    case 'RGGB'
        r = data(1:2:end, 1:2:end);
        gr = data(1:2:end, 2:2:end);
        gb = data(2:2:end, 1:2:end);
        b = data(2:2:end, 2:2:end);
    case 'GRBG'
        gr = data(1:2:end, 1:2:end);
        r = data(1:2:end, 2:2:end);
        b = data(2:2:end, 1:2:end);
        gb = data(2:2:end, 2:2:end);
    case 'GBRG'
        gb = data(1:2:end, 1:2:end);
        b = data(1:2:end, 2:2:end);
        r = data(2:2:end, 1:2:end);
        gr = data(2:2:end, 2:2:end);
    case 'BGGR'
        b = data(1:2:end, 1:2:end);
        gb = data(1:2:end, 2:2:end);
        gr = data(2:2:end, 1:2:end);
        r = data(2:2:end, 2:2:end);
end

r_mean = round(mean(mean(r)));
gr_mean = round(mean(mean(gr)));
gb_mean = round(mean(mean(gb)));
b_mean = round(mean(mean(b)));

fprintf("R:%d Gr:%d Gb:%d B:%d\n",r_mean,gr_mean,gb_mean,b_mean);

%% 每一个像素减去平均值
cr = r -r_mean;
cgr = gr -gr_mean;
cgb = gb -gb_mean;
cb = b -b_mean;

cdata=zeros(size(data)); %处理完成后的数据
cdata =uint8(cdata);

switch bayerFormat
    case 'RGGB'
        cdata(1:2:end, 1:2:end)=cr(1:1:end,1:1:end);
        cdata(1:2:end, 2:2:end)=cgr(1:1:end,1:1:end);
        cdata(2:2:end, 1:2:end)=cgb(1:1:end,1:1:end);
        cdata(2:2:end, 2:2:end)=cb(1:1:end,1:1:end);
    case 'GRBG'
        cdata(1:2:end, 1:2:end)=cgr(1:1:end,1:1:end);
        cdata(1:2:end, 2:2:end)=cr(1:1:end,1:1:end);
        cdata(2:2:end, 1:2:end)=cb(1:1:end,1:1:end);
        cdata(2:2:end, 2:2:end)=cgb(1:1:end,1:1:end);
    case 'GBRG'
        cdata(1:2:end, 1:2:end)=cgb(1:1:end,1:1:end);
        cdata(1:2:end, 2:2:end)=cb(1:1:end,1:1:end);
        cdata(2:2:end, 1:2:end)=cr(1:1:end,1:1:end);
        cdata(2:2:end, 2:2:end)=cgr(1:1:end,1:1:end);
    case 'BGGR'
        cdata(1:2:end, 1:2:end)=cb(1:1:end,1:1:end);
        cdata(1:2:end, 2:2:end)=cgb(1:1:end,1:1:end);
        cdata(2:2:end, 1:2:end)=cgr(1:1:end,1:1:end);
        cdata(2:2:end, 2:2:end)=cr(1:1:end,1:1:end);
end

for i = 1:col
    for j=1:row
        if(cdata(i,j)<0)
            cdata(i,j)=0;
        end

        if(cdata(i,j)>255)
            cdata(i,j)=255;
        end
    end
end

show(data, cdata, bits, gr_mean);




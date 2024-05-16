function result = pinto(around,current_point,th)
    result = current_point;
    media_v = median(around);
    diff = around - ones(1,numel(current_point))*current_point; %计算当前点与相邻点的

    %判断diff是否都大于0或者小于0，nnz函数可以用来返回满足条件的点
    if(nnz(diff>0)==numel(around) || nnz(diff<0)==numel(around))
        %可能需要，判断阈值
        % abs(diff)>th 如果大于返回的就是1，所以对于[1 2 3 4 5]>0，返回的就是[1 1 1 1 1]
        if length(find((abs(diff)>th)==1)) == numel(around)
            result = media_v; %用中位值来矫正
        end
    else
        result = current_point; %不需要矫正
    end

end
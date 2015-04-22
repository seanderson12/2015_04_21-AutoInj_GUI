function [o_path]=Path_qi(xy_and_o)
size_xy_o=size(xy_and_o);
dis=ones(size_xy_o(1),size_xy_o(1));
o_path=zeros(1,size_xy_o(1)-1);

%distance matrix
x_n=1;
    while x_n <= size_xy_o(1)
        y_m=1;
        while y_m <= size_xy_o(1)
            dis(y_m,x_n)=norm(xy_and_o(y_m,:)-xy_and_o(x_n,:));
            y_m=y_m+1;
        end
        x_n=x_n+1;
    end

o_point=1;
path_n=1;
    while path_n< size_xy_o(1)
        clean_point=o_point;
        dis_c=dis(:,o_point);
        dis_noZero=dis_c(dis_c~=0);
        mi=min(dis_noZero);
        minIndex=find(dis_c==mi);
        o_point=minIndex(1,1);
        dis(:,clean_point)=0;
        dis(clean_point,:)=0;
        o_path(path_n)=o_point-1;
        path_n=path_n+1;
    end
end

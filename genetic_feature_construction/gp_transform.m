function [ outpvect ] = gp_transform( input_data,genotype,num_leaves,num_levels,windows )
%GP_TRANSFORM Evolvable transformation function. Uses output from
%gp_genoinit.m and input data window
%   inp: 1xN input data vector
%   map{1}: 1 X N cell
%   map{2:number of leaves}: 2:number of levels X number of leaves
%   functions{1}: 1 X N cell, each value is either 1 or 2
%   functions{2:number of leaves}: 2:number of levels X number of leaves
%function primitives, 1-2, +,*

inp=genotype.input;
%inp{1}=input_data;
lev.map=genotype.map;
lev.func=genotype.func;

%lev.map{
outpvect=zeros((length(input_data)-(windows-1)),1);
for ind=windows:length(input_data)
    inp{1}=input_data(ind-(windows-1):ind);%cut out data window and assign to first input level
    for k=1:num_levels %iterate for each level
        for i=1:num_leaves %iterate for each leaf in level
           data=inp{k}(lev.map{k}==i);%find data points going to particular leaf
           if isempty(data)==0
               aggregate=data(1); %start with first data point in input data
               if length(data)>1 %is there any more input data to perform operations with?
                   for j=2:length(data) %for the rest of the input data, perform function specified by lev.func in that level
                       if lev.func{k}(i)==1 %addition
                           aggregate=aggregate+data(j);
                       elseif lev.func{k}(i)==2 %multiplication
                           aggregate=aggregate*data(j);
                       elseif lev.func{k}(i)==3 %subtraction
                           aggregate=aggregate-data(j);
                       elseif lev.func{k}(i)==4 %division remainder
                           aggregate=mod(aggregate,data(j));
                       elseif lev.func{k}(i)==5 %division
                           if data(j)~=0
                                aggregate=aggregate/data(j);    
                           end

                       elseif lev.func{k}(i)==6 %min
                           aggregate=min(aggregate,data(j));
                       elseif lev.func{k}(i)==7 %max
                           aggregate=max(aggregate,data(j));

                       end

                   end
               end
           else
               aggregate=1;
           end
           %leaffunction(aggregate)
           inp{k+1}(i)=aggregate;
        end
    end
    outpvect(ind-(windows-1))=sum(inp{i});
    
end    
outpvect=zscore(outpvect);
end


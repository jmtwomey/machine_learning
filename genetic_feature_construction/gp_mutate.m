function [ genotype_mutated ] = gp_mutate( genotype,i,num_mutations,probs )
genotype=genotype{i};

%probs=[input_prob,operation_prob,map_prob,maxcolumns,maxleaves,maxopers];
input_prob=probs(1);
operation_prob=probs(2);
map_prob=probs(3);
maxcolumns=probs(4);
maxleaves=probs(5);
maxopers=probs(6);
x=ones(1,50);
inpsamp=binornd(x,input_prob);
inpsamp=inpsamp(inpsamp==1);
opersamp=binornd(x,operation_prob);
opersamp=opersamp(opersamp==1);
mapsamp=binornd(x,map_prob);
mapsamp=mapsamp(mapsamp==1);
totalsamp=horzcat(inpsamp,opersamp*2,mapsamp*3); %create vector to sample from
% 
% columndomain=1:maxcolumns;
% operationdomain=1:maxopers;
% mapdomain=1:maxleaves;
[rowsmap,colsmap]=size(genotype.map);
[rowsoper,colsoper]=size(genotype.func);

for i=1:num_mutations
   %choose input, operation or map
   mut_choice=totalsamp(randi(3));
   if mut_choice==1 %input column mutation
      genotype.column= randi(maxcolumns,1); %mutate input column
   elseif mut_choice==2 %operation mutation
      genotype.func(randi(rowsoper,1),randi(colsoper,1))=randi(maxopers,1); %mutate random member of operation
   elseif mut_choice==3 %leaf mapping mutation
       genotype.map(randi(rowsmap,1),randi(colsmap,1))=randi(maxleaves,1); %mutate random member of leaf map
   end
end
genotype_mutated=genotype;
end


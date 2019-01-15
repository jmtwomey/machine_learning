function [ genotype ] = gp_genoinit( columns,levels,leaves,windows,opers )
%GP_GENOINIT initializes a genotype with randomized parameters for use in
%gp_transform.m
%   inputs:
%       columns: input data column
%       levels: how many levels used for gp.transform.m
%       leaves: how many leaves used for gp.transform.m
%       window: window size used in feature construction
%       opers: max number of operations use in gp.transform

genotype.column=randi(columns);
for i=1:levels
    genotype.input{i}=ones(1,windows);
    genotype.map{i}=randi(leaves,1,leaves);
    genotype.func{i}=randi(opers,1,leaves);
end
genotype.fitness=0;
end

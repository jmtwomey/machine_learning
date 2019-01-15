close all
clear
clc

%variable selection
%--------------------------------------------------------------------------
%   genetic parameters
survivors=6;
population=survivors*2;
generations=100;
%offspring_per_survivor=2;
%   transformation construction parameters
opers=7; %do not change until more operations are added to gp_transform
tranf_leaves=6; %must be less than or equal to window size
tranf_levels=6; %must be less than or equal to window size
%   feature construction parameters
windows=6;
responsechoice=1; %which fault to optimize for?
num_mutations=5;





%import data
%--------------------------------------------------------------------------
load('C:\Users\Jimmy\Box Sync\share\phm competition\Saurabh\DataComb\NaN_Removal\NTrain\NCombPlant1.mat')
load('C:\Users\Jimmy\Box Sync\share\phm competition\Data\raw data\Train mat files\Plant1.mat')

%preprocess data
%--------------------------------------------------------------------------
response=NCombPlant(windows:end,end-6+responsechoice); %cut out response vector
complist=unique(plant{1}(:,1)); %find list of components
sensor1=complist*8-6; %find indices for sensor 1 for each component
sensor2=sensor1+1;
sensor3=sensor2+1;
sensor4=sensor3+1;
ref1=sensor4+1;
ref2=ref1+1;
ref3=ref2+1;
ref4=ref3+1;

[~,columns]=size(NCombPlant);
zoneslist=unique(plant{2}(:,1));
power=zeros(length(zoneslist),1);
power(1)=columns-6;
for i=2:length(zoneslist) %find indices for power in each zone
    power(i)=power(i-1)-2;
end
power=sort(power);
contin_ind=sort(vertcat(sensor1,sensor2,power)); %indices for all sensor 1 and 2 values and power values
discr_ind=sort(vertcat(sensor3,ref1,ref2,ref3,ref4));%indices for all sensor 3 and reference values


%NCombPlant=NCombPlant(:,2:end-6); %remove time vector and response vectors
NCombPlant=NCombPlant(:,contin_ind);%reduce to continuous value vectors
[~,columns]=size(NCombPlant);



%initialize genotypes
%--------------------------------------------------------------------------
for i=1:population
    genotypei=gp_genoinit(columns,tranf_levels,tranf_leaves,windows,opers);
    genotype{i}=genotypei;
end

current_optim=genotype{1}; %initialize most optimal solution
j=1;
while j<generations && current_optim.fitness<1;
    tic
    %construct phenotype
    %--------------------------------------------------------------------------
    for i=1:population
        inputi=NCombPlant(:,genotype{i}.column); %use input data column selection
        features=gp_transform(inputi,genotype{i},tranf_leaves,tranf_levels,windows);%input_data,genotype,num_leaves,num_levels
    end

    %evaluate fitness
    %--------------------------------------------------------------------------
    for i=1:population
        genotype{i}.fitness=gp_fitness(features,response);
    end
    
    
    %select most fit population
    %--------------------------------------------------------------------------
    %extract fitnesses into data vector
    fitnesses=zeros(population,1);
    for i=1:population
        fitnesses(i)=genotype{i}.fitness;
    end
    [~,inds]=sort(fitnesses);
    surviving_geno=inds(1:survivors);
    died_geno=inds(survivors+1:end);
    
    %record "most fit"
    if current_optim.fitness<genotype{surviving_geno(1)}.fitness
        current_optim=genotype{surviving_geno(1)}; 
    end
    fprintf('Most fit phenotype of generation %d has a fitness of %d out of 1 \n',j,current_optim.fitness)

    %mutate fit genotypes
    %--------------------------------------------------------------------------
    k=0;
    for i=[surviving_geno',surviving_geno']%vector of indices of genotypes to mutate
        k=k+1;
        input_prob=0.3;%probability of mutating input columns
        operation_prob=0.7;%probability of mutating functions
        map_prob=0.75;%probability of mutating leaf maps
        maxcolumns=columns;
        maxopers=opers;
        maxleaves=tranf_leaves;
        probs=[input_prob,operation_prob,map_prob,maxcolumns,maxleaves,maxopers];%collect input parameters for mutation function
        genotype_new{k} = gp_mutate( genotype,i,num_mutations,probs );
        %[ genotype_mutated ] = gp_mutate( genotype,num_mutations,input_prob,operation_prob,map_prob,maxcolumns,maxleaves,maxopers )
    end
    genotype=genotype_new;
    
    
    
    j=j+1;
    toc
end


function [ fitness ] = gp_fitnessmulti( features,response )


featclass1=features(response==1,:);
featclass0=features(response==0,:);

% %find average value
 class1avg=mean(featclass1);
 class0avg=mean(featclass0);
 
 fitness=pdist([class1avg;class0avg]);

end

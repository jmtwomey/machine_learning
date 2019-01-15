function [ ksstat ] = gp_fitness( features,response )

featclass{1}=features(response==1,:);
featclass{2}=features(response==0,:);

% %find average value
% class1avg=mean(featclass{1});
% class2avg=mean(featclass{2});
% output_args=pdist([class1avg;class2avg]);

[~,~,ksstat]=kstest2(featclass{1},featclass{2});
end

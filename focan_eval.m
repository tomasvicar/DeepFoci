clc;clear all;close all force;
% dbstop if error
% dbclear if error
addpath('utils')
addpath('3DNucleiSegmentation_training')
addpath('unet_detection')


% res_focan( 0.35777 ,25.572,18,10,0)


% dfsdfsfd

% try 
% parpool(3);
% end
% 
% v1 = optimizableVariable('c',[-1,1]);
% v2 = optimizableVariable('median_size',[5,30]);
% v3 = optimizableVariable('d',[12,40],'Type','integer');
% vars = [v1,v2,v3];
% 
% fun = @(x) -1*res_focan(x.c,x.median_size,x.d,10,0);

% results = bayesopt(fun,vars,'UseParallel',0,'MaxObjectiveEvaluations',150);


% save('opt_focan.mat','results');

results.c=0.017596 ;
results.median_size=6.6423;
results.d=13;

fun2 = @(x) res_focan(x.c,x.median_size,x.d,100,1);

tmp = fun2(results);

dice_res_ja = tmp{1};
dice_res_jarda = tmp{2};
dice_ja_jarda = tmp{3};
dice = (mean(dice_res_ja) + mean(dice_res_jarda))/2

counts_res= tmp{4};
counts_ja= tmp{5};
counts_jarda= tmp{6};


figure()
y=[dice_res_ja',dice_res_jarda',dice_ja_jarda'];
boxplot(y)


figure()
plot(counts_res,(counts_jarda+counts_ja)/2,'*')
ylim([0,100])
xlim([0,100])

figure()
plot(counts_jarda,counts_ja,'*')
ylim([0,100])
xlim([0,100])


save('opt_res_focan.mat','tmp');

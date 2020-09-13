clc;clear all;close all force;
% dbstop if error
% dbclear if error
addpath('utils')
addpath('3DNucleiSegmentation_training')
addpath('unet_detection')





try 
parpool(3);
end

v1 = optimizableVariable('c',[-1,1]);
v2 = optimizableVariable('median_size',[5,30]);
v3 = optimizableVariable('d',[12,50],'Type','integer');
vars = [v1,v2,v3];

fun = @(x) -1*res_focan(x.c,x.median_size,x.d,10,0);

results = bayesopt(fun,vars,'UseParallel',1,'MaxObjectiveEvaluations',500);


save('opt_focan.mat','results');

fun2 = @(x) res_focan(x.c,x.median_size,x.d,100,1);

tmp = fun2(results.XAtMinObjective);

dice_res_ja = tmp{1};
dice_res_jarda = tmp{2};
dice_ja_jarda = tmp{3};
dice = (mean(dice_res_ja) + mean(dice_res_jarda))/2


figure()
y=[dice_res_ja',dice_res_jarda',dice_ja_jarda'];
boxplot(y)



save('opt_res_focan.mat','tmp');

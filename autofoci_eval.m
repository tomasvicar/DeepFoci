clc;clear all;close all force;
% dbstop if error
% dbclear if error
addpath('utils')
addpath('3DNucleiSegmentation_training')
addpath('unet_detection')

try 
parpool(4);
end


v1 = optimizableVariable('T_oep',[0,0.001]);
v2 = optimizableVariable('T',[0,1]);
v3 = optimizableVariable('d',[12,50],'Type','integer');
v4 = optimizableVariable('th',[3,20],'Type','integer');
vars = [v1,v2,v3,v4];

fun = @(x) -1*res_autofoci(x.T_oep,x.T,x.d,x.th,20,0);

results = bayesopt(fun,vars,'UseParallel',1,'MaxObjectiveEvaluations',500);


save('opt.mat','results');

fun2 = @(x) res_autofoci(x.T_oep,x.T,x.d,x.th,100,1);

tmp = fun2(results.XAtMinObjective);

dice_res_ja = tmp{1};
dice_res_jarda = tmp{2};
dice_ja_jarda = tmp{3};
dice = (mean(dice_res_ja) + mean(dice_res_jarda))/2


figure()
y=[dice_res_ja',dice_res_jarda',dice_ja_jarda'];
boxplot(y)



save('opt_res.mat','tmp');

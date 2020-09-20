clc;clear all;close all force;
% dbstop if error
% dbclear if error
addpath('utils')
addpath('3DNucleiSegmentation_training')
addpath('unet_detection')

% try 
% parpool(4);
% end

%  32    17

% v1 = optimizableVariable('d',[5,50],'Type','integer');
% v2 = optimizableVariable('th',[3,20],'Type','integer');
% vars = [v1,v2];
% 
% fun = @(x) -1*res_cellprofiler(x.d,x.th,20,0);
% 
% results = bayesopt(fun,vars,'UseParallel',1,'MaxObjectiveEvaluations',50);
% 
% 
% save('opt_cellprofiler.mat','results');
load('opt_cellprofiler.mat','results');

fun2 = @(x) res_cellprofiler(x.d,x.th,100,1);

tmp = fun2(results.XAtMinObjective);

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



figure()
y=[dice_res_ja',dice_res_jarda',dice_ja_jarda'];
boxplot(y)



save('opt_res_cellprofiler.mat','tmp');

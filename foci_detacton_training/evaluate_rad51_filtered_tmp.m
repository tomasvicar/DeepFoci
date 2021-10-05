clc;clear all;close all force;
addpath('../utils')

data_path = 'Z:\000000-My Documents\data_u87_nhdf_rad51_resaved_for_training_norm_nofilters';

nuc_mask_path = 'Z:\000000-My Documents\data_u87_nhdf_rad51_resaved';

data_chanels = {'a','b'};
matReaderData = @(x) matReader(x,'data',data_chanels,'norm_perc');
mask_chanels = {'a'};
matReaderMask = @(x) matReader(x,'mask',mask_chanels,'norm_no');
model_name = 'rad51_pretrained_filtered_tmp';

paralel_load = 1;


files = subdirx([data_path '/*data_53BP1.mat']);
in_layers = length(data_chanels);
out_layers = 3;


% dlnet = load(['C:/Data/Vicar/foci_new/resutls_a_b_ab_allfolds_1/final_net.mat']);
dlnet = load(['../../final_net.mat']);
dlnet = dlnet.dlnet;

patchSize = [96 96 48];


tmp_folder = ['../../resutls_' model_name];

tmp_folder_test = [tmp_folder '_test'];

files_test = files;
files_test_result = {};
for file_num = 1:length(files_test)

    disp(['evaluation test  '  num2str(file_num)  '/' num2str(length(files_test))])

    file  = files_test{file_num};
    
    
    results_name = replace( norm_path(file), norm_path(data_path), norm_path(tmp_folder_test));

    results_path = fileparts(results_name);

    results_name = [results_path '/result.mat'];
    
%     mask_predicted = load(results_name);
%     mask_predicted = mask_predicted.mask_predicted;
%     
%     data = matReaderData([file num2str(0)]);
% 
%     mask_predicted = predict_by_parts_foci_new(data,out_layers,dlnet,patchSize);

    
    nuc_mask_name = replace(norm_path(file), norm_path(data_path), norm_path(nuc_mask_path));
    
    nuc_mask_name = [fileparts(nuc_mask_name) '/mask.tif'];
    
    
    
%     mask = imread(nuc_mask_name);
%     mask = imresize3(mask,[505  681   48],'nearest');
    
%     gt_points = load([fileparts(file) '/points_53BP1.mat']);
%     gt_points = gt_points.mask_points_53BP1;
%     
%     
%     L = bwlabeln(mask);
%     N = max(L(:));
%     for k = 1:N
%        tmp = (L == k).*double(gt_points);
%        if  sum(tmp(:))==0
%           mask(L==k) = 0;
%        end 
%     end
%     
%     
%     mask = mask>0;
%     vel=[7 7 3];
%     [X,Y,Z] = meshgrid(linspace(-1,1,vel(1)),linspace(-1,1,vel(2)),linspace(-1,1,vel(3)));
%     sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
%     mask = imerode(mask,sphere);
%     
%     mask_predicted(mask == 0) = 0;
%     
% 
% 
%     mkdir(results_path)
% 
%     save(results_name,'mask_predicted')

    files_test_result = [files_test_result,results_name];

end






T = optimizableVariable('T',[0.6,8.5]);
h = optimizableVariable('h',[0.1,9.9]);
d = optimizableVariable('d',[2,25]);

vars = [T,h,d];



mask_chanels = {'a','b','ab'};

mkdir(tmp_folder)
for evaluate_index = 1:out_layers

    fun = @(x) -evaluate_detection_all_rad51(files_test,files_test_result,evaluate_index,matReaderMask,x.T,x.h,x.d);

    opt_results = bayesopt(fun,vars,'NumSeedPoints',5,'MaxObjectiveEvaluations',25,'UseParallel',false);


    x = opt_results.XAtMinObjective;


%     x = struct();
%     x.T = 2.5887;
%     x.h = 0.90234;
%     x.d = 4.8105;

    [test_dice,results_points,gt_points] = evaluate_detection_all_rad51(files_test,files_test_result,evaluate_index,matReaderMask,x.T,x.h,x.d);


    save([tmp_folder '/resutls_' mask_chanels{evaluate_index} '.mat'],'opt_results','test_dice','results_points','gt_points')

    aa = 1;
    save([tmp_folder '/test_dice_' mask_chanels{evaluate_index} '_' num2str(test_dice)  '.mat'],'aa')


    
    
end








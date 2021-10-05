clc;clear all;close all force;
addpath('../utils')

data_path='../../rad51_alldata/data_u87_nhdf_rad51_resaved_for_training_norm_nofilters';

nuc_mask_path = '../../rad51_alldata/data_u87_nhdf_rad51_resaved';

data_chanels = {'a','b'};
matReaderData = @(x) matReader(x,'data',data_chanels,'norm_perc');
mask_chanels = {'a'};
matReaderMask = @(x) matReader(x,'mask',mask_chanels,'norm_no');
model_name = 'rad51_pretrained';

paralel_load = 1;


files = subdirx([data_path '/*data_53BP1.mat']);
in_layers = length(data_chanels);
out_layers = 3;


dlnet = load(['C:/Data/Vicar/foci_new/resutls_a_b_ab_allfolds_1/final_net.mat']);
dlnet = dlnet.dlnet;

patchSize = [96 96 48];


tmp_folder = ['../../resutls_' model_name];

tmp_folder_test = [tmp_folder '_test'];

files_test = files;
files_test_result = {};
for file_num = 1:length(files_test)

    disp(['evaluation test  '  num2str(file_num)  '/' num2str(length(files_test))])

    file  = files_test{file_num};
    data = matReaderData([file num2str(0)]);

    mask_predicted = predict_by_parts_foci_new(data,out_layers,dlnet,patchSize);

    
    nuc_mask_name = replace(norm_path(file), norm_path(data_path), norm_path(nuc_mask_path));
    
    nuc_mask_name = [fileparts(nuc_mask_name) '/mask.tif'];
    
    
    mask = imread(nuc_mask_name);
    mask = imresize3(mask,[505  681   48],'nearest');
    
    mask_predicted(mask == 0) = 0;
    
    results_name = replace( norm_path(file), norm_path(data_path), norm_path(tmp_folder_test));

    results_path = fileparts(results_name);

    results_name = [results_path '/result.mat'];

    mkdir(results_path)

    save(results_name,'mask_predicted')

    files_test_result = [files_test_result,results_name];

end






T = optimizableVariable('T',[0.6,8.5]);
h = optimizableVariable('h',[0.1,9.9]);
d = optimizableVariable('d',[2,25]);

vars = [T,h,d];

evaluate_index = 1;

mkdir(tmp_folder)
for evaluate_index = 3:out_layers

    fun = @(x) -evaluate_detection_all_rad51(files_test,files_test_result,evaluate_index,matReaderMask,x.T,x.h,x.d);

    opt_results = bayesopt(fun,vars,'NumSeedPoints',5,'MaxObjectiveEvaluations',25,'UseParallel',false);


    x = opt_results.XAtMinObjective;


    [test_dice,results_points,gt_points] = evaluate_detection_all_rad51(files_test,files_test_result,evaluate_index,matReaderMask,x.T,x.h,x.d);


    save([tmp_folder '/resutls_' mask_chanels{evaluate_index} '.mat'],'opt_results','test_dice','results_points','gt_points')

    aa = 1;
    save([tmp_folder '/test_dice_' mask_chanels{evaluate_index} '_' num2str(test_dice)  '.mat'],'aa')


    
    
end

mask_chanels = {'a','b','ab'}







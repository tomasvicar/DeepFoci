clc;clear all;close all force;
addpath('../utils')

p = gcp('nocreate');
if isempty(p)
    parpool()
end
    
rng(42)

data_path='../../data_u87_nhdf_resaved_for_training';
folds = 5;


in_layers = {'a','b','c'};
out_layers = {'a','b'};


matReaderData = @(x,stats,whole) readFile(x,'data',in_layers,'norm_perc',stats,whole);
matReaderMask = @(x,whole) readFile(x,'mask',out_layers,'norm_no',[],whole);


files = subdirx([data_path '/*data_53BP1.mat']);





for fold = 1:folds

    [files_test,files_train_valid] = subfolder_based_split(files,fold,folds);
    
    [files_valid,files_train] = subfolder_based_split(files_train_valid,1,6);
   
    
    
    [file_stats_train] = get_stats(files_train,in_layers);
    
    [file_stats_valid] = get_stats(files_valid,in_layers);
    
    [file_stats_test] = get_stats(files_test,in_layers);
    
    
    drawnow;
    
    
end
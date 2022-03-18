clc;clear all;close all force;
addpath('../utils')

dices_all = {};
for k = 1:3


    all_vars = load(['tmp' num2str(k) '.mat']);
    tmp_folder = all_vars.tmp_folder;
    data_path = all_vars.data_path;
    matReaderMask = all_vars.matReaderMask;
    matReaderData= all_vars.matReaderData;
    out_layers = all_vars.out_layers;
    dlnet = all_vars.dlnet;
    patchSize = all_vars.patchSize;

    tmp_folder_valid_results = [tmp_folder '_valid_results'];

    files_valid = subdir([data_path '/valid/data_*.mat']);
    files_valid = {files_valid(:).name};
    files_valid = cellfun(@(x) [x '0'], files_valid,UniformOutput=false);
    


    dices = [];
    files_valid_result = {};
    for file_num = 1:length(files_valid)
        
        disp(['evaluation valid  '  num2str(file_num)  '/' num2str(length(files_valid))])
        
        file  = files_valid{file_num};
       

        img = matReaderData(file);

        mask = matReaderMask(file);
        drawnow;


        results_name = replace( norm_path(file), norm_path(data_path), norm_path(tmp_folder_valid_results));
    
        results_path = fileparts(results_name);
        
        results_name = [results_path '/result.mat'];
        

        mask_predicted = predict_by_parts(img,out_layers,dlnet,patchSize);
        
%         mask_predicted = load(results_name);
%         mask_predicted = mask_predicted.mask_predicted;

        
        files_valid_result = [files_valid_result,results_name];
        d = dice(mask>0,mask_predicted>0.5);

        dices = [dices,d];
    end



    dices_all = [dices_all,dices];

    disp(median(dices))

end


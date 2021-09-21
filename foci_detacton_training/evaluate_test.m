clc;clear all;close all;
addpath('../utils')

out_layers = 2;
patchSize = [96 96 48];

matReaderData = @(x) matReader(x,'data',{'a','b','c'},'norm_perc');
matReaderMask = @(x) matReader(x,'mask',{'a','b'},'norm_no');


dlnet = load('tmp_test_net.mat');
dlnet = dlnet.dlnet;

files_test = load('tmp_files_test.mat');
files_test = files_test.files_test;

for file_num = 1:length(files_test)
    file  = files_test{file_num};
    
    
    data = matReaderData([file num2str(0)]);
    mask = matReaderMask([file num2str(0)]);
    
    mask_predicted = predict_by_parts_foci_new(data,out_layers,dlnet,patchSize);
    
    
    drawnow;
    
    
end


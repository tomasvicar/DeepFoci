clc; clear all; close all force;
addpath('../utils')

filenames = subdir('../../../FOR ANALYSIS/*for_class.mat');


for filename_num = 1:120:length(filenames)

    filename = filenames(filename_num).name;
    disp(filename_num)
    disp(filename);
    
    app = klikac(filename);
    while isvalid(app)
        pause(0.1); 
    end


end

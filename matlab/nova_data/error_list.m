clc;clear all;close all;
addpath('../utils')
addpath('../nuclei_segmentation_training')


data_folders = {...
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Late gH2AX+53BP1 foci - different IR types, doses, cell types';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\15N 90st 4Gy NHDF+U87 gH2AX+53BP1';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení';
    };


for_uniques = {};
wholes = {};
for data_folder_num = 1:length(data_folders)

    data_folder = data_folders{data_folder_num};
    
    
    error_folder = split(data_folder,'\');
    error_folder = [error_folder{end}];

    listing = subdir([error_folder '/*.mat']);

    for error_num = 1:length(listing)
        error_name = listing(error_num).name;
        
        load(error_name,'filename')

        tmp = split(filename,'\');
        whole = join(tmp(end-5:end-1),'\');
        whole = whole{1};
        for_unique = join(tmp(end-5:end-3),'\');
        for_unique = for_unique{1};

        for_uniques = [for_uniques,for_unique];
        wholes = [wholes,whole];
    end


end


u = unique(for_uniques);


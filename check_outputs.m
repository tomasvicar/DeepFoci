clc;clear all;close all;
addpath('utils')

od_martina = subdir('D:\foci_error\od_martina\NHDF_30min PI all doses_ANALYZOVAN-NEULOZENO/*cell_orig*.mat');
od_martina = {od_martina(:).name};
results_od_martina = [];
for k =1:length(od_martina)
    tmp= isfile(replace(od_martina{k},'cell_orig','result'));
    results_od_martina = [results_od_martina,tmp];
end

z_googlu = subdir('D:\foci_error\z_googlu\NHDF_merge\NHDF_30min PI/*cell_orig*.mat');
z_googlu = {z_googlu(:).name};
results_z_googlu = [];
for k =1:length(z_googlu)
    
    tmp= isfile(replace(z_googlu{k},'cell_orig','result'));
  
    results_z_googlu = [results_z_googlu,tmp];
end




clc;clear all;close all force;
addpath('../utils')

data_path='../../data_u87_nhdf_resaved_for_training_norm_nofilters';



data_chanels = {'a'};
matReaderData = @(x) matReader(x,'data',data_chanels,'norm_perc');
mask_chanels = {'a'};
matReaderMask = @(x) matReader(x,'mask',mask_chanels,'norm_no');






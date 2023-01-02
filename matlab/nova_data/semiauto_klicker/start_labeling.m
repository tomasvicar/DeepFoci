clc;clear all; close all force;

% mkdir('completed')
% 
% folder_names = {...
%     '../../../../FOR ANALYSIS/Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení_labeling_new/RAD51 + gH2AX'
%     };
% 
% filenames_orig001 = {};
% 
% for folder_num = 1:length(folder_names)
%     folder_name = folder_names{folder_num};
%     tmp = subdir([folder_name '/*cell001.mat']);
%     filenames_orig001 = [filenames_orig001,{tmp(:).name}];
% end
% 
% 
% filenames_sets = {};
% for file_num = 1:length(filenames_orig001)
%     
%     tmp = subdir([fileparts(filenames_orig001{file_num}) '/*cell*.mat']);
%     tmp = tmp(cellfun(@(x) ~contains(x,'cell_orig'),{tmp(:).name}));
%     
%     filenames_sets = [filenames_sets,{{tmp(:).name}}];
% end
% 
% 
% rng(42)
% filenames_sets = filenames_sets(randperm(length(filenames_sets)));
% save('filenames_sets_rad51.mat','filenames_sets')
% % save('filenames_sets.mat','filenames_sets')

filenames_sets = load('filenames_sets_rad51.mat');
% filenames_sets = load('filenames_sets.mat');
filenames_sets = filenames_sets.filenames_sets;



step = 3;
for file_num = 100:step:length(filenames_sets)

    a = 'saved';
    save(['completed/' num2str(file_num,'%04.f') '.mat'],'a')
    filenames_part = [filenames_sets{file_num:file_num+step-1}];
    app = two_colors(filenames_part);
    while isvalid(app)
        pause(0.1); 
    end
end


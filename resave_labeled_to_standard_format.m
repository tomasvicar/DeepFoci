clc;clear all;close all;
addpath('utils')

orig_data_path = 'D:\foky_testovaci_data\orig';
labeled_path = 'D:\foky_testovaci_data\znacena';
save_folder = '../data_test';




orig_filenames = subdirx([orig_data_path '/*01.ics']);

labled_filenames = subdirx([labeled_path '/*' 'result*.mat']);
pos = regexp(labled_filenames,'result\d\d\d\.mat$');
labled_filenames = labled_filenames(cellfun(@(x) ~isempty(x),pos));




labled_filenames_pahts = cellfun(@(x) fileparts(x),labled_filenames,'UniformOutput',false);

unique_folders = unique(labled_filenames_pahts);
for unique_folder = unique_folders
    
    unique_folder_labled = unique_folder{1};
    unique_folder_orig = replace(unique_folder_labled,labeled_path,orig_data_path);
    
    
    orig_filename = orig_filenames(cellfun(@(x)  contains(x,unique_folder_orig), orig_filenames));
    labeled_filenames_allcells = labled_filenames(cellfun(@(x)  contains(x,unique_folder_labled), labled_filenames));
    
    
    [a,b,c]=read_ics_3_files(char(orig_filename));
    
    if isempty(labeled_filenames_allcells)
        
        save(['../errors/' replace(replace(datestr(now),' ','_'),':','_') 'no_cells.mat'],'orig_filename')
        continue
    end
    
    for labeled_cell_num = 1:length(labeled_filenames_allcells)
        labeled_filename_allcells = labeled_filenames_allcells{labeled_cell_num};
        labeled_filename_allcells_input = replace(labeled_filename_allcells,'result','cell');
        
        
        lbls = load(labeled_filename_allcells);
        input = load(labeled_filename_allcells_input); 
    end
        
    
    
    mask = imread();
    
    
    
    
    
    drawnow;
    
    
    
    
    
    
    
end










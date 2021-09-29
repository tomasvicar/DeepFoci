clc;clear all;close all;


resutls_folder = 'C:\Data\Vicar\foci_new';


reutls_name = 'resutls_a_b_ab_allfolds';
img_types = {'a','b','ab'};

res_all = struct();
for data_type = img_types
    res_all.(data_type{1}) = [];
    
end


for fold = 1:5
    
    
    
    results_folder_actual = [resutls_folder '/' reutls_name '_' num2str(fold)];
    
    
    
    for data_type = img_types
        
        res = load([results_folder_actual '/resutls_' data_type{1}  '.mat' ]);
        drawnow;
        
        res_all.(data_type{1}) = [res_all.(data_type{1}) res.test_dice];
        
    end
    
    
end



res_all.ab_sep = [];

for fold = 1:5
    
    
    
    results_folder_actual = [resutls_folder '/' reutls_name '_' num2str(fold)];
    
    
    
    
    
    res_all.ab_sep = [res_all.ab_sep dice];
    
end
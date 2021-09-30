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
    
    res_a = load([results_folder_actual '/resutls_a.mat' ]);
    res_b = load([results_folder_actual '/resutls_b.mat' ]);
    res_ab = load([results_folder_actual '/resutls_ab.mat' ]);
    
    ab_gts = res_ab.gt_points;
    a_res = res_a.results_points;
    b_res = res_b.results_points;
    
    dices = [];
    for k = 1:length(ab_gts)
        
        gt_points = ab_gts{k};
        
        a = a_res{k};
        b = b_res{k};
        
        
        factor = 2;
        d_t = 10;
        
        r=a(:,1);
        c=a(:,2);
        v=a(:,3);
        v = v * factor;
        pos1 = [r,c,v];
        
        r=b(:,1);
        c=b(:,2);
        v=b(:,3);
        v = v * factor;
        pos2 = [r,c,v];
        

        D = pdist2(pos1,pos2);
        D(D>d_t)=Inf;
                
       
        [assignment,cost]=munkres(D);

        new_points = [];
        for ass_ind = 1:length(assignment)
            ass = assignment(ass_ind);
            if ass ==0
                continue; 
            end

            new_point = int32((pos1(ass_ind,:) + pos2(ass,:))/2);

            new_point(3) = int32(round(new_point(3)/factor));


            new_points = [new_points;new_point];

        end
        
        
        res_points = new_points;
        
        
        
        dice = dice_points(gt_points,res_points);
        
        dices = [dices,dice];
    end
    
    dice = mean(dices);
    
    res_all.ab_sep = [res_all.ab_sep dice];
    
end







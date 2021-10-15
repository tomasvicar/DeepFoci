clc;clear all;close all;

load("D:\foky_new\resutls_rad51_pretrained_filtered_tmp\resutls_a.mat")



dices = zeros(1,length(gt_points));

for file_num = 1:length(gt_points)

    
    gt_points_tmp = gt_points{file_num};
    res_points_tmp = results_points{file_num};
    
    dice = dice_points(gt_points_tmp,res_points_tmp);

    if isempty(gt_points_tmp)
        dice = 9999;
    end
    
    dices(file_num) = dice;
    
end



dice = mean(dices(dices~=9999));

tmp = dices(dices~=9999);

boxplot(tmp)

title_name = 'rad51_dice';

savefig(title_name)
print(title_name,'-dpng')
print(title_name,'-depsc')
print(title_name,'-dsvg')




function [dice,results_points,gt_pointss] = evaluate_detection_all_rad51(files,files_result,evaluate_index,maskReader,T,h,d)


dices = zeros(1,length(files));
results_points = cell(1,length(files));
gt_pointss = cell(1,length(files));

fprintf(1,'%s\n\n',repmat('.',1,length(files)));

parfor file_num = 1:length(files)
%     disp([num2str(file_num) '/' num2str(length(files))])
    fprintf(1,'\b|\n');
    
    file = files{file_num};
    file_result = files_result{file_num};
    
    gt = maskReader([file num2str(0)]);
    res = load(file_result);
    res = res.mask_predicted;
    
    gt = gt(:,:,:,1);
    res = res(:,:,:,evaluate_index);
     
    
    gt_points = detect(gt,0.5,0.1,2);
    res_points = detect(res,T,h,d);

    
    dice = dice_points(gt_points,res_points);

    dices(file_num) = dice;
    
    results_points{file_num} = res_points;
    
    gt_pointss{file_num} = gt_points;
    
end


dice = mean(dices);

end


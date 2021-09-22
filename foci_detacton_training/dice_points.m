function [dice] = dice_points(gt_poits,res_points)

   d_t = 10;

   D = pdist2(res_points,gt_poits);
       
       
   D(D>d_t)=Inf;

   [assignment,cost]=munkres(D);

   fp = sum(assignment==0);

   assignment(assignment==0)=[];

   tp = length(assignment);

   ass_2 = 1:length(gt_poits);

   ass_2(assignment)=[];


   fn = length(ass_2);
   
   dice = (2 * tp) / (2 * tp + fp + fn);




end


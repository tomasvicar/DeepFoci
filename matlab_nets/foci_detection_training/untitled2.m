

load('detection_model_old.mat');

xxx = load('additional_parms.mat');


optimal_params.points_53BP1 = xxx.optimal_params.points_53BP1;


save(['detection_model' '.mat'],'dlnet','optimal_params')
function [features_new] = get_features_all(features,cell_num)



  
    features_new=features(:,[1,2,3,4]);
    
    features_new=[features_new,features(:,5:13)];
    
    features_new=[features_new,features(:,35:46)];

    
    
    features_new = addvars(features_new,features.MaxIntensitya./features.mediana,'NewVariableNames','MaxDMedA');
    features_new = addvars(features_new,features.MaxIntensityb./features.medianb,'NewVariableNames','MaxDMedB');
    features_new = addvars(features_new,features.MaxIntensityab./features.medianab,'NewVariableNames','MaxDMedAB');
     
    
    features_new = addvars(features_new,features.MeanIntensitya./features.mediana,'NewVariableNames','MeanDMedA');
    features_new = addvars(features_new,features.MeanIntensityb./features.medianb,'NewVariableNames','MeanDMedB');
    features_new = addvars(features_new,features.MeanIntensityab./features.medianab,'NewVariableNames','MeanDMedAB');



    features_new = addvars(features_new,features.MaxIntensitya./features.percentile99a,'NewVariableNames','MaxDpercentileA');
    features_new = addvars(features_new,features.MaxIntensityb./features.percentile99b,'NewVariableNames','MaxDpercentileB');
    features_new = addvars(features_new,features.MaxIntensityab./features.percentile99ab,'NewVariableNames','MaxDpercentileAB');


    features_new = addvars(features_new,features.MeanIntensitya./features.percentile99a,'NewVariableNames','MeanDpercentileA');
    features_new = addvars(features_new,features.MeanIntensityb./features.percentile99b,'NewVariableNames','MeanDpercentileB');
    features_new = addvars(features_new,features.MeanIntensityab./features.percentile99ab,'NewVariableNames','MeanDpercentileAB');    





     sigmas=[6,9,15,25];
     for sigma = sigmas
  
         features_new = addvars(features_new,features.(['CentroidValueaG' num2str(sigma)])./features.CentroidValuea,'NewVariableNames',['CentroidValueaG' num2str(sigma) 'DCentroidValue']);
         features_new = addvars(features_new,features.(['CentroidValuebG' num2str(sigma)])./features.CentroidValueb,'NewVariableNames',['CentroidValuebG' num2str(sigma) 'DCentroidValue']);
         features_new = addvars(features_new,features.(['CentroidValueabG' num2str(sigma)])./features.CentroidValueab,'NewVariableNames',['CentroidValueabG' num2str(sigma) 'DCentroidValue']);
 
     end
     
     
     sigmas=[6,9,15,25];
     for sigma = sigmas
  
         features_new = addvars(features_new,features.(['CentroidValueaG' num2str(sigma)])-features.CentroidValuea,'NewVariableNames',['CentroidValueaG' num2str(sigma) 'MCentroidValue']);
         features_new = addvars(features_new,features.(['CentroidValuebG' num2str(sigma)])-features.CentroidValueb,'NewVariableNames',['CentroidValuebG' num2str(sigma) 'MCentroidValue']);
         features_new = addvars(features_new,features.(['CentroidValueabG' num2str(sigma)])-features.CentroidValueab,'NewVariableNames',['CentroidValueabG' num2str(sigma) 'MCentroidValue']);
 
     end     
     



     sigmas=[6,9,15,25];
     for sigma = sigmas
  
         features_new = addvars(features_new,features.(['CentroidValueaMin' num2str(sigma)])./features.CentroidValuea,'NewVariableNames',['CentroidValueaMin' num2str(sigma) 'DCentroidValue']);
         features_new = addvars(features_new,features.(['CentroidValuebMin' num2str(sigma)])./features.CentroidValueb,'NewVariableNames',['CentroidValuebMin' num2str(sigma) 'DCentroidValue']);
         features_new = addvars(features_new,features.(['CentroidValueabMin' num2str(sigma)])./features.CentroidValueab,'NewVariableNames',['CentroidValueabMin' num2str(sigma) 'DCentroidValue']);
 
     end
    

     sigmas=[6,9,15,25];
     for sigma = sigmas
  
         features_new = addvars(features_new,(features.CentroidValuea-features.(['CentroidValueaMin' num2str(sigma)]))./features.CentroidValuea,'NewVariableNames',['CentroidValueaMin' num2str(sigma) 'MDCentroidValue']);
         features_new = addvars(features_new,(features.CentroidValueb-features.(['CentroidValuebMin' num2str(sigma)]))./features.CentroidValueb,'NewVariableNames',['CentroidValuebMin' num2str(sigma) 'MDCentroidValue']);
         features_new = addvars(features_new,(features.CentroidValueab-features.(['CentroidValueabMin' num2str(sigma)]))./features.CentroidValueab,'NewVariableNames',['CentroidValueabMin' num2str(sigma) 'MDCentroidValue']);
 
     end

     
     
    cell_num=cell_num{:,:};
    cell_nums=unique(cell_num)';

    tmp=features.MaxIntensitya;
    for k = cell_nums
        tmp(cell_num==k)=tmp(cell_num==k)/median(tmp(cell_num==k));
    end
    features_new = addvars(features_new,tmp,'NewVariableNames','MaxaCellMedNorm');
    
    tmp=features.MaxIntensityb;
    
    for k = cell_nums
        tmp(cell_num==k)=tmp(cell_num==k)/median(tmp(cell_num==k));
    end
    features_new = addvars(features_new,tmp,'NewVariableNames','MaxbCellMedNorm');
    
    tmp=features.MaxIntensityab;
    
    for k = cell_nums
        tmp(cell_num==k)=tmp(cell_num==k)/median(tmp(cell_num==k));
    end
    features_new = addvars(features_new,tmp,'NewVariableNames','MaxabCellMedNorm');

    
    
    tmp=features.MeanIntensitya;
    
    for k = cell_nums
        tmp(cell_num==k)=tmp(cell_num==k)/median(tmp(cell_num==k));
    end
    features_new = addvars(features_new,tmp,'NewVariableNames','MeanaCellMedNorm');
    
    tmp=features.MaxIntensityb;
    
    for k = cell_nums
        tmp(cell_num==k)=tmp(cell_num==k)/median(tmp(cell_num==k));
    end
    features_new = addvars(features_new,tmp,'NewVariableNames','MeanbCellMedNorm');
    
    tmp=features.MaxIntensityab;
    
    for k = cell_nums
        tmp(cell_num==k)=tmp(cell_num==k)/median(tmp(cell_num==k));
    end
    features_new = addvars(features_new,tmp,'NewVariableNames','MeanabCellMedNorm');
    

    
    tmp=features.MaxIntensitya;
    
    for k = cell_nums
        tmp(cell_num==k)=tmp(cell_num==k)/mean(tmp(cell_num==k));
    end
    features_new = addvars(features_new,tmp,'NewVariableNames','MaxaCellmeanNorm');
    
    tmp=features.MaxIntensityb;
    
    for k = cell_nums
        tmp(cell_num==k)=tmp(cell_num==k)/mean(tmp(cell_num==k));
    end
    features_new = addvars(features_new,tmp,'NewVariableNames','MaxbCellmeanNorm');
    
    tmp=features.MaxIntensityab;
    
    for k = cell_nums
        tmp(cell_num==k)=tmp(cell_num==k)/mean(tmp(cell_num==k));
    end
    features_new = addvars(features_new,tmp,'NewVariableNames','MaxabCellmeanNorm');

    
    
    tmp=features.MeanIntensitya;
    
    for k = cell_nums
        tmp(cell_num==k)=tmp(cell_num==k)/mean(tmp(cell_num==k));
    end
    features_new = addvars(features_new,tmp,'NewVariableNames','MeanaCellmeanNorm');
    
    tmp=features.MaxIntensityb;
    
    for k = cell_nums
        tmp(cell_num==k)=tmp(cell_num==k)/mean(tmp(cell_num==k));
    end
    features_new = addvars(features_new,tmp,'NewVariableNames','MeanbCellmeanNorm');
    
    tmp=features.MaxIntensityab;
    
    for k = cell_nums
        tmp(cell_num==k)=tmp(cell_num==k)/mean(tmp(cell_num==k));
    end
    features_new = addvars(features_new,tmp,'NewVariableNames','MeanabCellmeanNorm');
    
    
end
    
function [features_new] = get_features_half(features,cell_num)



  
    features_new=features(:,[1,2,3,4]);

    
    features_new=[features_new,features(:,35:46)];

    


     sigmas=[6,9,15,25];
     for sigma = sigmas
  
         features_new = addvars(features_new,features.(['CentroidValueaG' num2str(sigma)])./features.CentroidValuea,'NewVariableNames',['CentroidValueaG' num2str(sigma) 'DCentroidValue']);
         features_new = addvars(features_new,features.(['CentroidValuebG' num2str(sigma)])./features.CentroidValueb,'NewVariableNames',['CentroidValuebG' num2str(sigma) 'DCentroidValue']);
         features_new = addvars(features_new,features.(['CentroidValueabG' num2str(sigma)])./features.CentroidValueab,'NewVariableNames',['CentroidValueabG' num2str(sigma) 'DCentroidValue']);
 
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

     
    
    
end
    
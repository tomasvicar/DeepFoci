clc;clear all; close all;

path = 'Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
path_out='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\example_folder';


names=strsplit(genpath(path),';');


names_tmp={};
for k=1:length(names)
    n=names{k};
    
    
    names_tmp2=names;
    names_tmp2(k)=[];
    
    tmp=cellfun(@(x) contains(x,n),names_tmp2);
    
    
    
    if sum(tmp)==0
    
        names_tmp=[names_tmp,n];
        
        
    end
    
    
end
names=names_tmp;



rng(5)


q=randperm(length(names),600);


names=names(q);

save('names_foci_sample.mat','names')


for k =1 :length(names)

    copyfile(names{k}, [path_out '/' num2str(k,'%04.f')]);


end






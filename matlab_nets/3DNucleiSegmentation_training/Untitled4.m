names=subdir('trenovaci_data_preprocess_1');
names={names.name};

for name=names
    name=name{1};
    movefile(name,strrep(name,'.tif','.mat'));
    
    
end
function create_4_tmpfiles_for_each(file_folders,data_path,tmp_path)

for k=1:length(file_folders)
   file_folder=file_folders{k};
   
   file_folder = replace(file_folder,'\','/');
   data_path = replace(data_path,'\','/');
   tmp_path = replace(tmp_path,'\','/');
   file_folder = [tmp_path replace(file_folder,data_path,'') 'tmpmatfile'];
   
   mkdir(fileparts(file_folder))
   
   for kk=1:4       
       tmp=[file_folder num2str(kk)];
       a=1;
       save(tmp,'a')
   end
   
end


end


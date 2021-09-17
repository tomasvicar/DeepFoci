function [volds] = create_4_for_each(volds,filenames,data_path)

Files={};
for k=1:length(filenames)
   file=filenames{k};
   
   file = replace(file,'\','/');
   data_path = replace(data_path,'\','/');
   file = [data_path '_tmpmatfiles' replace(file,data_path,'')];
   
   mkdir(fileparts(file))
   
   for k=1:4       
       tmp=[file num2str(k)];
       Files=[Files,tmp];
       a=1;
       save(tmp,'a')
   end
   
end

volds.Files=Files;


end


function [file_stats] = get_stats(files,in_layers)


    file_stats = {};

    parfor file_num = 1:length(files)
        
        file = files{file_num};
        
        matReaderData_forstats = @(x) readFile(x,'data',in_layers,'norm_no',[],1);
        
        
        data = matReaderData_forstats(file);
        
        file_stat = [];
        for k = 1:size(data,4)
            perc = 0.0001;
            a = data(:,:,:,k);
            tmp = [double(prctile(a(:),perc*100)) double(prctile(a(:),100-perc*100))];
            
            file_stat = [file_stat;tmp];
        end
        
        file_stats = [file_stats,file_stat] ;
        
    end

    
    

end


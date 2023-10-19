function [data] = read_data_ordered(filename)
    if exist([filename 'fov.txt'],'file')
        name_fov_file = [filename 'fov.txt'];
    elseif exist([filename 'roi.txt'],'file')
        name_fov_file = [filename 'roi.txt'];
    else
        error('no textfile')
    end
    chanel_names={};
    fid = fopen(name_fov_file);
    tline = 'dfdf';
    while ischar(tline)
        if contains(tline,'Name=')
            chanel_names=[chanel_names tline(6:end)];
        end
        tline = fgetl(fid);
    end
    fclose(fid);



   
    order = [0,0,0];
    if (contains(lower(chanel_names{1}),'53bp1')||contains(lower(chanel_names{1}),'rad51'))
        order(1) = 1;
    elseif (contains(lower(chanel_names{2}),'53bp1')||contains(lower(chanel_names{2}),'rad51'))
        order(1) = 2;
    elseif (contains(lower(chanel_names{3}),'53bp1')||contains(lower(chanel_names{3}),'rad51'))  
        order(1) = 3;
    else
        error('fsfdsfsd')
    end

    if contains(lower(chanel_names{1}),'gh2ax')
        order(2) = 1;
    elseif contains(lower(chanel_names{2}),'gh2ax')
        order(2) = 2;
    elseif contains(lower(chanel_names{3}),'gh2ax') 
        order(2) = 3;
    else
        error('fsfdsfsd')
    end

    if (contains(lower(chanel_names{1}),'dapi')||contains(lower(chanel_names{1}),'topro'))
        order(3) = 1;
    elseif (contains(lower(chanel_names{2}),'dapi')||contains(lower(chanel_names{2}),'topro'))
        order(3) = 2;
    elseif (contains(lower(chanel_names{3}),'dapi')||contains(lower(chanel_names{3}),'topro'))  
        order(3) = 3;
    else
        error('fsfdsfsd')
    end
   
    
    
    data = read_ics_3_files(filename);
 
    data = data([2,1,3]);
    data = data(order);
end
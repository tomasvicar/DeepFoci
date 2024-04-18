function [chanel_names] = get_channel_names(filename)
    name_fov_file = [filename 'fov.txt'];
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
end
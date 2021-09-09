function data = matReaderData(filename)


    num=str2num(filename(end));
    filename=filename(1:end-1);
    
    size_v=[505  681   48];
    
    if num==1
        postion_vec1=1:floor(size_v(1)/2)+20;
        postion_vec2=1:floor(size_v(2)/2)+20;
    elseif num==2
        postion_vec1=floor(size_v(1)/2)-20:size_v(1);
        postion_vec2=1:floor(size_v(2)/2)+20;
    elseif num==3
        postion_vec1=1:floor(size_v(1)/2)+20;
        postion_vec2=floor(size_v(2)/2)-20:size_v(2);
    elseif num==4
        postion_vec1=floor(size_v(1)/2)-20:size_v(1);
        postion_vec2=floor(size_v(2)/2)-20:size_v(2);   
    end
        

    matObject = matfile(filename);
    data=single(matObject.rgb(postion_vec1,postion_vec2,:,1:3));

end
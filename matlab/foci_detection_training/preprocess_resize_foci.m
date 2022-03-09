function [a,b,c] = preprocess_resize_foci(a,b,c)

    a=imresize3(a,[505  681   48]);
    b=imresize3(b,[505  681   48]);
    c=imresize3(c,[505  681   48]);
    
end


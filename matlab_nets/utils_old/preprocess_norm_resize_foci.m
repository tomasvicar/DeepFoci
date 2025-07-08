

function [a,b,c]=preprocess_norm_resize_foci(a,b,c)



    a=norm_percentile(a,0.0001)-0.5;
    b=norm_percentile(b,0.0001)-0.5;
    c=norm_percentile(c,0.0001)-0.5;
    
    
    a=imresize3(a,[505  681   48]);
    b=imresize3(b,[505  681   48]);
    c=imresize3(c,[505  681   48]);

end


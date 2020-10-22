function [a,b,c]=preprocess_filters_small(a,b,c,gpu)

%     a=single(a);
%     b=single(b);
%     c=single(c);

    a=double(a);
    b=double(b);
    c=double(c);
    
    if gpu
        a=gpuArray(a);
        b=gpuArray(b);
        c=gpuArray(c);
    end 


%     a=medfilt3(a,[5 5 1],'symmetric');
%     b=medfilt3(b,[5 5 1],'symmetric');
%     c=medfilt3(c,[5 5 1],'symmetric');
    
    for k=1:size(a,3)
        a(:,:,k)=medfilt2(a(:,:,k),[5 5]);
        b(:,:,k)=medfilt2(b(:,:,k),[5 5]);
        c(:,:,k)=medfilt2(c(:,:,k),[5 5]);
    end
    
    
    a=imgaussfilt3(a,[0.6 0.6 0.3]);
    b=imgaussfilt3(b,[0.6 0.6 0.3]);
    c=imgaussfilt3(c,[0.6 0.6 0.3]);
    
    if gpu
        a=gather(a);
        b=gather(b);
        c=gather(c);
    end
    
    
end
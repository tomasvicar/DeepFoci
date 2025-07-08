function [a]=preprocess_filters(a,gpu)



    
    if gpu
        a=gpuArray(a);
    end 


    
    for k=1:size(a,3)
        a(:,:,k)=medfilt2(a(:,:,k),[3 3]);
    end 
    
    a=imgaussfilt3(a,[1 1 1]);
    
    if gpu
        a=gather(a);
    end
    
    
end
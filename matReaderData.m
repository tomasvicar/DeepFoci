function [window_k] = matReaderData(filename)

    load(filename);
    
    window_k=window_k(4:end-4,4:end-4,2:end-2,:);
%     window_k=single(mat2gray(window_k,[90,600])-0.5);
    window_k=single((window_k-mean(window_k(:)))/std(window_k(:))) ;
end


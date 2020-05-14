function [window_k] = matReaderData_test(filename)


    load(filename);
    
    window_k=window_k(3:end-3,3:end-3,2:end-2,:);
    
    
%     window_k=window_k(4:end-4,4:end-4,2:end-2,:);
%     window_k=single(mat2gray(double(window_k),[90,600])-0.5);
%     window_k=single(mat2gray(window_k,[90,600])-0.5);
%     window_k=single((window_k-mean(window_k(:)))/std(window_k(:)));
    
    window_k=single(mat2gray(window_k,[0,1]));
    
end


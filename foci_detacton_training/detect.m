function [detections_out2] = detect(res,T,h,d)


    
    [X,Y,Z] = meshgrid(linspace(-1,1,d),linspace(-1,1,d),linspace(-1,1,int16(d/2)));
    sphere=sqrt(X.^2+Y.^2+Z.^2)<1;

%     tic
%     tmp = imdilate(res,sphere);
%     toc
    tmp = res;


    tmp = imextendedmax(tmp,h).*(res>T);

    
    s = regionprops(tmp>0,res,'centroid','MeanIntensity');
    
    detections_out = round(cat(1, s.Centroid));
    values = cat(1, s.MeanIntensity);
    
    detections = detections_out;
    
    if isempty(detections)
       detections_out2 = zeros(0,3);
       return; 
    end
    
    detections(:,3) = detections(:,3)*2;
    
    
    D = pdist2(detections,detections);
    D_t = D < d;
    
    V = repmat(values,[1,size(values,1)])';
    V(D_t == 0) = -Inf;
    
    
    
    [max_tmp,use_ind] = max(V,[],2);
    
    detections_out2 = detections_out(unique(use_ind),:);
    
    
%     values2 = values(unique(use_ind));
%     
%     figure();
%     imshow(max(res,[],3),[]);
%     hold on;
%     plot(detections_out2(:,1),detections_out2(:,2),'r*')
%     
    
    

    drawnow;
    
    
    
    
end


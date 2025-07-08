function [loss] = MSEpixelLoss(Y,T)

q=0.5*(Y-T).^2;

loss=sum(q(:))/numel(q);  
            
            
end


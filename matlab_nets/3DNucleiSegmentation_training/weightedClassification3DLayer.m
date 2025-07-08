classdef weightedClassification3DLayer < nnet.layer.ClassificationLayer
               
    properties
        % Vector of weights corresponding to the classes in the training
        % data
        ClassWeights
    end

    methods
        function layer = weightedClassification3DLayer(classWeights, name)
            % layer = weightedClassificationLayer(classWeights) creates a
            % weighted cross entropy loss layer. classWeights is a row
            % vector of weights corresponding to the classes in the order
            % that they appear in the training data.
            % 
            % layer = weightedClassificationLayer(classWeights, name)
            % additionally specifies the layer name. 

            % Set class weights
            layer.ClassWeights = classWeights;

            % Set layer name
            if nargin == 2
                layer.Name = name;
            end

            % Set layer description
            layer.Description = 'Weighted cross entropy';
        end
        
        function loss = forwardLoss(layer, Y, T)
            % loss = forwardLoss(layer, Y, T) returns the weighted cross
            % entropy loss between the predictions Y and the training
            % targets T.
                
            s=1:length(size(T));
            s=s([2 1 3:end]);
            T=permute(T,s);
        
            W = layer.ClassWeights;
            
%             if length(size(Y))>4
%                 
%                 
%                 imshow4(gather(cat(2,Y(:,:,:,2,1),T(:,:,:,2,1))))
%                 drawnow;
%             end
            
            
            WW=ones(size(T),'like',T);
            for k=1:length(W)
                if length(size(T))==5
                    WW(:,:,:,k,:)=W(k);
                    
                else
                    WW(:,:,:,k)=W(k);
                end
            end
            
            tmp=WW.*(T.*log(Y));
            loss = -sum(tmp(:))/numel(tmp(:));
        end
        
        function dLdY = backwardLoss(layer, Y, T)
            % dLdY = backwardLoss(layer, Y, T) returns the derivatives of
            % the weighted cross entropy loss with respect to the
            % predictions Y.
            
%             if length(size(Y))>4
%                 
%                 
%                 imshow4(gather(cat(2,Y(:,:,:,2,1),T(:,:,:,2,1))))
%                 drawnow;
%             end

            
            

            
            s=1:length(size(T));
            s=s([2 1 3:end]);
            T=permute(T,s);

            W = layer.ClassWeights;
            
            for k=1:length(W)
                if length(size(T))==5
                    WW(:,:,:,k,:)=W(k);
                    
                else
                    WW(:,:,:,k)=W(k);
                end
            end
			
            dLdY = -(WW.*T./Y)/numel(T(:));
        end
    end
end
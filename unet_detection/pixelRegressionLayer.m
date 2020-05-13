classdef pixelRegressionLayer < nnet.layer.RegressionLayer
        
    properties
        % (Optional) Layer properties.

        % Layer properties go here.
    end
 
    methods
        function layer = pixelRegressionLayer(name)           
            % (Optional) Create a myRegressionLayer.

            % Layer constructor function goes here.
            layer.Name = name;
        end

        function loss = forwardLoss(layer, Y, T)
            % Return the loss between the predictions Y and the 
            % training targets T.
            %
            % Inputs:
            %         layer - Output layer
            %         Y     – Predictions made by network
            %         T     – Training targets
            %
            % Output:
            %         loss  - Loss between Y and T

            % Layer forward loss function goes here.
            
            s=1:length(size(T));
            s=s([2 1 3:end]);
            T=permute(T,s);
            
            q=0.5*(Y-T).^2;
%             q=abs(Y-T);
            
            loss=sum(q(:))/numel(q);   
            
        end
        
        function dLdY = backwardLoss(layer, Y, T)
            % Backward propagate the derivative of the loss function.
            %
            % Inputs:
            %         layer - Output layer
            %         Y     – Predictions made by network
            %         T     – Training targets
            %
            % Output:
            %         dLdY  - Derivative of the loss with respect to the predictions Y        

            % Layer backward loss function goes here.
            
            s=1:length(size(T));
            s=s([2 1 3:end]);
            T=permute(T,s);
            
            q=Y-T;
%             q=sign(Y-T);
            
            
            dLdY=q/numel(q);
            
        end
    end
end
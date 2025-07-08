classdef preluLayer < nnet.layer.Layer
    % Example custom PReLU layer.

    
    methods
        function layer = preluLayer() 
            % layer = preluLayer(numChannels, name) creates a PReLU layer
            % with numChannels channels and specifies the layer name.

            % Set layer name.
            layer.Name = "gfgfdgdfgdfgdf";

            % Set layer description.
            layer.Description = "hbghfgh";

        end
        
        function Z = predict(layer, X)
            % Z = predict(layer, X) forwards the input data X through the
            % layer and outputs the result Z.
            
            
            
            if length(size(X))>4
                
                
                imshow4(gather(X(:,:,:,1,1)))
                drawnow;
            end
            
            Z = X;
        end
        
        function [dLdX] = backward(layer, X,Z, dLdZ,qqqq)
            % [dLdX, dLdAlpha] = backward(layer, X, ~, dLdZ, ~)
            % backward propagates the derivative of the loss function
            % through the layer.
            % Inputs:
            %         layer    - Layer to backward propagate through
            %         X        - Input data
            %         dLdZ     - Gradient propagated from the deeper layer
            % Outputs:
            %         dLdX     - Derivative of the loss with respect to the
            %                    input data
            %         dLdAlpha - Derivative of the loss with respect to the
            %                    learnable parameter Alpha
            
            
            % Sum over all observations in mini-batch.
            dLdX = dLdZ;
        end
    end
end
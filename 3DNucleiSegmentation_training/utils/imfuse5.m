function [varargout] = imfuse5(varargin)

fused = zeros([size(varargin{1}),nargin]);
if size(varargin{1},4)<2
    if size(varargin{1},3)>1
        for i = 1:nargin
            fused(:,:,:,i) = double(varargin{i});
        end
    else
        for i = 1:nargin
            fused(:,:,i) = double(varargin{i});
        end
    end
else
    for i = 1:nargin
        fused(:,:,:,:,i) = double(varargin{i});
    end
end
if nargout == 1
    varargout{1} = fused;
end
imshow5(fused,1,1,'all','gray',1)
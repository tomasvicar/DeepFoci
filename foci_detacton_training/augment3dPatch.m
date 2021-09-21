function patchOut = augment3dPatch(patchIn)
% Randomly rotate and reflect image patches and return the augmented
% patches in a two-column table as required by the trainNetwork function.
%
% Copyright 2018 The MathWorks, Inc.

inpVol = cell(size(patchIn,1),1);
inpResponse = cell(size(patchIn,1),1);

% 5 augmentations: nil,rot90,fliplr,flipud,rot90(fliplr)
fliprot = @(x) rot90(fliplr(x));
augType = {@rot90,@fliplr,@flipud,fliprot};

for id=1:size(patchIn,1)
    rndIdx = randi(8,1);
    tmpImg =  patchIn.InputImage{id};
    tmpResp = patchIn.ResponseImage{id};
    if rndIdx < 5
        out =  augType{rndIdx}(tmpImg);
        respOut = augType{rndIdx}(tmpResp);
    else
        out =  tmpImg;
        respOut = tmpResp;
    end
    min_v=rand()*0.6-0.3;
    max_v=1+rand()*0.6-0.3;
    out(:,:,:,1)=single(mat2gray_nocrop(out(:,:,:,1)+0.5,[min_v max_v]))-0.5;
    min_v=rand()*0.6-0.3;
    max_v=1+rand()*0.6-0.3;
    out(:,:,:,2)=single(mat2gray_nocrop(out(:,:,:,2)+0.5,[min_v max_v]))-0.5;
    min_v=rand()*0.6-0.3;
    max_v=1+rand()*0.6-0.3;
    out(:,:,:,3)=single(mat2gray_nocrop(out(:,:,:,3)+0.5,[min_v max_v]))-0.5;
    
    inpVol{id}=out;
    inpResponse{id}=respOut;
end

patchOut = table(inpVol,inpResponse);


end



function data = mat2gray_nocrop(data,range)

    data = (data - range(1))/(range(2) - range(1));


end








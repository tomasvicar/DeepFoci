function patchOut = augment3dPatch_valid(patchIn)
% Randomly rotate and reflect image patches and return the augmented
% patches in a two-column table as required by the trainNetwork function.
%
% Copyright 2018 The MathWorks, Inc.

inpVol = cell(size(patchIn,1),1);
inpResponse = cell(size(patchIn,1),1);

% 5 augmentations: nil,rot90,fliplr,flipud,rot90(fliplr)
fliprot = @(x) rot90(fliplr(x));

for id=1:size(patchIn,1)
    
    tmpImg =  patchIn.InputImage{id};
    tmpResp = patchIn.ResponseImage{id};

    out =  tmpImg;
    respOut = tmpResp;

    
    inpVol{id}=out;
    inpResponse{id}=respOut;
end

patchOut = table(inpVol,inpResponse);


end











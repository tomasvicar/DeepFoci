% Disclaimer:  IMPORTANT:  This software was developed at the National Institute of Standards and Technology by employees of the Federal Government in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not subject to copyright protection and is in the public domain. This is an experimental system. NIST assumes no responsibility whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or any other characteristic. We would appreciate acknowledgment if the software is used. This software can be redistributed and/or modified freely provided that any derivative works bear some notice that they are derived from it, and any modified versions bear some notice that they have been modified.



function S = fill_holes(S, upper_bound)

S = logical(S);

if isinf(upper_bound)
    % the user has selected no upper limit (inf) for the fill holes size
    CC = bwconncomp(~S, 4);
    szs = zeros(numel(CC.PixelIdxList),1);
    for i = 1:numel(CC.PixelIdxList)
        szs(i,1) = numel(CC.PixelIdxList{i});
    end
    upper_bound = max(szs(:)) - 1;
    if isempty(upper_bound)
        upper_bound = 0;
    end
end

% BWu holds the mask of pixels where the holes larger than upper_bound have been filled
BWu = bwareaopen(~S, upper_bound, 4);
BWu = (~S) - BWu;

% remove the hole pixels from S that are in either the upper or lower mask
S(BWu>0) = 1;

end
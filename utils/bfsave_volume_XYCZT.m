function bfsave_volume_XYCZT(fname,img)

% it can fail if file exists
if isfile(fname)
    delete(fname)
end
bfsave(img, fname, 'dimensionOrder', 'XYCZT', 'Compression', 'LZW')
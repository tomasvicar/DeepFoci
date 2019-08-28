function imwrite_single_4D(name,data)

% data=single(data);
data=uint16(data);

%  Modify these variables to reuse this section: (enclosed by ----s)
%     - outputFileName  (filename in your question)
%     - data            (Id{k} in your question)
%


outputFileName = name;

for k=1:size(data,3)
    data_tmp=squeeze(data(:,:,k,:));

    % This is a direct interface to libtiff
    if k==1
        t = Tiff(outputFileName,'w');
%         imwrite(data_tmp,outputFileName)
    else
%         imwrite(data_tmp,outputFileName,'WriteMode','append')
        t = Tiff(outputFileName,'a');
    end
    tagstruct.ImageLength     = size(data_tmp,1);
    tagstruct.ImageWidth      = size(data_tmp,2);
    tagstruct.Photometric     = Tiff.Photometric.RGB;
    tagstruct.BitsPerSample   = 16;
    tagstruct.SamplesPerPixel = size(data_tmp,3);
    tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
    tagstruct.Compression=Tiff.Compression.LZW;
    tagstruct.RowsPerStrip    = 16;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct)


    

    t.write(data_tmp);
    

end

t.close();



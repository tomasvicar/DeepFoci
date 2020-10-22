function tiff_stack_single_color(nazev,data,k)

%  Modify these variables to reuse this section: (enclosed by ----s)
%     - outputFileName  (filename in your question)
%     - data            (Id{k} in your question)
%



outputFileName = nazev;
% This is a direct interface to libtiff
if k==1
    t = Tiff(outputFileName,'w');
else
    t = Tiff(outputFileName,'a');
end

tagstruct.ImageLength     = size(data,1);
tagstruct.ImageWidth      = size(data,2);
tagstruct.Photometric     = Tiff.Photometric.RGB;
tagstruct.BitsPerSample   = 32;
tagstruct.SamplesPerPixel = 3;
tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
tagstruct.Compression=Tiff.Compression.LZW;
tagstruct.RowsPerStrip    = 16;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software        = 'MATLAB';
t.setTag(tagstruct)

t.write(data);
t.close();




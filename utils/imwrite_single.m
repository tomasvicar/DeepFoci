function []=imwrite_single(data,name)

data=single(data);

outputFileName = name;

t = Tiff(outputFileName,'w');

tagstruct.ImageLength     = size(data,1);
tagstruct.ImageWidth      = size(data,2);
tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample   = 32;
tagstruct.SampleFormat = 3;
tagstruct.SamplesPerPixel = size(data,3);
tagstruct.RowsPerStrip    = 16;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software        = 'MATLAB';
t.setTag(tagstruct)


t.write(data);
t.close();

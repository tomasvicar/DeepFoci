function [img] = bfopen_volume_XYCZT(fname)


img = bfopen(fname);
shape_xy = size(img{1}{1,1});
shape_zct = img{1}{1,2};
shape_zct = split(shape_zct,';');

if length(shape_zct) == 5
    shape_zct = [str2num(replace(shape_zct{3},' Z?=1/','')),...
        str2num(replace(shape_zct{4},' C?=1/','')),...
        str2num(replace(shape_zct{5},' T?=1/',''))...
        ];
    shape_zct = [shape_zct(2),shape_zct(1),shape_zct(3)];
    
elseif length(shape_zct) == 4
    shape_zct = [str2num(replace(shape_zct{3},' Z?=1/','')),...
    str2num(replace(shape_zct{4},' C?=1/',''))...
    ];
    shape_zct = [shape_zct(2),shape_zct(1)];
    
elseif length(shape_zct) == 3
    shape_zct = [str2num(replace(shape_zct{3},' C?=1/','')),...
    ];
    shape_zct = [shape_zct(1)];
    
end


shape = [shape_xy,shape_zct];
img = reshape(cat(3, img{1}{:, 1}),shape);

function [s] = sphere_gui(shape)

[X,Y,Z] = meshgrid(linspace(-1,1,shape(1)*2+1),linspace(-1,1,shape(2)*2+1),linspace(-1,1,shape(3)*2+1));
s=sqrt(X.^2+Y.^2+Z.^2)<=1;
if shape(3)<2
    s = strel('disk',shape(1));
end

end


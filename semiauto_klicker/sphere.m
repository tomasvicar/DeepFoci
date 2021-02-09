function [strell] = sphere(shape)

[X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
strell=sqrt(X.^2+Y.^2+Z.^2)<1;


end


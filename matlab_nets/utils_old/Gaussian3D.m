function G = Gaussian3D(sigma_array, size_array)
% Amir Fazlollahi -- Australian e-Health Research Centre -- Jan 2013
%
% Gaussian3D Creates 3-D Gaussian Kernel of specified
% width (standard deviation) sigma_array=[sigma_x, sigma_y, sigma_z] with 
% profile length of size_array=[size_x, size_y, size_z]
%
%   How to use the function:
%
%   Sx=3;Sy=4;Sz=5;
%   G = Gaussian3D([Sx, Sy, Sz], [7*Sx, 7*Sy, 7*Sz]);
if(all([sigma_array ])>0 & length(size_array) == length(sigma_array))
    % Make 1D Gaussian kernel
    % Filter each dimension with the 1D Gaussian kernels\
    sigma_x=sigma_array(1);
    size_x=size_array(1);
    sigma_y=sigma_array(2);
    size_y=size_array(2);
    sigma_z=sigma_array(3);
    size_z=size_array(3);
    
%     x=-ceil(size_x/2):ceil(size_x/2);
%     Kx = exp(-(x.^2/(2*(sigma_x.^2))));
%     Kx = Kx/sum(Kx(:));
    % OR
    Kx = fspecial('gaussian', [1 round(size_x)], sigma_x);
    
    
%     y=-ceil(size_y/2):ceil(size_y/2);
%     Ky = exp(-(y.^2/(2*(sigma_y.^2))));
%     Ky = Ky/sum(Ky(:));
    % OR
    Ky = fspecial('gaussian', [1 round(size_y)], sigma_y);
    
%     z=-ceil(size_z/2):ceil(size_z/2);
%     Kz = exp(-(z.^2/(2*(sigma_z.^2))));
%     Kz = Kz/sum(Kz(:));
    % OR
    Kz = fspecial('gaussian', [1 round(size_z)], sigma_z);
    
    
    Hx=reshape(Kx,[length(Kx) 1 1]);
    Hy=reshape(Ky,[1 length(Ky) 1]);
    Hz=reshape(Kz,[1 1 length(Kz)]);
    
    % since gaussian Kernel is separable
    G=convn(Hz,convn(Hx,Hy));
end

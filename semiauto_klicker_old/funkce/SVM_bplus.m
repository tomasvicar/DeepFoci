function vys=SVM_bplus(Mdl,b_plus,data)

data=data-repmat(Mdl.Mu,[size(data,1) 1]);
data=data./repmat(Mdl.Sigma,[size(data,1) 1]);

w=Mdl.Beta;
a=Mdl.Alpha;
b=Mdl.Bias;
x=Mdl.SupportVectors  ;
y=Mdl.SupportVectorLabels;

b=b-b_plus;

% try
%     
% catch
%     o=;
% end
typ=Mdl.KernelParameters.Function;
if strcmp(typ,'polynomial')
    
    o= Mdl.KernelParameters.Order;
elseif strcmp(typ,'gaussian')
    o= Mdl.KernelParameters.Scale;
end






X=data;
m=size(X,1);
vys = zeros(m, 1);
for i = 1:m
    vys(i) = SVMpredict(X(i, :), a, x, y,o,typ);
end
vys=vys+b;

end



function [margin] = SVMpredict( x, alpha, X, Y, sigma,typ)
% Given the optimal dual variables of the SVM problem, the bias,
%   the training data, the training labels and a data point x, it
%   calculates the margin for x
m = length(alpha);
prod = zeros(m, 1);
if strcmp(typ,'polynomial')
    for i = 1:m
        
        prod(i) = polinom(x, X(i,:), sigma);
    end
elseif strcmp(typ,'gaussian')
    for i = 1:m
        
        prod(i) = RBF(x, X(i,:), sigma);
    end
end
margin = alpha' * (Y.*prod);

end


function [ K ] =polinom(x, y, p)
% Radial basis function (Gaussian) kernel

K = (1+x*y')^p;
end


function [ K ] = RBF(x, y, sigma)
% Radial basis function (Gaussian) kernel

    K = exp(-norm(x - y)^2/sigma);
end



function [a]=insertmatrix(a,b,roh)

x0=1:size(b,1);
y0=1:size(b,2);
z0=1:size(b,3);

x=roh(1):roh(1)+size(b,1)-1;
y=roh(2):roh(2)+size(b,2)-1;
z=roh(3):roh(3)+size(b,3)-1;

x0(x>size(a,1))=[];
x(x>size(a,1))=[];
y0(y>size(a,2))=[];
y(y>size(a,2))=[];
z0(z>size(a,3))=[];
z(z>size(a,3))=[];


a(x,y,z)=a(x,y,z)+b(x0,y0,z0);
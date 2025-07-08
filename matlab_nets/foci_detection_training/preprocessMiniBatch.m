function [X,Y] = preprocessMiniBatch(XCell,YCell)

X = cat(5,XCell{1:end});

Y = cat(5,YCell{1:end});

end
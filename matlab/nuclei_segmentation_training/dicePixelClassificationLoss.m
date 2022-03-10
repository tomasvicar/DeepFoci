function [loss] = dicePixelClassificationLoss(Y,T)

    my_eps = 1;
    my_sum = @(x) sum(x,'all');

    dice = ((2. * my_sum(Y.*T) + my_eps) / (my_sum(Y) + my_sum(T) + my_eps) );


    loss = 1 - dice;
end
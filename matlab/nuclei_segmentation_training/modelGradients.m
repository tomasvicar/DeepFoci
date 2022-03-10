function [gradients,state,loss] = modelGradients(dlnet,dlX,Y)

    [dlYPred,state] = forward(dlnet,dlX);
    
    loss = dicePixelClassificationLoss(dlYPred,Y);
    gradients = dlgradient(loss,dlnet.Learnables);

end
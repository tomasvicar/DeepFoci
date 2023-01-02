function [gradients,state,loss] = modelGradients(dlnet,dlX,Y)

    [dlYPred,state] = forward(dlnet,dlX);
    
    loss = MSEpixelLoss(dlYPred,Y);
    gradients = dlgradient(loss,dlnet.Learnables);

end
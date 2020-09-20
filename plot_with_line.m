function plot_with_line(x,y,max_count)


n = 1; % Polynomial Order
alfa = 0.95; % Desired Significance
xv = linspace(0, max(x))';

polyfcn = @(b,x) b(1).*x;

[beta,R,J,CovB,MSE,ErrorModelInfo]=nlinfit(x,y,polyfcn,1);


[yhat,delta] = nlpredci(polyfcn,xv,beta,R,'Jacobian',J);
[f] = nlpredci(polyfcn,x,beta,R,'Jacobian',J);



ybar = mean(y);
SStot = sum((y - ybar).^2);
SSreg = sum((f - ybar).^2);
SSres = sum((y - f').^2);
R2 = 1 - SSres/SStot;



figure()

hold on


ci=delta;

plot(xv, xv, 'k--')

% plot(xv, yhat+ci, '--g')
% plot(xv, yhat-ci, '--g')
% plot(xv, yhat, '-r')
fill([xv; xv(end:-1:1)],[yhat-ci;yhat(end:-1:1)+ci(end:-1:1)],[ 0.8500    0.3250    0.0980],'FaceAlpha',0.2,'EdgeColor','none');

title(['R^2=' num2str(R2) '; slope=' num2str(beta)])
plot(xv, yhat, '-','Color',[0.8500    0.3250    0.0980],'LineWidth',2)
plot(x, y, '.','Color',[ 0    0.4470    0.7410],'MarkerSize',10)

xlim([0 max_count])
ylim([0 max_count])




end
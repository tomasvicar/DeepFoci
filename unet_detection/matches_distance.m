function d=matches_distance(t1,t2)
% 
% hold off
% plot(t1(:,1),t1(:,2),'b*')
% hold on
% plot(t2(:,1),t2(:,2),'r*')




if length(t1)>0&&length(t2)>0
    D = pdist2(t1,t2);
    D(D>30)=99999999;
    [assignment,cost] = munkres(D);
    x=find(assignment);
    y=assignment(assignment>0);
    dd=D(sub2ind(size(D),x,y));
    x=x(dd<30);
    y=y(dd<30);
    d=length(x);
else
    d=0;
end


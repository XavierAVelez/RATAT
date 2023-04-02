function e = AgeModel()
% reads in the AgingFunction.txt file and fits the points to a 4th order
% polynomial. Points in AgingFunction.txt come from:
% doi:10.1371/journal.pone.0128839

A = readmatrix("AgingFunction.txt");
age = A(:,1);
vari = A(:,2);

order = 4;
p = polyfit(age,vari,order);

x = 0:89;
e = zeros(85,1);
for ii = order:-1:0
    e = e + (p(order-ii+1)*(x.^ii));
end

e = e(1,:);

%{
figure(1);
scatter(age, vari, 'filled');
hold on;
plot(x,e);
ylim([0 100]);
xlim([0 89]);
hold off;
%}

end
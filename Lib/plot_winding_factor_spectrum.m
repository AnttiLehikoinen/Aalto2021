
%W = dim.W;
%W = winding.layout_matrix

dim.Qs = 24;
dim.p = 11;

Qs = dim.Qs;
pn = dim.p;
ps = 0:(5*pn);

W = WindingLayout.concentrated(Qs, pn, 6, 1);

wfs = calculate_winding_factor(ps, W);

figure(1); clf; hold on; box on; grid on; grid('minor');
pn = dim.p;
bar(ps, pn*wfs(1,:), 'b');
bar(ps, -pn*wfs(2,:), 'r');
legend('Forward-rotating', 'Backward-rotating', 'Fontsize', 14);
title('Stator frame');
%ax = gca; ax.XTick = unique( [1 ax.XTick] );
xlabel('Harmonic order');
ylabel('Winding factor');

%Plot airgap flux density

solution_to_plot = static_solution;
step = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
motor_here = solution_to_plot.problem.model;
problem_here = solution_to_plot.problem;
gap = motor_here.airgap.airgaps(1);

%getting airgap triangulation
[tag, pag] = gap.t_ag(0);
msh_ag = SimpleMesh(pag, tag);

%finding nodes to plot
plot_angles = linspace(0, 2*pi/problem_here.msh.symmetrySectors, 5000);
r = dim.Sin - 0.05*dim.delta*sign(dim.Sout-dim.Sin);
x = r*cos(plot_angles);
y = r*sin(plot_angles);


els = msh_ag.point2element([x;y]); 
plot_angles = plot_angles(els>0); x = x(els>0); y = y(els>0);
els = els(els>0);

%computing B in the airgap
Araw = solution_to_plot.raw_solution(1:problem_here.Np, step);
A_ag = gap.tag_solution(Araw, pars.rotorAngle(step));
[Babs, Bvec] = calculate_B(A_ag, msh_ag);

Bvec = Bvec(:, els);
xnorm = sqrt(x.^2 + y.^2);
Brad = (Bvec(1,:).*x  + Bvec(2,:).*y) ./ xnorm;
Btan = (Bvec(1,:).*-y  + Bvec(2,:).*x) ./ xnorm;

figure(10); clf; hold on; box on; grid on;
plot(plot_angles/pi*180, Brad , 'b', 'linewidth', 1)
plot(plot_angles/pi*180, Btan , 'r', 'linewidth', 1)
title('Flux density')
xlabel('Angular coordinate (mech.deg.)');
ylabel('Flux density (T)');

%computing harmonic
a_p = trapz(plot_angles, Brad.*cos(dim.p*plot_angles)) * 2 / (2*pi/dim.symmetry_sectors);
b_p = trapz(plot_angles, Brad.*sin(dim.p*plot_angles)) * 2 / (2*pi/dim.symmetry_sectors);

plot(plot_angles/pi*180, a_p*cos(dim.p*plot_angles)+b_p*sin(dim.p*plot_angles), 'k--', 'linewidth', 1);

legend('Normal', 'Tangential', 'Fundamental', 'linewidth', 1)


%return
%{
figure(6); clf; hold on; box on;
%drawFluxDensity(mshc, sim.results.Xh, 'LineStyle', 'none'); colormap('jet'); colorbar;% caxis([0 2])
drawFluxDensity(msh_ag, A_ag, 'LineStyle', 'none'); colorbar;
%}

return
%plotting spectrum
%FIXME incorrect amplitudes, no full period available
bspec = fft( Brad ) * 2/numel(Brad);
Nharm = 37;
ns = (0:(Nharm-1)) * (2*pi/plot_angles(end));% / dim.p;

figure(11); clf; hold on; box on; grid on;
bar(ns, abs(bspec(1:Nharm)));
xlabel('Spatial harmonic order');
ylabel('Amplitude (T)');
title('Airgap flux density spectrum (normal component)');
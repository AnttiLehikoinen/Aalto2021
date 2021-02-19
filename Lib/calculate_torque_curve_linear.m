%calculate_torque_curve Torque curve of an SPM, vs current density.

Jrms = 1e6 * linspace(10, 45, 2);

problem = MagneticsProblem(motor); %creating a problem
phase_circuit = stator.winding_spec.circuit;
    
%no-load
%{
phase_circuit.set_source('uniform coil current', zeros(stator.winding_spec.phases, 1)); %EXPLAIN

%rotor angle to analyse
pars = SimulationParameters('rotorAngle', 0);

%solving
static_solution = problem.solve_static(pars);

Bag_plot;


%plotting
figure(5); clf; hold on; box on;
motor.plot_flux(static_solution);
title('No-load flux density');


return
%}


%setting source
Ipeak = sqrt(2)*Jrms * phase_circuit.conductor_area_per_turn_and_coil();
Is = xy(Ipeak.*[0; 1], problem);
phase_circuit.set_source('uniform coil current', Is);

%setting parameters
pars = SimulationParameters('rotorAngle', 0*Jrms/dim.p);

%solving problem
static_solution = problem.solve_static(pars);

%plotting torque
figure(6); clf; hold on; box on;
T = motor.compute_torque( static_solution );
plot(Jrms/1e6, T);
xlabel('Load angle (deg)');
ylabel('Torque (Nm)');

%plotting flux
figure(5); clf; hold on; box on;
motor.plot_flux(static_solution, numel(Jrms));


disp(['Shaft power: ' num2str(2*pi*dim.rpm/60*T(end)/1e3) ' kW at ' ...
    num2str(dim.rpm) ' rpm'])

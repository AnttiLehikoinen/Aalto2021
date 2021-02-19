%calculate_torque_curve Torque curve of a synchronous machine.
%
% This script calculates the torque curve versus pole angle, from static
% analysis using one rotor position.

angles = linspace(0, pi, 21); %pole angles to analyse
Jrms = 15e6; %current density Arms

problem = MagneticsProblem(motor); %creating a problem
phase_circuit = stator.winding_spec.circuit;

%no-load
%{
phase_circuit.set_source('uniform coil current', zeros(stator.winding_spec.phases, 1)); %EXPLAIN

%rotor angle to analyse
pars = SimulationParameters('rotorAngle', 0);

%solving
static_solution = problem.solve_static(pars);

%plotting
figure(5); clf; hold on; box on;
motor.plot_flux(static_solution);
title('No-load flux density');
return
%}


%setting source
Ipeak = sqrt(2)*Jrms * phase_circuit.conductor_area_per_turn_and_coil();
Is = xy(Ipeak*[cos(angles); sin(angles)], problem);
%Is = winding.xy(Ipeak*[cos(angles); sin(angles)]);
phase_circuit.set_source('uniform coil current', Is);

%setting parameters
pars = SimulationParameters('rotorAngle', 0*angles/dim.p);

%solving problem
static_solution = problem.solve_static(pars);

%plotting flux
figure(5); clf; hold on; box on;
motor.plot_flux(static_solution, 10);

%plotting torque
figure(6); clf; hold on; box on;
T = motor.compute_torque( static_solution );
plot(angles/pi*180, T);
xlabel('Load angle (deg)');
ylabel('Torque (Nm)');
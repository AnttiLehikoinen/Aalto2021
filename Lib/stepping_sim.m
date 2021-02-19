%stepping_sim Quasi-time-dependent stepping simulation.
%
% Fixed current density supply used, no damping effects of any kind
% considered

%operating point
rpm = dim.rpm;
Jrms = 55e6;
pole_angle = pi/180 * 90; %EXPLAIN WHY 90
angles = linspace(0, pi/6, 25); %electrical angles to step through
%angles = linspace(0, pi/6, 100); %electrical angles to step through

%initializing problem
problem = MagneticsProblem(motor);

%setting source
phase_circuit = motor.circuits.get('Phase winding');
Ipeak = sqrt(2)*Jrms * phase_circuit.conductor_area_per_turn_and_coil();
Is = xy(Ipeak*[cos(pole_angle); sin(pole_angle)], problem, 'angles', angles);
%Is = xy( [id; iq], problem, 'angles', angles) / winding.a;

phase_circuit.set_source('uniform coil current', Is);


%parameters
pars = SimulationParameters('f', rpm/60*dim.p, 'slip', 0, 'rotorAngle', angles/dim.p, ...
    'silent', ~true, 'rel', 0.9);

%solving
stepping_solution = problem.solve_static(pars);

%plotting example of flux
figure(5); clf; hold on; box on;
motor.plot_flux(stepping_solution, 1); %SHOW DIFFERENT STEPS


%plotting torque
T = motor.compute_torque( stepping_solution );
figure(7); clf; hold on; box on;
plot(angles/pi*180, T);
%ax = gca; ax.YLim(1) = 0;
%}

%return

%calculating iron losses
[Ptot, data_steinmetz] = ...
    time_domain_Steinmetz(stepping_solution, 'plotting_on', true);

%different approach
[Ptot2, data_bertotti] = frequency_domain_Bertotti( stepping_solution, 'plotting_on', false );

disp(['Iron losses from Steinmetz model: ' num2str(Ptot) ' W']);
disp(['Iron losses from Bertotti model: ' num2str(Ptot2) ' W']);

%COMMENT ON LARGE EDDIES --> frequency

%calculating copper losses
[P_Cu, data_pcu] = phase_circuit.losses( stepping_solution, 'plotting_on', true );

%calculating efficiency
Pout = 2*pi*rpm/60 * mean(T);
Pin = Pout + P_Cu + Ptot;
disp(['Efficiency = ' num2str(100*Pout/Pin)]);

disp(['Power density = ' num2str(Pout/motor.mass()/1e3), ' kW/kg'])

%back-emf
phase_circuit.include_lew = true;
voltage = phase_circuit.terminal_voltage(stepping_solution);
voltage_dq = phase_circuit.terminal_voltage( stepping_solution, 'output', 'space vector');
phase_voltage = phase_circuit.phase_bemf(stepping_solution);

figure(8); clf; hold on; box on; grid on;
plot( stepping_solution.ts, voltage );
plot( stepping_solution.ts, colnorm( voltage_dq), 'linewidth', 2 );
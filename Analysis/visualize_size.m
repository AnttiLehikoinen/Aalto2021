
L_turbine = 84 * 2.54e-2; H_turbine = 33 * 2.54e-2; %PW127
offset = [-0.5, 0.3];

figure(2); clf; hold on; box on; axis equal;
motor.visualize_axial();

%drawing heat sink
axial_offset = dim.leff/2;
rectangle('Position', [axial_offset, d_bore/2-h_fin_sic, l_sink, h_fin_sic], ...
    'FaceColor', [1 1 1]*0.8);
rectangle('Position', [axial_offset, -d_bore/2, l_sink, h_fin_sic], ...
    'FaceColor', [1 1 1]*0.8);


rectangle('Position', [offset(1), offset(2), L_turbine, H_turbine]);

axis([-0.7, 1.8, -0.3, 1.3]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% estimate of pressure drop in slot channel
% based on 
% https://en.wikipedia.org/wiki/Darcy%E2%80%93Weisbach_equation

%effective channel diameter
A_channel = A_coolant / wires_per_slot;
D_channel = 2*sqrt(A_channel/pi); %hydraulic diameter

%friction coefficient, assuming laminar flow
%FIXME prolly not true
Re = v_coolant*D_channel/nu; %Reynolds number
fD = 64/Re;

p_bar = dim.leff * fD * rho_coolant/2 * v_coolant^2 / D_channel / 1e5
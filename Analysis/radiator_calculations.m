%Simple calculations for the radiator

v_air = 50; %air velocity
D_duct = 1e-2; %single duct/pipe diameter

%air properties
%TODO include temperature, pressure effects
k_air = 23.84e-3; %thermal conductivity at 20C
nu_air = 1.516e-5; %kinematic viscosity at 20C


%computing Reynolds number
Re_air = v_air * D_duct / nu_air;

Pr = 0.71; %air Prandtl number
Nu_air = 0.027 * Re_air^(4/5) * 1; %TODO include viscosity factor


%heat transfer coefficient
h_air = Nu_air * k_air / D_duct
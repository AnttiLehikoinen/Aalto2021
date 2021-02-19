%heat transfer calculations

%coolant properties, paratherm LR for example
c_coolant = 2.0934e3; %heat capacity, kJ/kgK, Paratherm LR
rho_coolant = 700; %density
nu = 2.4e-6; %paratherm kinematic viscosity in m^2/s, 2.4 cSt

%slot heat transfer
%FIXME calculate estimate
h_wire = 200; %heat transfer coefficient, wire-to-coolant

Pcu_slot = P_Cu / dim.Qs;
wires_per_slot = winding.N_layers*winding.N_series*winding.wires_in_hand;
P_wire = Pcu_slot / wires_per_slot;

A_wire = pi*layout.diameter*dim.leff; %cooling surface area
dT_wire = P_wire / (A_wire * h_wire);
T_coolant = dim.temperature_stator - dT_wire;

%required mass flow
dT_coolant = 5; %coolant temperature rise
q = Pcu_slot / (dT_coolant*c_coolant); %mass flow per slot, kg/s
Q = q / rho_coolant; %flow rate, m^3/s
A_coolant = A_slot_free - Acopper_slot;
v_coolant = Q / A_coolant; %coolant velocity, m/s

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%heat sink dimensions

h_sink = 150; %heat sink to air
Wtot = P_Cu + Ptot;

%single-bore
%%{
d_bore = 0.4;
l_sink = 0.52;
fin_spacing = 1.0e-2;
fin_ribbing_factor = 2;
d_wall = 0.7e-2;

h_fin_sic = 0.05;
d_fin = 1e-3;

%material properties
k = 205; %aluminum
rho = 2700;

%fin efficiency
h_fin = h_fin_sic * fin_ribbing_factor;
mLc = sqrt(2*h_sink/(k*d_fin)) * h_fin;
eta_fin = tanh(mLc)/mLc;

number_of_fins = ceil(pi*d_bore/fin_spacing);
total_fin_area = 2*number_of_fins * h_fin*l_sink * eta_fin;
bore_area = (pi*d_bore - number_of_fins*d_fin)*l_sink;

dT = Wtot / ((total_fin_area + bore_area) * h_sink)

%mass
m_fins = h_fin*d_fin*l_sink * number_of_fins * rho
m_wall = l_sink * pi*d_bore*d_wall * rho
m_radiator = m_fins + m_wall
%}

%double-bore
%{
h_sink = 150; %heat sink to air

d_bore = 0.3;
l_sink = 0.35;
fin_spacing = 1.0e-2;
fin_ribbing_factor = 2;
d_wall = 0.7e-2;

h_fin_sic = 0.05;
d_fin = 1e-3;

%dependent parameters
h_fin = h_fin_sic * fin_ribbing_factor;
d_bore_inner = d_bore - h_fin_sic;

%material properties
k = 205; %aluminum
rho = 2700;

%fin efficiency
mLc = sqrt(2*h_sink/(k*d_fin)) * h_fin/2;
eta_fin = tanh(mLc)/mLc;

number_of_fins = ceil(pi*d_bore/fin_spacing);
total_fin_area = 2*number_of_fins * h_fin*l_sink * eta_fin;
bore_area = (pi*d_bore - number_of_fins*d_fin)*l_sink;
inner_bore_area = (pi*d_bore_inner - number_of_fins*d_fin)*l_sink;

dT = Wtot / ((total_fin_area + bore_area + inner_bore_area)*h_sink)

%mass
m_fins = h_fin*d_fin*l_sink * number_of_fins * rho
m_wall = l_sink * pi*d_bore*d_wall * rho
m_wall_inner = l_sink * pi*d_bore_inner*d_wall * rho
m_radiator = m_fins + m_wall + m_wall_inner
%}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% required air flow

%air temperature rise
dT_air = 20;

rho_air = 1;
c_air = 1e3; %specific heat capacity, J/kgK

q_air = Wtot / (c_air*dT_air); %mass flow
Q_air = q_air / rho_air; %volumetric flow, m^3/s

A_intake = 0.8*pi*d_bore^2/4;
v_min = Q_air / A_intake;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% drag calculation
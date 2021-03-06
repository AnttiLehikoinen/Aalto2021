%heat transfer calculations

%coolant properties, paratherm LR for example
c_coolant = 2.0934e3; %heat capacity, kJ/kgK, Paratherm LR
rho_coolant = 700; %density
nu = 2.4e-6; %paratherm kinematic viscosity in m^2/s, 2.4 cSt
k_coolant = 0.15; %thermal conductivity

%slot dimensions
wires_per_slot = winding.N_layers*winding.N_series*winding.wires_in_hand;
A_wire = pi*layout.diameter*dim.leff; %cooling surface area
A_coolant = A_slot_free - Acopper_slot; %cross-sectional area free for flow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% wire-to-coolant heat transfer coefficient

h_wire = 200; %heat transfer coefficient, wire-to-coolant, FIRST GUESS

%effective channel diameter, SIC
A_channel = A_coolant / wires_per_slot;
D_channel = 2*sqrt(A_channel/pi); %hydraulic diameter

%heat transfer coefficient, laminar flow.
% Base on https://en.wikipedia.org/wiki/Nusselt_number
Nu = 3.66; %for circular pipe, FIXME
h_wire = Nu * k_coolant / D_channel;

%version 2
V_fluid = A_coolant * dim.leff; %total fluid volume per active length
A_wire_total = A_wire * wires_per_slot; %total surface area
L = V_fluid / A_wire_total; %characteristic length: "For complex shapes, the length may be 
%defined as the volume of the fluid body divided by the surface area.

h_wire = Nu * k_coolant / L;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% heat rejection from wire to coolant

Pcu_slot = P_Cu / dim.Qs;
P_wire = Pcu_slot / wires_per_slot;


dT_wire = P_wire / (A_wire * h_wire);
T_coolant = dim.temperature_stator - dT_wire;

%required mass flow
dT_coolant = 5; %coolant temperature rise
q = Pcu_slot / (dT_coolant*c_coolant); %mass flow per slot, kg/s
Q = q / rho_coolant; %flow rate, m^3/s
v_coolant = Q / A_coolant; %coolant velocity, m/s

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%heat sink dimensions

h_sink = 265; %heat sink to air
Wtot = P_Cu + Ptot; %total losses to reject, TODO add inverter losses

%radiator material properties
k = 205; %aluminum
rho = 2700;

%honeycomb approximation: two concentric cylinders with a honeycomb-like
%ducting inbetween, with rectangular cells
%%{
d_bore = 0.4; %outer cylinder diameter
d_bore_inner = 0.3; %inner cylinder diameter
d_wall = 0.7e-2; %cylinder wall effective thickness

l_sink = 0.3; %axial length
d_duct = 1e-3; %duct wall thickness
w_duct = 1.0e-2; %duct size

%ducting efficiency, see
% https://en.wikipedia.org/wiki/Heat_sink#Fin_efficiency
L_duct_effective = sqrt(2) * (d_bore/2 - d_bore_inner/2)/2; %distance to closest bore
mLc = sqrt(2*h_sink/(k*d_duct)) * L_duct_effective;
eta_fin = tanh(mLc)/mLc;

%computing ducting area
A_bore = pi*(d_bore^2 - d_bore_inner^2)/4; %sink cross-sectional area
number_of_ducts = A_bore / w_duct^2;
duct_wall_area = 4*number_of_ducts * w_duct*l_sink; %4 walls per duct
dT = Wtot / (duct_wall_area * h_sink * eta_fin); %duct wall to ambient temp diff to dump the required heat

%computing ducting mass
duct_wall_volume = duct_wall_area/2*d_duct; %division by 2 here since each wall faces air on both sides
duct_wall_mass = duct_wall_volume * rho;

%bore mass
m_wall = l_sink * pi*d_bore*d_wall * rho;
m_wall_inner = l_sink * pi*d_bore_inner*d_wall * rho;

%total mass
m_radiator = duct_wall_mass + m_wall + m_wall_inner;
%}


%single-bore
%{
d_bore = 0.4;
l_sink = 0.52;
fin_spacing = 1.0e-2;
fin_ribbing_factor = 2;
d_wall = 0.7e-2;

h_fin_sic = 0.05;
d_fin = 1e-3;

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

T_ambient = T_coolant - dT;

disp(['Radiator heat rejection performance: ' num2str(Wtot/m_radiator*1e-3) ...
    ' kW/kg of heat rejected'])
disp([' at ' num2str(dT) ' C temperature difference to ambient at ' num2str(T_ambient) ' C'])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% required air flow

%air temperature rise
dT_air = 20;

rho_air = 1;
c_air = 1e3; %specific heat capacity, J/kgK

q_air = Wtot / (c_air*dT_air); %mass flow
Q_air = q_air / rho_air; %volumetric flow, m^3/s

A_intake = 0.8*pi*d_bore^2/4; %scoop frontal area
v_min = Q_air / A_intake; %minimum air velocity

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% drag calculation

%TODO from cooling air speed drop and momentum conservation
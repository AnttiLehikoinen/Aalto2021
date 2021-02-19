%Concentrated-winding design
dim = struct();

dim.Ubus = 1e3;
dim.rpm = 5000;
h_wall = 0.6e-3;

%general dimensions
mult = 5;
dim.p = 10*mult;
dim.Qs = 24*mult;
dim.delta = 2e-3; %total effective airgap
dim.leff = 180e-3;


%operating temperatures
dim.temperature_stator = 120;
dim.temperature_rotor = 120;

%winding parameters
winding = ConcentratedWindingSpec(dim);
winding.N_layers = 1;
winding.N_series = 1;
winding.wires_in_hand = 160;
winding.a = 1; %number of parallel paths
dim.stator_winding = winding;

layout = RoundWireLayout();
layout.diameter = 0.6e-3;
winding.layout_spec = layout;


dim.symmetry_sectors = winding.symmetry_period();


%stator dimensions
dim.Sout = 500e-3/2; %back radius
dim.htt_s = 2e-3; %tooth tip height
dim.hys = 6e-3;
dim.htt_taper_s = dim.htt_s / 2;
dim.r_slotbottom_s = 1e-3; %slot bottom corner fillet radius
dim.hslot_s = 17e-3;
dim.Sin = dim.Sout - dim.hslot_s - dim.hys;
dim.wslot_s = 2*pi*(dim.Sin + dim.htt_s)/dim.Qs * 0.5;
dim.wso_s = dim.wslot_s*0.7;

%stator materials
dim.stator_core_material = NO12();
dim.stator_stacking_factor = 0.99;
dim.stator_wedge_material = 0;

%rotor dimensions
dim.Rout = dim.Sin-dim.delta; %rotor outer diameter
dim.hyr = 3e-3; %yoke thickness
dim.h_sleeve = 3e-3; %retaining sleeve thickness
dim.hpm = 5e-3; %PM thickness
dim.alpha_pm = 0.5; %PM pitch, as a ratio to pole pitch
dim.is_halbach = true;

%dim.is_halbach = false; dim.alpha_pm = 0.95;

dim.magnet_material = PMlibrary.create('G52SH');
dim.rotor_core_material = NO12();
dim.rotor_sleeve_material = 20;


%creating geometries
stator = Stator(dim);
rotor = SPM1(dim);


%plotting geometries
%%{
figure(1); clf; hold on; box on; axis equal;
stator.plot_geometry();
rotor.plot_geometry();


%meshing geometries
stator.mesh_geometry();
rotor.mesh_geometry();

%figure(2); clf; hold on; box on; axis equal; stator.visualize('linestyle', '-'); return
%figure(2); clf; hold on; box on; axis equal; stator.triplot; return

%creating model
motor = RFmodel(dim, stator, rotor);

figure(2); clf; hold on; box on; axis equal;
motor.visualize('plot_axial', true, 'plot_ag', false, 'linestyle', 'none', 'plot_nodes', false);


hcond = dim.hslot_s - dim.htt_s;
Acopper_slot = winding.N_layers*winding.N_series*winding.wires_in_hand * layout.conductor_area;
A_slot_free = (hcond - 2*h_wall)*(dim.wslot_s-2*h_wall);
free_fill_factor =  Acopper_slot / A_slot_free
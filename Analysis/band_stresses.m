%CF sleeve stress calculations
%
% Roughest of the rough analytical estimations

[m, mass_per_domain, mass_per_material] = motor.mass();

mmag = mass_per_material.Material_G52SH;
mcf = mass_per_material.Material_Carbonfiber;

%older scramblings
%{
r2 = dim.Sin - dim.delta;
r1 = r2 - dim.h_sleeve;

rho = (mmag + mcf) / (pi*(r2^2 - r1^2)*dim.leff); %equivalent density

sigma = (2*pi*rpm/60)^2 * rho * (r1^2 + r1*r2 + r2^2)/3 / 1e6

%formula 2
sigma2 = (mmag+mcf)*(2*pi*rpm/60)^2 *r2^2 / (dim.leff*(r2-r1)) / 1e6
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stress calculations based on "Fixation of Buried and Surface-Mounted Magnets
% in High-Speed Permanent-Magnet Synchronous Machines"

stress_limit_MPa = 1100; %stress limit for the CF sleeve, from paper

w = 2*pi*dim.rpm/60; %angular velocity

%materials
m_mag = dim.magnet_material;
m_sleeve = Material.create( dim.rotor_sleeve_material );

%pre-stress calculations
rm = dim.Rout - dim.h_sleeve - dim.hpm/2; %average magnet ring radius
rb = dim.Rout - dim.h_sleeve/2; %average sleeve radius
rb_o = dim.Rout; %sleeve outer radius
rb_i = dim.Rout - dim.h_sleeve; %sleeve inner radius


p_m = rm * m_mag.material_properties.rho * w^2 * dim.hpm; %Equation 6
p_b = rb * m_sleeve.material_properties.rho * w^2 * dim.h_sleeve; %Equation 7

pre_pressure_margin = 2;
required_prepressure = pre_pressure_margin * (p_m + p_b); %from Equation 1

prestress_MPa = required_prepressure * rb / dim.h_sleeve / 1e6 %Equation 4a
prestress_thick_MPa = required_prepressure * ...
    (rb_i^2 / (rb_o^2 - rb_i^2) * (1 + rb_o^2/rb_i^2)) / 1e6 %Equation 4b

%stress from band's own centrifugal stress
self_stress_MPa = m_sleeve.material_properties.rho * w^2 * rb^2 / 1e6
self_stress_thick_MPa = m_sleeve.material_properties.rho * w^2 * ...
    0.4125 * (0.424*rb_i^2 + 2*rb_o^2) / 1e6

%thermal stress calculations
thermal_expansion_coefficient = 12e-6;
expansion_ratio = thermal_expansion_coefficient * (dim.temperature_rotor - 20);
expansion_stress_MPa = expansion_ratio * m_sleeve.material_properties.Youngs_modulus/1e6

%total stress
total_stress_MPa = max(prestress_MPa, prestress_thick_MPa) + ...
    max(self_stress_MPa, self_stress_thick_MPa) + expansion_stress_MPa

safety_margin = stress_limit_MPa / total_stress_MPa


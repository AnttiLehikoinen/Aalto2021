addpath(genpath('E:/Work/Matlab/EMDtool/Versions/3.0.2/EMDtool'));

addpath(genpath('Analysis'));
addpath(genpath('Dimensions'));
addpath(genpath('Lib'));

% README
% 0. Download and setup EMDtool 3.0.2.dev
% 1. create model (see e.g. Dimensions/dim_1a.m
% 2. Run electromagnetic analysis
%   - e.g. calculate_torque_curve_linear for quick testing
%   - stepping_sim.m to run static stepping analysis, to evaluate
%   performance and losses
% 3. Run any post-processing / analysis scripts under Analysis
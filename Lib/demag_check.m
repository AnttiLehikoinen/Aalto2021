%checking minimum flux density

solution = stepping_solution;
%solution = static_solution;

PMs = motor.namedElements.get('PMs');

els = [PMs.elements];
vec = cell(1, numel(PMs));
%determining vectors
for k = 1:numel(PMs)
    els_here = PMs(k).elements;
    
    
    %parsing remanence vector direction
    mat = PMs(k).material;
    Br = mat.material_properties.Br * (1 + mat.material_properties.alpha_Br * (dim.temperature_rotor - 20) );
    
    HcJ = mat.material_properties.HcJ * (1 + mat.material_properties.alpha_HcJ * (dim.temperature_rotor - 20) );
    
    Brdir = PMs(k).remanence_direction;
    
    if ischar(Brdir)
        %parsing direction
        if Brdir(1) == '-'
            sig = -1;
            Brdir = Brdir(2:end);
        else
            sig = 1;
        end

        %elements centers of mass
        p0 = motor.p(:, motor.t(1, els_here));
        for kf = 2:size(motor.t,1)
            p0 = p0 + motor.p(:, motor.t(kf, els_here));
        end
        p0 = p0 / size(motor.t,1);

        %normalizing
        pnorm = sqrt( sum(p0.^2,1) );
        er = sig*bsxfun(@rdivide, p0, pnorm);

        if strcmpi(Brdir, 'circumferential')
            er = [0 -1;1 0]*er;
        end
    else
        er = repmat([cos(Brdir); sin(Brdir)], 1, numel(els_here) / numel(Brdir));
    end
    vec{k} = er;
end
vecs = [vec{:}];

%return

A = solution.raw_solution;
Bpm = zeros(numel(els), size(A,2));
for k = 1:size(A,2)
    [~, Bvec] = calculate_B(A(:,k), motor);

    Bproj = dotProduct(Bvec(:,els), vecs);
    Bpm(:,k) = Bproj';
end
Bmin = min(Bpm, [], 2);
Hmin = (Bmin-Br) / (1.05*pi*4e-7);

%Bmin = (Br - Bmin);

disp(['Minimum flux density: ' num2str(min(Bmin)) ' T']);
disp(['Maximum demag field: ' num2str(min(Hmin/1e3)) ' kA/m']);
disp(['Maximum demag field: ' num2str(100*min(Hmin)/-HcJ) ' %']);

figure(10); clf; hold on; box on; axis equal tight;
%Bmin plot
%{
msh_fill(motor, els, Bmin, 'linestyle', 'none'); 
colormap( flipud(colormap('jet')));
colorbar; 
%cax = caxis; cax(1) = 0; caxis(cax);
%}

%Hdemag plot
%%{
msh_fill(motor, els, Hmin/1e3, 'linestyle', 'none'); colormap(flipud(colormap('jet'))); colorbar;
cax = caxis; 
cax(1) = -HcJ/1e3; 
cax(2) = -HcJ/1e3*0.8; 
caxis(cax);
title('Demagnetizing field (kA/m)');
%}

%drawFluxLines(mshc, A(:,1), 100, 0, 'k');


%msh_fill(mshc, els, Hmin/79.5775e3, 'linestyle', 'none'); colorbar;  %in kOe
%caxis([0 Br]);
set(gca, 'XTick', [], 'YTick', []);

%plotting flux vectors
xc = (motor.p(:, motor.t(1,:)) + motor.p(:, motor.t(2,:)) + motor.p(:, motor.t(3,:)));

figure(11); clf; hold on; axis equal square;
quiver(xc(1,els), xc(2,els), Bvec(1,els), Bvec(2,els));
%quiver(xc(1,els), xc(2,els), vecs(1,:), vecs(2,:));

els_here = els(Bmin<0.1);
%quiver(xc(1,els_here), xc(2,els_here), Bvec(1,els_here), Bvec(2,els_here), 'r');
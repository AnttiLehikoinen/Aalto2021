%Tabulating winding configurations

m = 6;
nlayers = 1;

WF_min = 0.85;
Nbelt_max = 12*2;

prange = 30:80;
Qrange = 60:180;

prange = 20:60;
Qrange = 40:80;

%prange = [76/2 78/2];
if nlayers == 1
    step = 2;
else
    step = 1;
end

%prange = 4:6;
%Qrange = 10:18;

[ps, qs] = meshgrid(prange, Qrange);
WF = nan*ones(size(ps));
WS = cell(size(ps));
NB = nan*ones(size(ps));
SYMM = NB;
for k = 1:numel(ps)
    phere = ps(k);
    Qhere = qs(k);
    
    try
        W = WindingLayout.concentrated(Qhere, phere, m, nlayers);
    catch
        continue;
    end
    if any(isnan(W))
        continue;
    end
    wf = calculate_winding_factor(phere, W);
    
    WF(k) = max(abs(wf)) * phere;
    WS{k} = W;
    
    [~, NB(k), SYMM(k)] = calculate_winding_characteristics(W);
end
%return

%skipping too low values
inds = union(find( WF <= WF_min ), find(NB > Nbelt_max) );
WF(inds) = nan;
NB(inds) = nan;
SYMM(inds) = nan;

%NB( WF<0.85 ) = nan;
%WF( WF<0.85 ) = nan;


figure(1); clf; hold on; box on; axis tight;
%h = pcolor(2*ps(:,:), qs(:,:), WF(:,:));
%set(h, 'EdgeColor', 'none');
plot(2*ps(isfinite(WF)), qs(isfinite(WF)), 'marker', 'o', 'linestyle', 'none');
colormap( flipud(colormap('jet')) );
colorbar;

xlabel('Poles');
ylabel('Slots');

for k = 1:numel(WF)
    if isnan(WF(k))
        continue;
    end
    %disp('got here');
    %text( 2*ps(k) + 1, qs(k)+2, num2str(round(WF(k),3)), 'Color', 'red' );
    text( 2*ps(k) , qs(k), num2str(round(WF(k),3)), 'Color', 'red' );
end

figure(2); clf; hold on; box on; axis tight;
h = pcolor(2*ps(:,:), qs(:,:), NB(:,:));
set(h, 'EdgeColor', 'none');
colormap('jet');
colorbar;

%{
figure(3); clf; hold on; box on; axis tight;
h = pcolor(2*ps(:,:), qs(:,:), reshape(lcm(ps(:), qs(:)), size(ps)));
set(h, 'EdgeColor', 'none');
colormap('jet');
colorbar;
return
%}


figure(3); clf; hold on; box on; axis tight;
%h = pcolor(2*ps(:,:), qs(:,:), WF(:,:));
%set(h, 'EdgeColor', 'none');
plot(2*ps(isfinite(SYMM)), qs(isfinite(SYMM)), 'marker', 'o', 'linestyle', 'none');
colormap( flipud(colormap('jet')) );
colorbar;

xlabel('Poles');
ylabel('Slots');

for k = 1:numel(SYMM)
    if isnan(SYMM(k))
        continue;
    end
    disp('got here');
    %text( 2*ps(k) + 1, qs(k)+2, num2str(round(WF(k),3)), 'Color', 'red' );
    text( 2*ps(k) , qs(k), num2str(SYMM(k)), 'Color', 'red', 'Fontsize', 14 );
end


return


col_inds = find( sum( ~isnan(WF), 1 ) );
row_inds = find( sum( ~isnan(WF), 2 ) );

q_indices = cell(1, size(WF, 1));
for k = 1:size(WF,2)
    q_indices{k} = find( ~isnan(WF(:,k)) );
end

return
col_inds = find( sum( ~isnan(WF), 1 ) );
row_inds = find( sum( ~isnan(WF), 2 ) );

figure(2); clf; hold on; box on; axis tight;
h = pcolor(2*ps(row_inds,col_inds), qs(row_inds,col_inds), WF(row_inds,col_inds));
set(h, 'EdgeColor', 'none');

colormap( flipud(colormap('jet')) );
colorbar;
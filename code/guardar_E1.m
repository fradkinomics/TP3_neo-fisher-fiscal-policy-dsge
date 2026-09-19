%% ============================================================
%  guardar_E1.m — Entregables E1 → output/
%  Lee de MEMORIA (oo_, M_, bayestopt_) tras correr uribe_A_E1.mod.
%  NO re-estima. Genera: tabla moda+s.d. (csv) y figuras mode_check (pdf).
% ============================================================
outdir = fullfile('..','output');
if ~exist(outdir,'dir'), mkdir(outdir); end

% --- Nombres, moda y s.d., todo en el MISMO orden de estimación ---
Nombre = string(bayestopt_.name(:));
Moda   = oo_.posterior_mode.parameters;   % struct → lo aplanamos abajo
% oo_.posterior_mode viene como struct por bloques; reconstruimos vector:
moda_vec = []; sd_vec = []; nom_vec = strings(0,1);
blk = {'measurement_errors_std','shocks_std','parameters'};  % orden Dynare
for b = 1:numel(blk)
    if isfield(oo_.posterior_mode, blk{b})
        s  = oo_.posterior_mode.(blk{b});
        sd = oo_.posterior_std_at_mode.(blk{b});
        f  = fieldnames(s);
        for k = 1:numel(f)
            nom_vec(end+1,1) = string(f{k});
            moda_vec(end+1,1)= s.(f{k});
            sd_vec(end+1,1)  = sd.(f{k});
        end
    end
end

E1 = table(nom_vec, moda_vec, sd_vec, ...
      'VariableNames', {'Parametro','Moda','SD'});
writetable(E1, fullfile(outdir,'E1_moda_sd.csv'));
disp('--- E1: tabla guardada en output/E1_moda_sd.csv ---');
disp(E1);

% --- Figuras mode_check abiertas en memoria → PDF vectorial ---
figs = flipud(findobj(0,'Type','figure'));
c = 0;
for k = 1:numel(figs)
    nm = get(figs(k),'Name');
    if contains(lower(nm),'mode') || ~isempty(findobj(figs(k),'Type','axes'))
        c = c + 1;
        exportgraphics(figs(k), ...
            fullfile(outdir,sprintf('E1_mode_check_%02d.pdf',c)), ...
            'ContentType','vector');
    end
end
fprintf('--- E1: %d figuras mode_check guardadas en output/ ---\n', c);
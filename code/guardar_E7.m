%% ============================================================
%  guardar_E7.m — Entregables E7 (Uribe-B) → output/
%  Lee de MEMORIA (oo_, bayestopt_) tras correr uribe_B_E7.mod.
%  NO re-estima. Genera: tabla moda+s.d. (csv) y figuras mode_check (pdf).
% ============================================================
outdir = fullfile('..','output');
if ~exist(outdir,'dir'), mkdir(outdir); end

% --- Nombres, moda y s.d., en el MISMO orden de estimación ---
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

E7 = table(nom_vec, moda_vec, sd_vec, ...
      'VariableNames', {'Parametro','Moda','SD'});
writetable(E7, fullfile(outdir,'E7_moda_sd.csv'));
disp('--- E7: tabla guardada en output/E7_moda_sd.csv ---');
disp(E7);

% --- Figuras mode_check → PDF (SOLO mode_check, excluye smoother) ---
delete(fullfile(outdir,'E7_mode_check_*.pdf'));   % limpia corridas viejas (borra los 04-06 espurios)
figs = flipud(findobj(0,'Type','figure'));
c = 0;
for k = 1:numel(figs)
    nm = lower(get(figs(k),'Name'));
    es_mc = (contains(nm,'check') || contains(nm,'mode')) ...
            && ~contains(nm,'smooth') && ~contains(nm,'histor');
    if es_mc
        c = c + 1;
        exportgraphics(figs(k), ...
            fullfile(outdir,sprintf('E7_mode_check_%02d.pdf',c)), ...
            'ContentType','vector');
    end
end
fprintf('--- E7: %d figuras mode_check guardadas en output/ ---\n', c);
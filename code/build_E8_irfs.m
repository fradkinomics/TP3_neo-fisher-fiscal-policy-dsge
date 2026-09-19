% ============================================================
%  build_E8_irfs.m — IRFs de Uribe-B a los 2 shocks monetarios
%  activos (z^{m2} persistente, z^m transitorio). Param. UNICA:
%  moda E7 (horneada en uribe_B_irf.mod). Reproducible de cero.
%  Salida: data/E8_irfs_B.mat. Requiere setting.m corrido.
% ============================================================
global M_ oo_ options_
assert(exist('code_dir','var')==1,'Corré setting.m primero.');
cd(code_dir)

% 1) Generar modelo + IRFs (deja oo_.irfs en memoria)
dynare uribe_B_irf.mod noclearall

% 2) Extraer IRFs de los 2 shocks monetarios activos
shocks_m = {'eps_zm2','eps_zm'};
obs      = {'di_obs','dpi_obs','dy_obs'};
IRF = struct();
for s = 1:numel(shocks_m)
    for o = 1:numel(obs)
        fld = [obs{o} '_' shocks_m{s}];
        IRF.(fld) = oo_.irfs.(fld)(:);
    end
end

% 3) Guardar insumo (NO entregable)
save(fullfile(code_dir,'..','data','E8_irfs_B.mat'),'IRF');
fprintf('\nGuardado: data/E8_irfs_B.mat\n');

% 4) Chequeo numerico (regla 22): niveles anualizados por acumulacion
Iz  = 4*cumsum(IRF.di_obs_eps_zm2);
PIz = 4*cumsum(IRF.dpi_obs_eps_zm2);
Ym  =   cumsum(IRF.dy_obs_eps_zm2);
fprintf('\n--- z^{m2} (neo-Fisher, cuasi-permanente) ---\n');
fprintf('  I : impacto=%.4f  meseta(t=21)=%.4f  (impacto/LP=%.2f)\n', Iz(1), Iz(end), Iz(1)/Iz(end));
fprintf('  PI: impacto=%.4f  pico=%.4f  LP(t=21)=%.4f\n', PIz(1), max(PIz), PIz(end));
fprintf('  Y : impacto=%.4f  pico=%.4f\n', Ym(1), max(Ym));
Izm = 4*cumsum(IRF.di_obs_eps_zm);
fprintf('--- z^m (transitorio): I impacto=%.4f  LP(t=21)=%.4f ---\n', Izm(1), Izm(end));
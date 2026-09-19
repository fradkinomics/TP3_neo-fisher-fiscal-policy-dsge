% ============================================================
%  build_E9_vardec.m — E9: descomposicion de varianza Uribe-B de
%  dy_obs (Δy), di_obs (Δi), dpi_obs (Δπ), con desvios ESTIMADOS
%  (moda E7, horneados como sig_* en uribe_B_irf.mod).
%  g^m apagado (sig_gm=0); z^{m2} activo (sig_zm2 estimado).
%  Salidas: data/E9_vardec_B.mat + output/E9_vardec_B.csv
% ============================================================
global M_ oo_ options_
assert(exist('code_dir','var')==1,'Corré setting.m primero.'); cd(code_dir)

dynare uribe_B_irf.mod noclearall
vars3 = {'dy_obs','di_obs','dpi_obs'};
options_.noprint = 1;

% --- Sigma_e diagonal con los sigma ESTIMADOS (tanto por uno) ---
ne = M_.exo_nbr; exo = M_.exo_names;
Sig = zeros(ne,ne);
for e = 1:ne
    signame  = strrep(exo{e},'eps_','sig_');           % eps_zm2 -> sig_zm2
    Sig(e,e) = M_.params(strcmp(M_.param_names,signame))^2;
end
M_.Sigma_e = Sig;

% --- re-resolver -> descomposicion de varianza ---
[~, oo_, options_, M_] = stoch_simul(M_, options_, oo_, vars3);
VD.dec = oo_.variance_decomposition;   % filas=vars3, cols=exo
VD.vars = vars3; VD.shocks = exo;
save(fullfile(code_dir,'..','data','E9_vardec_B.mat'),'VD');

% --- CSV (orden tipo Tabla 6; z^{m2} primero) ---
ord = {'eps_zm2','eps_zm','eps_g','eps_z','eps_xi','eps_theta','eps_gm'};
[~,ic] = ismember(ord, exo);
lbl = strrep(ord,'eps_','');
T = cell2table([vars3(:) num2cell(VD.dec(:,ic))], 'VariableNames',[{'variable'} lbl]);
writetable(T, fullfile(code_dir,'..','output','E9_vardec_B.csv'));

% --- chequeo numerico: las 3 filas ---
fprintf('\nDescomp. de varianza [%%]:\n'); fprintf('%-8s',''); fprintf(' %8s',lbl{:}); fprintf('\n');
for r=1:numel(vars3)
    fprintf('%-8s',strrep(vars3{r},'_obs','')); fprintf(' %8.2f',VD.dec(r,ic)); fprintf('\n');
end
fprintf('\nGuardado: data/E9_vardec_B.mat + output/E9_vardec_B.csv\n');
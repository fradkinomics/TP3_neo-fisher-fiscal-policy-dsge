% ============================================================
%  build_E4_irfs.m — IRFs de Uribe-A a los 2 shocks monetarios
%  (eps_gm permanente, eps_zm transitorio) para las 3 param.:
%  moda E1, moda mc=6, media MH. Reproducible de cero.
%  Salida: data/E4_irfs_A.mat  (struct IRF)
%  Requiere: setting.m corrido + data/params_A.mat
% ============================================================
global M_ oo_ options_
assert(exist('code_dir','var')==1,'Corré setting.m primero.');
cd(code_dir)

% 1) Construir el modelo (deja M_, oo_, options_ en memoria)
dynare uribe_A_irf.mod noclearall

% 2) Cargar los 3 vectores
S = load(fullfile(code_dir,'..','data','params_A.mat')); P = S.P;

% 3) Config
tags     = {'modaE1','moda_mc6','mediaMH'};
list12   = {'phi','alfa_pai','alfa_y','gamma_m','gamma_i','delta', ...
            'rho_xi','rho_theta','rho_z','rho_g','rho_gm','rho_zm'};
shocks_m = {'eps_gm','eps_zm'};
obs      = {'di_obs','dpi_obs','dy_obs'};
options_.noprint = 1;          % no floodear la Command Window

% 4) Recorrer parametrizaciones
IRF = struct();
for it = 1:numel(tags)
    vec = P.(tags{it});
    for j = 1:numel(list12)
        idx = find(strcmp(P.names, list12{j}));
        set_param_value(list12{j}, vec(idx));
    end
    [~, oo_, options_, M_] = stoch_simul(M_, options_, oo_, obs);   % re-resuelve
    for s = 1:numel(shocks_m)
        for o = 1:numel(obs)
            fld = [obs{o} '_' shocks_m{s}];
            IRF.(tags{it}).(fld) = oo_.irfs.(fld)(:);
        end
    end
end

% 5) Guardar insumo
save(fullfile(code_dir,'..','data','E4_irfs_A.mat'),'IRF');
fprintf('\nGuardado: data/E4_irfs_A.mat (IRF.modaE1/moda_mc6/mediaMH)\n\n');

% 6) Chequeo: nivel de I ante g^m (impacto y largo plazo, sin normalizar)
fprintf('Nivel I ante g^m (x4 cumsum de di_obs):\n');
for it = 1:numel(tags)
    Iperm = 4*cumsum(IRF.(tags{it}).di_obs_eps_gm);
    fprintf('  %-9s | I(t=1)=%7.3f  I(t=21)=%7.3f\n', tags{it}, Iperm(1), Iperm(end));
end
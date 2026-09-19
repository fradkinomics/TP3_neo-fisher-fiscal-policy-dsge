% ============================================================
%  build_E6_smooth.m — E6: dpi_obs suavizado (Kalman smoother)
%  para las 3 parametrizaciones de Uribe-A. Reproducible de cero.
%  Salida: data/E6_smooth_A.mat (struct SM)
%  Requiere: setting.m + params_A.mat + uribe_A_smoother.mod
% ============================================================
global M_ oo_ options_ bayestopt_ estim_params_
assert(exist('code_dir','var')==1,'Corré setting.m primero.');
cd(code_dir)

dynare uribe_A_smoother.mod noclearall
S = load(fullfile(code_dir,'..','data','params_A.mat')); P = S.P;

tags   = {'modaE1','moda_mc6','mediaMH'};
list15 = {'phi','alfa_pai','alfa_y','gamma_m','gamma_i','delta', ...
          'rho_xi','rho_theta','rho_z','rho_g','rho_gm','rho_zm', ...
          'R11','R22','R33'};
sig6   = {'eps_xi','eps_theta','eps_z','eps_g','eps_gm','eps_zm'};  % estimation scale (x100)
exo    = M_.exo_names;

SM = struct();
for it = 1:numel(tags)
    vec = P.(tags{it});
    % (a) 15 params (estructurales + rho + R_ii)
    for j = 1:numel(list15)
        set_param_value(list15{j}, vec(strcmp(P.names,list15{j})));
    end
    % (b) varianzas de shock (escala estimacion = valor x100, al cuadrado)
    for e = 1:numel(sig6)
        v = vec(strcmp(P.names, ['stderr ' sig6{e}]));
        M_.Sigma_e(strcmp(exo,sig6{e}), strcmp(exo,sig6{e})) = v^2;
    end
    % (c) correr smoother a estos parametros
    [oo_, ~, ~, ~, ~] = evaluate_smoother('calibration', char(M_.endo_names), M_, oo_, options_, bayestopt_, estim_params_);
    SM.(tags{it}).dpi = oo_.SmoothedVariables.dpi_obs(:);
end
SM.tags = tags;
save(fullfile(code_dir,'..','data','E6_smooth_A.mat'),'SM');

fprintf('\nGuardado: data/E6_smooth_A.mat\n');
fprintf('Chequeo dpi_obs suavizado (primeros 3):\n');
for it=1:numel(tags)
    fprintf('  %-9s: %7.4f %7.4f %7.4f\n', tags{it}, SM.(tags{it}).dpi(1:3));
end
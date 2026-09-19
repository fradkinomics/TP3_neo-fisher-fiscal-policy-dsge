%% ============================================================
%  make_estim_data.m — Opción B: arma el .mat de datos para estimar
%  Lee data/Datos.xlsx (hoja 'data') y guarda data/uribe_data.mat
%  con las 3 series observables. NO es entregable → va a data/.
% ============================================================
clear;

% --- Rutas portables (mismo criterio que setting.m) ---
this_file = mfilename('fullpath');
code_dir  = fileparts(this_file);
proj_root = fileparts(code_dir);

xlsx_in = fullfile(proj_root,'data','Datos.xlsx');
mat_out = fullfile(proj_root,'data','uribe_data.mat');

% --- Leer Excel (hoja 'data') ---
T = readtable(xlsx_in, 'Sheet','data');

% --- Extraer las 3 series que se estiman (vector columna c/u) ---
dy_obs = T.dy_obs;
r_obs  = T.r_obs;
di_obs = T.di_obs;

% --- Guardar .mat nativo de Dynare ---
save(mat_out, 'dy_obs', 'r_obs', 'di_obs');

% --- Chequeo en pantalla (confirmar antes de estimar) ---
fprintf('\n--- uribe_data.mat creado ---\n');
fprintf('Ruta: %s\n', mat_out);
fprintf('nro obs: %d\n', numel(dy_obs));
fprintf('medias (deben ser ~0): dy=%.2e  r=%.2e  di=%.2e\n', ...
        mean(dy_obs), mean(r_obs), mean(di_obs));
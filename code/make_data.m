%% make_data.m — construye data/Datos.xlsx (observables TP3; Uribe en PUNTOS PORCENTUALES)
clear;
proj_root = fileparts(fileparts(mfilename('fullpath')));   % raíz portable

% 1) Pipeline de Uribe (mismas transformaciones y muestra 1954Q4–2018Q2)
tend = 2018.25;
[Dy,Dpai,Dff, y, pai, ff, date] = read_data(tend);
r = ff - pai;                          % diferencial tasa−inflación

% 2) Observables en PUNTOS PORCENTUALES, trimestrales, MEDIA CERO
%    (= Uribe ×100:  Dy ya está en %/trim;  r y Dff están en %/año → /4)
dy_obs = (Dy  - mean(Dy));             % Δy  (pp/trim, demeaned)
r_obs  = (r   - mean(r) )/4;           % r   (pp/trim, demeaned)
di_obs = (Dff - mean(Dff))/4;          % Δi  (pp/trim, demeaned)

% 3) Auxiliar Δπ: NO se estima → NO se centra en media cero (consigna)
dpi_obs = Dpai/4;                      % Δπ  (pp/trim, SIN demean)

% 4) Chequeo
fprintf('Obs=%d | medias 3 obs: %.2e %.2e %.2e (~0) | media Δπ=%.4f (≠0)\n', ...
        numel(dy_obs), mean(dy_obs), mean(r_obs), mean(di_obs), mean(dpi_obs));

% 5) Exportar a data/Datos.xlsx, hoja 'data'
Tbl = table(date, dy_obs, r_obs, di_obs, dpi_obs);
out = fullfile(proj_root,'data','Datos.xlsx');
writetable(Tbl, out, 'Sheet','data');
fprintf('Guardado: %s (%d filas)\n', out, height(Tbl));
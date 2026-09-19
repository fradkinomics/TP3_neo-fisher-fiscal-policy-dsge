% ============================================================
%  build_infl_obs.m — reconstruye la inflacion observada (deflactor
%  del PIB, anualizada, %) con la MISMA formula de read_data.m, la
%  recorta a la muestra del modelo (1954Q4–2018Q2, 255 obs) y la
%  guarda para E6. Fuente: data_raw/gdplev.xlsx. Correr setting.m antes.
% ============================================================
clearvars -except code_dir; clc;
assert(exist('code_dir','var')==1,'Corré setting.m primero.');

% --- 1) Leer gdplev.xlsx (misma logica que read_data.m) ---
xlsfile = fullfile(code_dir,'..','data_raw','gdplev.xlsx');   % <-- AJUSTAR si esta en otra carpeta
[a,~] = xlsread(xlsfile);
gdp  = a(:,5);        % PIB nominal (BEA, corriente, SA anualizado)
rgdp = a(:,6);        % PIB real (encadenado 2012, SA anualizado)

gdp_deflator = gdp ./ rgdp;
inflation = ( (gdp_deflator(2:end)./gdp_deflator(1:end-1)).^4 - 1 )*100;
inflation_date = (1947.25:0.25:2018.25)';    % igual que read_data.m

% --- 2) Recorte a la muestra del modelo: 1954Q4 (1954.75) -> 2018Q2 (2018.25) ---
d_ini = 1954.75;  d_fin = 2018.25;
sel = inflation_date >= d_ini - 1e-6 & inflation_date <= d_fin + 1e-6;
infl_obs  = inflation(sel);
infl_date = inflation_date(sel);

% --- 3) Chequeos ---
fprintf('N obs recortadas: %d  (esperado 255)\n', numel(infl_obs));
fprintf('Fecha inicial: %.2f  | Fecha final: %.2f\n', infl_date(1), infl_date(end));
fprintf('Ancla pi_1 (inflacion observada en 1954Q4): %.4f %%\n', infl_obs(1));
fprintf('Primeros 5 valores: '); fprintf('%.4f  ', infl_obs(1:5)); fprintf('\n');

% --- 4) Guardar en data/ (insumo para 5.4.3) ---
save(fullfile(code_dir,'..','data','infl_obs_A.mat'),'infl_obs','infl_date');
fprintf('\nGuardado: data/infl_obs_A.mat (infl_obs 255x1, infl_date)\n');
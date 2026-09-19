%% ============================================================
%  setting.m  —  TP3 Macroeconometría (UdeSA 2026)
%  Correr UNA vez al abrir MATLAB para dejar el entorno listo.
%  Uso: abrir este archivo y apretar el botón verde RUN (F5).
% ============================================================
clear; close all; clc;

%% ---- 1) CONFIG DE USUARIO (editar SOLO esta línea) ----
% Ruta a la carpeta 'matlab' de TU instalación de Dynare.
% Ej: 'C:\Program Files\Dynare\7.0\matlab'   |   'C:\dynare\6.1\matlab'
DYNARE_PATH = 'C:\Program Files\Dynare\7.0\matlab';

%% ---- 2) Cargar Dynare ----
addpath(DYNARE_PATH);
disp(['Dynare cargado: version ' dynare_version]);

%% ---- 3) Ubicar la raíz del proyecto (automático y portable) ----
this_file = mfilename('fullpath');      % ruta de este setting.m
code_dir  = fileparts(this_file);       % .../TP3_macrometrics/code
proj_root = fileparts(code_dir);        % .../TP3_macrometrics
disp(['Raíz del proyecto: ' proj_root]);

%% ---- 4) Agregar carpetas del proyecto al path ----
addpath(fullfile(proj_root,'tools'));       % utilidades .m de la cátedra
addpath(fullfile(proj_root,'data'));        % archivos procesados (Datos.xlsx)
addpath(fullfile(proj_root,'data_raw'));    % Excel crudos (gdplev, LNU, fedfunds)
addpath(code_dir);                          % scripts y .mod

%% ---- 5) Pararse en /code para correr los .mod desde acá ----
cd(code_dir);

disp('Setup OK: entorno listo para el TP3.');

%% ---- 6) (Más adelante) correr los modelos ----
% Cuando tengamos el .mod, se descomenta y listo:
% dynare uribe_A.mod
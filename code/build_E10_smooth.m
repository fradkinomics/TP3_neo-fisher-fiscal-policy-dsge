% ============================================================
%  build_E10_smooth.m — E10: dpi_obs suavizado (Kalman smoother)
%  Uribe-B, param UNICA (moda E7, horneada en uribe_B_smoother.mod).
%  Salida: data/E10_smooth_B.mat
% ============================================================
global M_ oo_ options_
assert(exist('code_dir','var')==1,'Corré setting.m primero.'); cd(code_dir)

dynare uribe_B_smoother.mod noclearall     % corre calib_smoother con moda E7

SM.dpi = oo_.SmoothedVariables.dpi_obs(:);
save(fullfile(code_dir,'..','data','E10_smooth_B.mat'),'SM');
fprintf('\nGuardado: data/E10_smooth_B.mat\n');
fprintf('dpi_obs suavizado (primeros 3): %7.4f %7.4f %7.4f\n', SM.dpi(1:3));
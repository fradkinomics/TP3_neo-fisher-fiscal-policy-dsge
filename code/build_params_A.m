% ============================================================
%  build_params_A.m — consolida los 3 vectores de parametros de
%  Uribe-A (moda E1, moda mc=6, media posterior MH) en un unico
%  .mat reutilizable por E4, E5 y E6. Correr setting.m antes.
% ============================================================
clearvars -except code_dir; clc;
assert(exist('code_dir','var')==1,'Corré setting.m primero (define code_dir).');

% --- 1) Cargar los tres origenes ------------------------------------
E1  = load(fullfile(code_dir,'uribe_A_E1','Output','uribe_A_E1_mode.mat'));    % moda mc=5
MC6 = load(fullfile(code_dir,'uribe_A_E2','Output','uribe_A_E2_mode.mat'));    % moda mc=6
R2  = load(fullfile(code_dir,'uribe_A_E2','Output','uribe_A_E2_results.mat')); % oo_.posterior_mean

nm = R2.bayestopt_.name;        % 21 nombres, en el orden de xparam1
np = numel(nm);
pm = R2.oo_.posterior_mean;     % .shocks_std (eps_*) y .parameters (resto)

% --- 2) Media MH alineada al mismo orden que nm ---------------------
mediaMH = nan(np,1);
for k = 1:np
    name = nm{k};
    if startsWith(name,'stderr ')
        shk = strtrim(erase(name,'stderr '));   % p.ej. 'eps_xi'
        mediaMH(k) = pm.shocks_std.(shk);
    else
        mediaMH(k) = pm.parameters.(name);
    end
end

% --- 3) Empaquetar --------------------------------------------------
P.names    = nm(:);
P.modaE1   = E1.xparam1(:);
P.moda_mc6 = MC6.xparam1(:);
P.mediaMH  = mediaMH(:);

% --- 4) Chequeo visual ----------------------------------------------
fprintf('\n idx | nombre           |  moda E1  | moda mc=6 |  media MH\n');
fprintf('-----+------------------+-----------+-----------+----------\n');
for k = 1:np
    fprintf('%3d | %-16s | %9.5g | %9.5g | %9.5g\n', ...
            k, P.names{k}, P.modaE1(k), P.moda_mc6(k), P.mediaMH(k));
end

% --- 5) Guardar en data/ (insumo, NO entregable) --------------------
save(fullfile(code_dir,'..','data','params_A.mat'),'P');
fprintf('\nGuardado: data/params_A.mat  (struct P: names/modaE1/moda_mc6/mediaMH)\n');
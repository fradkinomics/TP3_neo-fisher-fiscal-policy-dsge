% ============================================================
%  build_E5_vardec.m — E5: descomposicion de varianza de
%  dy_obs (Δy), di_obs (Δi), dpi_obs (Δπ) para las 3
%  parametrizaciones de Uribe-A, con desvios de shock ESTIMADOS.
%  Salidas: data/E5_vardec_A.mat + output/E5_vardec_A.csv
%  Requiere: setting.m + data/params_A.mat + uribe_A_irf.mod
% ============================================================
global M_ oo_ options_
assert(exist('code_dir','var')==1,'Corré setting.m primero.');
cd(code_dir)

dynare uribe_A_irf.mod noclearall
S = load(fullfile(code_dir,'..','data','params_A.mat')); P = S.P;

tags   = {'modaE1','moda_mc6','mediaMH'};
list12 = {'phi','alfa_pai','alfa_y','gamma_m','gamma_i','delta', ...
          'rho_xi','rho_theta','rho_z','rho_g','rho_gm','rho_zm'};
vars3  = {'dy_obs','di_obs','dpi_obs'};
options_.noprint = 1;

ne  = M_.exo_nbr;          % 7 shocks
exo = M_.exo_names;        % orden de columnas de la vardecomp

VD = struct();
for it = 1:numel(tags)
    vec = P.(tags{it});
    % (a) 12 params libres de escala
    for j = 1:numel(list12)
        set_param_value(list12{j}, vec(strcmp(P.names,list12{j})));
    end
    % (b) varianzas de shock ESTIMADAS (tanto por uno = valor/100)
    Sig = zeros(ne,ne);
    for e = 1:ne
        nm = exo{e};
        if strcmp(nm,'eps_zm2')
            v = 0;                                         % Uribe-A
        else
            v = vec(strcmp(P.names, ['stderr ' nm]))/100;  % sig en 1x1
        end
        Sig(e,e) = v^2;
    end
    M_.Sigma_e = Sig;
    % (c) re-resolver -> vardecomp
    [~, oo_, options_, M_] = stoch_simul(M_, options_, oo_, vars3);
    VD.(tags{it}) = oo_.variance_decomposition;   % filas=vars3, cols=exo
end
VD.vars = vars3; VD.shocks = exo;
save(fullfile(code_dir,'..','data','E5_vardec_A.mat'),'VD');

% --- CSV ordenado como Tabla 6 de Uribe ---
ord = {'eps_gm','eps_zm2','eps_zm','eps_g','eps_z','eps_xi','eps_theta'};
[~,ic] = ismember(ord, exo);
rows = {}; C = [];
for it = 1:numel(tags)
    Mv = VD.(tags{it});
    for r = 1:numel(vars3)
        rows(end+1,1) = tags(it);
        rows(end,2)   = vars3(r);
        C(end+1,:)    = Mv(r, ic);
    end
end
lbl = strrep(ord,'eps_','');
T = cell2table([rows num2cell(C)], 'VariableNames', [{'param','variable'} lbl]);
writetable(T, fullfile(code_dir,'..','output','E5_vardec_A.csv'));

% --- chequeo: Δπ (dpi_obs) por parametrizacion ---
fprintf('\nDescomp. de varianza de d(pi) [%%]:\n');
fprintf('%-9s',''); fprintf(' %8s', lbl{:}); fprintf('\n');
for it = 1:numel(tags)
    Mv = VD.(tags{it}); r = find(strcmp(vars3,'dpi_obs'));
    fprintf('%-9s', tags{it}); fprintf(' %8.2f', Mv(r,ic)); fprintf('\n');
end
fprintf('\nGuardado: data/E5_vardec_A.mat + output/E5_vardec_A.csv\n');
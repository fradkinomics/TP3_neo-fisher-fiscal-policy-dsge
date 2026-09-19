%% ============================================================
%  guardar_E2.m — Entregables E2 (MH) → output/
%  Lee de MEMORIA (oo_, M_) tras correr uribe_A_E2.mod. NO re-estima.
%  Genera: tabla media posterior + HPD 90% (csv) y copia los
%  gráficos Prior-vs-Posterior que Dynare guardó.
% ============================================================
outdir = fullfile('..','output');
if ~exist(outdir,'dir'), mkdir(outdir); end

% --- Media posterior y HPD, en el MISMO orden (shocks_std + parameters) ---
nom = strings(0,1); media = []; hpdinf = []; hpdsup = [];
blk = {'shocks_std','parameters'};
for b = 1:numel(blk)
    s  = oo_.posterior_mean.(blk{b});
    lo = oo_.posterior_hpdinf.(blk{b});
    hi = oo_.posterior_hpdsup.(blk{b});
    f  = fieldnames(s);
    for k = 1:numel(f)
        nom(end+1,1)    = string(f{k});
        media(end+1,1)  = s.(f{k});
        hpdinf(end+1,1) = lo.(f{k});
        hpdsup(end+1,1) = hi.(f{k});
    end
end

E2 = table(nom, media, hpdinf, hpdsup, ...
      'VariableNames', {'Parametro','MediaPost','HPD5','HPD95'});
writetable(E2, fullfile(outdir,'E2_posterior.csv'));
disp('--- E2: tabla guardada en output/E2_posterior.csv ---');
disp(E2);

% --- Copiar los PDF Prior-vs-Posterior que generó Dynare ---
srcdir = fullfile(M_.dname,'graphs');
L = dir(fullfile(srcdir,'*PriorsAndPosteriors*.pdf'));
for k = 1:numel(L)
    copyfile(fullfile(srcdir,L(k).name), ...
             fullfile(outdir,sprintf('E2_priors_post_%02d.pdf',k)));
end
fprintf('--- E2: %d figuras Prior-vs-Posterior copiadas a output/ ---\n', numel(L));
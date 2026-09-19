%% plot_E6.m — E6: nivel de inflacion suavizado vs observado
%  Lee data/E6_smooth_A.mat + data/infl_obs_A.mat
%  Chequea escala (x1 vs x4) y exporta output/E6_infl_nivel_A.pdf
proj_root = fileparts(fileparts(mfilename('fullpath')));
SM = load(fullfile(proj_root,'data','E6_smooth_A.mat')); SM = SM.SM;
IO = load(fullfile(proj_root,'data','infl_obs_A.mat'));
infl_obs = IO.infl_obs(:); fecha = IO.infl_date(:); pi1 = infl_obs(1);
outdir = fullfile(proj_root,'output'); if ~exist(outdir,'dir'), mkdir(outdir); end

tags = {'modaE1','moda_mc6','mediaMH'};

% --- CHEQUEO DE ESCALA: nivel final con x1 y x4 (usa media MH) ---
dpi = SM.mediaMH.dpi;
nivel_x1 = pi1 + cumsum([0; dpi(2:end)]);
nivel_x4 = pi1 + cumsum([0; 4*dpi(2:end)]);
fprintf('Inflacion observada: pi_1=%.3f  pi_T=%.3f  (media=%.3f)\n', pi1, infl_obs(end), mean(infl_obs));
fprintf('Nivel reconstruido (media MH) pi_T:  x1=%.3f   x4=%.3f\n', nivel_x1(end), nivel_x4(end));
rec_mh = pi1 + cumsum([0; 4*dpi(2:end)]);
fprintf('PICO  observado=%.2f (en %.2f) | reconstruido MH=%.2f (en %.2f)\n', ...
        max(infl_obs), fecha(infl_obs==max(infl_obs)), ...
        max(rec_mh), fecha(rec_mh==max(rec_mh)));
    
% --- FACTOR: se fija tras el chequeo (por defecto 1; cambiar a 4 si corresponde) ---
FAC = 4;   % trimestral -> anual (mismo x4 que plot_E0)

% --- reconstruccion del nivel para las 3 parametrizaciones ---
col = {[0.85 0.11 0.11],[0.12 0.60 0.30],[0.11 0.35 0.85]};
sty = {'-','--','-'}; LW=[2.0 1.8 2.4]; gcol=[0.90 0.90 0.92];
f1=figure('Color','w','Position',[80 80 1000 460]);
tiledlayout(1,1,'Padding','loose'); nexttile; hold on; box off;
hObs = plot(fecha, infl_obs, '-', 'Color',[0.5 0.5 0.5], 'LineWidth',1.4);
hL = gobjects(1,numel(tags));
for k=1:numel(tags)
    dpi = SM.(tags{k}).dpi;
    nivel = pi1 + cumsum([0; FAC*dpi(2:end)]);
    hL(k) = plot(fecha, nivel, sty{k}, 'Color',col{k}, 'LineWidth',LW(k));
end
yline(0,'-','Color',[.7 .7 .7]); grid on; xlim([fecha(1) fecha(end)]);
set(gca,'GridColor',gcol,'GridAlpha',1,'Layer','top','FontSize',10,'TickLabelInterpreter','latex');
ylabel('\% anual','Interpreter','latex','FontSize',12);
lg=legend([hObs hL],{'$\pi_t$ observada','moda mc=5','moda mc=6','media MH'}, ...
          'Interpreter','latex','Location','northeast','FontSize',10); lg.Box='on';
exportgraphics(f1, fullfile(outdir,'E6_infl_nivel_A.pdf'), 'ContentType','vector');
disp('--- E6: figura guardada en output/E6_infl_nivel_A.pdf ---');
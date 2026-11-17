%% plot_E10.m — E10: nivel de inflacion suavizado (Uribe-B) vs observado
%  Lee data/E10_smooth_B.mat + data/infl_obs_A.mat -> output/E10_infl_nivel_B.pdf
proj_root = fileparts(fileparts(mfilename('fullpath')));
SM = load(fullfile(proj_root,'data','E10_smooth_B.mat')); SM = SM.SM;
IO = load(fullfile(proj_root,'data','infl_obs_A.mat'));
infl_obs = IO.infl_obs(:); fecha = IO.infl_date(:); pi1 = infl_obs(1);
outdir = fullfile(proj_root,'output'); if ~exist(outdir,'dir'), mkdir(outdir); end

dpi = SM.dpi;

% --- CHEQUEO DE ESCALA / PICO (regla 22) ---
rec = pi1 + cumsum([0; 4*dpi(2:end)]);
fprintf('Inflacion observada: pi_1=%.3f  pi_T=%.3f  (media=%.3f)\n', pi1, infl_obs(end), mean(infl_obs));
fprintf('Nivel reconstruido pi_T (x4)=%.3f\n', rec(end));
fprintf('PICO  observado=%.2f (en %.2f) | reconstruido B=%.2f (en %.2f)\n', ...
        max(infl_obs), fecha(infl_obs==max(infl_obs)), ...
        max(rec), fecha(rec==max(rec)));

FAC = 4;   % trimestral -> anual (mismo x4 que E0/E6)
nivel = pi1 + cumsum([0; FAC*dpi(2:end)]);

% --- figura ---
gcol=[0.90 0.90 0.92];
f1=figure('Color','w','Position',[80 80 1000 460]);
tiledlayout(1,1,'Padding','loose'); nexttile; hold on; box off;
hObs = plot(fecha, infl_obs, '-', 'Color',[0.5 0.5 0.5], 'LineWidth',1.4);
hRec = plot(fecha, nivel,    '-', 'Color',[0.11 0.35 0.85], 'LineWidth',2.4);
yline(0,'-','Color',[.7 .7 .7]); grid on; xlim([fecha(1) fecha(end)]);
set(gca,'GridColor',gcol,'GridAlpha',1,'Layer','top','FontSize',10,'TickLabelInterpreter','latex');
ylabel('\% anual','Interpreter','latex','FontSize',12);
lg=legend([hObs hRec],{'$\pi_t$ observada','$\pi_t$ suavizada (moda mc5)'}, ...
          'Interpreter','latex','Location','northeast','FontSize',10); lg.Box='on';
exportgraphics(f1, fullfile(outdir,'E10_infl_nivel_B_v2.pdf'), 'ContentType','vector');
disp('--- E10: figura guardada en output/E10_infl_nivel_B.pdf ---');
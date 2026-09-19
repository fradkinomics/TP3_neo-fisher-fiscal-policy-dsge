%% plot_E0_irfs.m — IRFs Figuras 11 y 12 (Uribe), estética custom
% Reproducible: carga las IRFs desde data/E0_irfs.mat (no depende de la memoria)
proj_root = fileparts(fileparts(mfilename('fullpath')));
S = load(fullfile(proj_root,'data','E0_irfs.mat'));  irfs = S.irfs_E0;
outdir = fullfile(proj_root,'output'); if ~exist(outdir,'dir'), mkdir(outdir); end

% ---------- Paleta ----------
col_I =[0.78 0.24 0.20];  % tasa nominal I_t  -> ROJO
col_PI=[0.15 0.29 0.52];  % inflación   Pi_t  -> AZUL
col_Y =[0.16 0.44 0.42];  % producto    Y_t   -> VERDE
gcol=[0.90 0.90 0.92]; LW=2.4; H=21;

% ---------- Niveles por acumulación ----------
shk={'eps_gm','eps_zm2','eps_zm'};  ttl={'$X_t^m$','$z_t^{m2}$','$z_t^m$'};
for s=1:3
  di =irfs.(['di_obs_'  shk{s}])(:);  dpi=irfs.(['dpi_obs_' shk{s}])(:);
  dy =irfs.(['dy_obs_'  shk{s}])(:);
  IR(s).I=4*cumsum(di); IR(s).PI=4*cumsum(dpi); IR(s).Y=cumsum(dy);
  IR(s).rr=IR(s).I(1:end-1)-IR(s).PI(2:end);
end
f=1/IR(1).I(end);
for c={'I','PI','Y','rr'}, IR(1).(c{1})=IR(1).(c{1})*f; end

% ylims de Uribe (editables si algún panel difiere)
yl_top={[0 2],[-0.5 1],[-0.5 1]};   yl_bot={[0 0.4],[-0.2 0.6],[-0.3 0.1]};

% ================= FIGURA 11 =================
t=(0:H-1)';  ttl={'$X_t^m$','$z_t^{m2}$','$z_t^m$'};
f1=figure('Color','w','Position',[100 100 1180 640]);
tiledlayout(2,3,'TileSpacing','compact','Padding','loose');
axT=gobjects(1,3); axB=gobjects(1,3);
for s=1:3
  axT(s)=nexttile(s); hold on; box off;
  hI =plot(t,IR(s).I ,'-','Color',col_I ,'LineWidth',LW);   % I_t rojo
  hPI=plot(t,IR(s).PI,'-','Color',col_PI,'LineWidth',LW);   % Pi_t azul
  yline(0,'-','Color',[.6 .6 .6]); xlim([0 20]); ylim(yl_top{s}); grid on;
  set(gca,'GridColor',gcol,'GridAlpha',1,'Layer','top','FontSize',10,'TickLabelInterpreter','latex');
  axT(s).Toolbar=[]; title(ttl{s},'Interpreter','latex','FontSize',13,'FontWeight','normal');

  axB(s)=nexttile(s+3); hold on; box off;
  hY=plot(t,IR(s).Y,'-','Color',col_Y,'LineWidth',LW);
  yline(0,'-','Color',[.6 .6 .6]); xlim([0 20]); ylim(yl_bot{s}); grid on;
  if s==3, yticks(-0.3:0.1:0.1); end 
  set(gca,'GridColor',gcol,'GridAlpha',1,'Layer','top','FontSize',10,'TickLabelInterpreter','latex');
  axB(s).Toolbar=[];
end
lg1=legend(axT(3),[hI hPI],{'$I_t$','$\Pi_t$'},'Interpreter','latex','Location','northeast','FontSize',11); lg1.Box='on';
lg2=legend(axB(3),hY,{'$Y_t$'},'Interpreter','latex','Location','southeast','FontSize',11); lg2.Box='on';
exportgraphics(f1,fullfile(outdir,'E0_Fig11.pdf'),'ContentType','vector');

% ================= FIGURA 12 =================
tr=(0:H-2)';
f2=figure('Color','w','Position',[100 100 640 480]);
tiledlayout(1,1,'Padding','loose'); nexttile; hold on; box off;
p1=plot(tr,IR(1).rr,'-' ,'Color',col_PI,'LineWidth',LW);
p2=plot(tr,IR(2).rr,'--','Color',col_I ,'LineWidth',LW);
p3=plot(tr,IR(3).rr,':' ,'Color',col_Y ,'LineWidth',LW+0.4);
yline(0,'-','Color',[.6 .6 .6]); xlim([0 20]); ylim([-0.5 1]); grid on;
set(gca,'GridColor',gcol,'GridAlpha',1,'Layer','top','FontSize',11,'TickLabelInterpreter','latex');
ax=gca; ax.Toolbar=[];
lg=legend([p1 p2 p3],{'$X_t^m$','$z_t^{m2}$','$z_t^m$'},'Interpreter','latex','Location','northeast','FontSize',11); lg.Box='on';
exportgraphics(f2,fullfile(outdir,'E0_Fig12.pdf'),'ContentType','vector');
disp('--- Figuras E0 (v2) guardadas en output/ ---');
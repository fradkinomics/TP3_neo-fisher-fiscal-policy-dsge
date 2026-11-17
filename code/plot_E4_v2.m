%% plot_E4_v2.m — IRFs Uribe-A apaisadas: filas = shock, columnas = I, Pi, Y, r
%  Lee data/E4_irfs_A.mat -> output/E4_irfs_A_v2.pdf
proj_root = fileparts(fileparts(mfilename('fullpath')));
S = load(fullfile(proj_root,'data','E4_irfs_A.mat')); IRF = S.IRF;
outdir = fullfile(proj_root,'output');
tags = {'modaE1','moda_mc6','mediaMH'};
H = 21; t = (0:H-1)'; tr = (0:H-2)';
for k = 1:3
  tg = tags{k};
  I=4*cumsum(IRF.(tg).di_obs_eps_gm); PI=4*cumsum(IRF.(tg).dpi_obs_eps_gm); Y=cumsum(IRF.(tg).dy_obs_eps_gm);
  f=1/I(end);
  D1(k).I=I*f; D1(k).PI=PI*f; D1(k).Y=Y*f; D1(k).rr=(I(1:end-1)-PI(2:end))*f;
  I=4*cumsum(IRF.(tg).di_obs_eps_zm); PI=4*cumsum(IRF.(tg).dpi_obs_eps_zm); Y=cumsum(IRF.(tg).dy_obs_eps_zm);
  D2(k).I=I; D2(k).PI=PI; D2(k).Y=Y; D2(k).rr=I(1:end-1)-PI(2:end);
end
col = {[0.78 0.24 0.20],[0.16 0.44 0.42],[0.15 0.29 0.52]};
sty = {'-','--','-'};  LW = [1.8 1.6 2.0];  gcol = [0.90 0.90 0.92];
vars = {'I','PI','Y','rr'};  tit = {'$I_t$','$\Pi_t$','$Y_t$','$r_t$'};
filas = {'$g_t^m$','$z_t^m$'};
fig = figure('Color','w','Units','centimeters','Position',[2 2 16 8]);
tiledlayout(2,4,'TileSpacing','compact','Padding','compact');
hL = gobjects(1,3);
for r = 1:2
  if r==1, D=D1; else, D=D2; end
  for c = 1:4
    nexttile; hold on; box off;
    v = vars{c}; xx = t; if strcmp(v,'rr'), xx = tr; end
    for k = 1:3
      h = plot(xx, D(k).(v), sty{k}, 'Color',col{k}, 'LineWidth',LW(k));
      if r==1 && c==1, hL(k) = h; end
    end
    yline(0,'-','Color',[.6 .6 .6]); xlim([0 20]); grid on;
    set(gca,'GridColor',gcol,'GridAlpha',1,'Layer','top','FontSize',7,'TickLabelInterpreter','latex');
    if r==1, title(tit{c},'Interpreter','latex','FontSize',11,'FontWeight','normal'); end
    if c==1, ylabel(filas{r},'Interpreter','latex','FontSize',11,'Rotation',0,'HorizontalAlignment','right'); end
  end
end
lg = legend(hL,{'moda mc5','moda mc6','media MH'},'Interpreter','latex','Orientation','horizontal','FontSize',8);
lg.Box = 'on'; lg.Layout.Tile = 'south';
exportgraphics(fig, fullfile(outdir,'E4_irfs_A_v2.pdf'),'ContentType','vector');
disp('Guardado: output/E4_irfs_A_v2.pdf');
%% plot_E8_v2.m — IRFs Uribe-B apaisadas: filas = shock, columnas = I, Pi, Y, r
%  Lee data/E8_irfs_B.mat -> output/E8_irfs_B_v2.pdf
proj_root = fileparts(fileparts(mfilename('fullpath')));
S = load(fullfile(proj_root,'data','E8_irfs_B.mat')); IRF = S.IRF;
outdir = fullfile(proj_root,'output');
H = 21; t = (0:H-1)'; tr = (0:H-2)';
I=4*cumsum(IRF.di_obs_eps_zm2); PI=4*cumsum(IRF.dpi_obs_eps_zm2); Y=cumsum(IRF.dy_obs_eps_zm2);
f=1/I(end);
D = cell(1,2);   % fuerza D a ser celda (1 por shock): evita choque con variables previas
D{1}.I=I*f; D{1}.PI=PI*f; D{1}.Y=Y*f; D{1}.rr=(I(1:end-1)-PI(2:end))*f;
I=4*cumsum(IRF.di_obs_eps_zm); PI=4*cumsum(IRF.dpi_obs_eps_zm); Y=cumsum(IRF.dy_obs_eps_zm);
D{2}.I=I; D{2}.PI=PI; D{2}.Y=Y; D{2}.rr=I(1:end-1)-PI(2:end);
colr = [0.15 0.29 0.52]; gcol = [0.90 0.90 0.92];
vars = {'I','PI','Y','rr'};  tit = {'$I_t$','$\Pi_t$','$Y_t$','$r_t$'};
filas = {'$z_t^{m2}$','$z_t^m$'};
fig = figure('Color','w','Units','centimeters','Position',[2 2 16 8]);
tiledlayout(2,4,'TileSpacing','compact','Padding','compact');
for r = 1:2
  for c = 1:4
    nexttile; hold on; box off;
    v = vars{c}; xx = t; if strcmp(v,'rr'), xx = tr; end
    h = plot(xx, D{r}.(v), '-', 'Color',colr, 'LineWidth',2.0);
    if r==1 && c==1, hL = h; end
    yline(0,'-','Color',[.6 .6 .6]); xlim([0 20]); grid on;
    set(gca,'GridColor',gcol,'GridAlpha',1,'Layer','top','FontSize',7,'TickLabelInterpreter','latex');
    if r==1, title(tit{c},'Interpreter','latex','FontSize',11,'FontWeight','normal'); end
    if c==1, ylabel(filas{r},'Interpreter','latex','FontSize',11,'Rotation',0,'HorizontalAlignment','right'); end
  end
end
lg = legend(hL,{'moda mc=5'},'Interpreter','latex','Orientation','horizontal','FontSize',8);
lg.Box = 'on'; lg.Layout.Tile = 'south';
exportgraphics(fig, fullfile(outdir,'E8_irfs_B_v2.pdf'),'ContentType','vector');
disp('Guardado: output/E8_irfs_B_v2.pdf');
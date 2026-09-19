%% plot_E4.m — E4: IRFs Uribe-A a shocks monetarios (g^m, z^m)
%  Compara 3 parametrizaciones (moda E1, moda mc=6, media MH).
%  Lee data/E4_irfs_A.mat -> exporta output/E4_irfs_A.pdf
proj_root = fileparts(fileparts(mfilename('fullpath')));
S = load(fullfile(proj_root,'data','E4_irfs_A.mat')); IRF = S.IRF;
outdir = fullfile(proj_root,'output'); if ~exist(outdir,'dir'), mkdir(outdir); end

tags = {'modaE1','moda_mc6','mediaMH'};
H = 21; t = (0:H-1)'; tr = (0:H-2)';

% --- niveles por acumulacion (x4 anualiza I y Pi; Y sin x4) ---
for k = 1:numel(tags)
  tg = tags{k};
  % g^m permanente: normalizado (I(LP)=1 por parametrizacion)
  I=4*cumsum(IRF.(tg).di_obs_eps_gm); PI=4*cumsum(IRF.(tg).dpi_obs_eps_gm); Y=cumsum(IRF.(tg).dy_obs_eps_gm);
  f=1/I(end);
  G(k).I=I*f; G(k).PI=PI*f; G(k).Y=Y*f; G(k).rr=(I(1:end-1)-PI(2:end))*f;
  % z^m transitorio: sin normalizar
  I=4*cumsum(IRF.(tg).di_obs_eps_zm); PI=4*cumsum(IRF.(tg).dpi_obs_eps_zm); Y=cumsum(IRF.(tg).dy_obs_eps_zm);
  Z(k).I=I; Z(k).PI=PI; Z(k).Y=Y; Z(k).rr=I(1:end-1)-PI(2:end);
end

% --- estetica (estilo plot_E0) ---
col = {[0.78 0.24 0.20],[0.16 0.44 0.42],[0.15 0.29 0.52]}; % E1 rojo, mc6 verde, MH azul
sty = {'-','--','-'};  LW = [2.2 2.0 2.6];  gcol=[0.90 0.90 0.92];
rowvar = {'I','PI','Y','rr'};
rowlab = {'$I_t$','$\Pi_t$','$Y_t$','$r_t$'};
collab = {'$g_t^m$ (permanente)','$z_t^m$ (transitorio)'};

f1 = figure('Color','w','Position',[80 60 900 1050]);
tiledlayout(4,2,'TileSpacing','compact','Padding','loose');
hL = gobjects(1,numel(tags));
for r = 1:4
  for c = 1:2
    nexttile((r-1)*2+c); hold on; box off;
    if c==1, D=G; else, D=Z; end
    vv=rowvar{r}; xx=t; if strcmp(vv,'rr'), xx=tr; end
    for k=1:numel(tags)
      h=plot(xx, D(k).(vv), sty{k}, 'Color',col{k}, 'LineWidth',LW(k));
      if r==1 && c==1, hL(k)=h; end
    end
    yline(0,'-','Color',[.6 .6 .6]); xlim([0 20]); grid on;
    set(gca,'GridColor',gcol,'GridAlpha',1,'Layer','top','FontSize',9,'TickLabelInterpreter','latex');
    if r==1, title(collab{c},'Interpreter','latex','FontSize',12,'FontWeight','normal'); end
    if c==1, ylabel(rowlab{r},'Interpreter','latex','FontSize',14,'Rotation',0,'HorizontalAlignment','right'); end
  end
end
lg = legend(hL,{'moda mc=5','moda mc=6','media MH'},'Interpreter','latex', ...
            'Orientation','horizontal','FontSize',10);
lg.Box='on'; lg.Layout.Tile='south';
exportgraphics(f1, fullfile(outdir,'E4_irfs_A.pdf'), 'ContentType','vector');
disp('--- E4: figura guardada en output/E4_irfs_A.pdf ---');
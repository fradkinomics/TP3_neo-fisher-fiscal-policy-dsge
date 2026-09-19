%% plot_E8.m — E8: IRFs Uribe-B a shocks monetarios activos (z^{m2}, z^m)
%  Parametrizacion unica: moda E7. Lee data/E8_irfs_B.mat -> output/E8_irfs_B.pdf
proj_root = fileparts(fileparts(mfilename('fullpath')));
S = load(fullfile(proj_root,'data','E8_irfs_B.mat')); IRF = S.IRF;
outdir = fullfile(proj_root,'output'); if ~exist(outdir,'dir'), mkdir(outdir); end

H = 21; t = (0:H-1)'; tr = (0:H-2)';

% --- niveles por acumulacion (x4 anualiza I y Pi; Y sin x4) ---
% z^{m2}: neo-Fisher cuasi-permanente -> normalizado a I(LP)=1
I=4*cumsum(IRF.di_obs_eps_zm2); PI=4*cumsum(IRF.dpi_obs_eps_zm2); Y=cumsum(IRF.dy_obs_eps_zm2);
f=1/I(end);
Z2.I=I*f; Z2.PI=PI*f; Z2.Y=Y*f; Z2.rr=(I(1:end-1)-PI(2:end))*f;
% z^m: transitorio -> sin normalizar
I=4*cumsum(IRF.di_obs_eps_zm); PI=4*cumsum(IRF.dpi_obs_eps_zm); Y=cumsum(IRF.dy_obs_eps_zm);
Zm.I=I; Zm.PI=PI; Zm.Y=Y; Zm.rr=I(1:end-1)-PI(2:end);

% --- estetica (estilo plot_E0) ---
col=[0.15 0.29 0.52]; gcol=[0.90 0.90 0.92];
rowvar={'I','PI','Y','rr'};
rowlab={'$I_t$','$\Pi_t$','$Y_t$','$r_t$'};
collab={'$z_t^{m2}$ (transitorio persistente, $\rho=0{,}999$)','$z_t^m$ (transitorio)'};

f1=figure('Color','w','Position',[80 60 900 1050]);
tiledlayout(4,2,'TileSpacing','compact','Padding','loose');
for r=1:4
  for c=1:2
    nexttile((r-1)*2+c); hold on; box off;
    if c==1, D=Z2; else, D=Zm; end
    vv=rowvar{r}; xx=t; if strcmp(vv,'rr'), xx=tr; end
    plot(xx, D.(vv), '-', 'Color',col, 'LineWidth',2.4);
    yline(0,'-','Color',[.6 .6 .6]); xlim([0 20]); grid on;
    set(gca,'GridColor',gcol,'GridAlpha',1,'Layer','top','FontSize',9,'TickLabelInterpreter','latex');
    if r==1, title(collab{c},'Interpreter','latex','FontSize',12,'FontWeight','normal'); end
    if c==1, ylabel(rowlab{r},'Interpreter','latex','FontSize',14,'Rotation',0,'HorizontalAlignment','right'); end
    if r==4, xlabel('trimestres','Interpreter','latex','FontSize',10); end
  end
end
exportgraphics(f1, fullfile(outdir,'E8_irfs_B.pdf'), 'ContentType','vector');
disp('--- E8: figura guardada en output/E8_irfs_B.pdf ---');
%% plot_E5.m — E5: descomposicion de varianza (barras apiladas)
%  Lee data/E5_vardec_A.mat -> output/E5_vardec_A.pdf
proj_root = fileparts(fileparts(mfilename('fullpath')));
S = load(fullfile(proj_root,'data','E5_vardec_A.mat')); VD = S.VD;
outdir = fullfile(proj_root,'output'); if ~exist(outdir,'dir'), mkdir(outdir); end

tags  = {'modaE1','moda_mc6','mediaMH'};
tlab  = {'moda mc=5','moda mc=6','media MH'};
% shocks activos en Uribe-A (dropeo z^{m2}, que es 0)
ord   = {'eps_gm','eps_zm','eps_g','eps_z','eps_xi','eps_theta'};
slab  = {'$g^m$','$z^m$','$g$','$z$','$\xi$','$\theta$'};
vlab  = {'$\Delta y$','$\Delta i$','$\Delta\pi$'};
vars3 = VD.vars;               % {'dy_obs','di_obs','dpi_obs'}
[~,ic]= ismember(ord, VD.shocks);

% paleta saturada; g^m rojo, z^m azul, g verde, z violeta, xi naranja, theta gris
col = [0.85 0.11 0.11;   % g^m   rojo saturado
       0.11 0.35 0.85;   % z^m   azul saturado
       0.12 0.60 0.30;   % g     verde saturado
       0.55 0.20 0.75;   % z     violeta
       0.95 0.55 0.10;   % xi    naranja
       0.60 0.60 0.63];  % theta gris (unico)

f1 = figure('Color','w','Position',[80 80 1120 420]);
tiledlayout(1,3,'TileSpacing','compact','Padding','loose');
hb = [];
for it = 1:numel(tags)
  nexttile; 
  Mv = VD.(tags{it});                 % filas=vars3, cols=shocks
  Data = Mv(:, ic);                   % 3 x 6  (var x shock)
  b = bar(Data,'stacked','EdgeColor','none','BarWidth',0.6);
  for k=1:numel(b), b(k).FaceColor = col(k,:); end
  if it==1, hb = b; end
  ylim([0 100]); xlim([0.4 3.6]);
  set(gca,'XTick',1:3,'XTickLabel',vlab,'TickLabelInterpreter','latex', ...
          'FontSize',11,'Layer','top'); box off;
  title(tlab{it},'Interpreter','latex','FontSize',12,'FontWeight','normal');
  if it==1, ylabel('\% de la varianza','Interpreter','latex','FontSize',12); end
end
lg = legend(hb, slab, 'Interpreter','latex','Orientation','horizontal','FontSize',11);
lg.Box='off'; lg.Layout.Tile='south';
exportgraphics(f1, fullfile(outdir,'E5_vardec_A.pdf'), 'ContentType','vector');
disp('--- E5: figura guardada en output/E5_vardec_A.pdf ---');
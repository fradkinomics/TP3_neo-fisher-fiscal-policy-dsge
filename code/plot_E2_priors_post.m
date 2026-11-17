%% plot_E2_priors_post.m — Fase 7: prior vs posterior del MH de Uribe-A (E2)
%  Usa las densidades que Dynare guardó en oo_ (uribe_A_E2_results.mat).
%  NO re-corre la cadena. Una figura 7x3 con una sola leyenda.
%  Salida: output/E2_priors_post.pdf
assert(exist('code_dir','var')==1,'Corré setting.m primero.');
outdir = fullfile(code_dir,'..','output');
R  = load(fullfile(code_dir,'uribe_A_E2','Output','uribe_A_E2_results.mat'),'oo_');
oo = R.oo_;

lista = {};                                   % {grupo, nombre} en orden de estimación
grupos = {'shocks_std','parameters'};
for g = 1:2
    fn = fieldnames(oo.posterior_density.(grupos{g}));
    for k = 1:numel(fn), lista(end+1,:) = {grupos{g}, fn{k}}; end %#ok<SAGROW>
end

f = figure('Color','w','Units','centimeters','Position',[2 2 16 21]);
tiledlayout(7,3,'TileSpacing','compact','Padding','compact');
for k = 1:size(lista,1)
    G = lista{k,1};  n = lista{k,2};
    pr = oo.prior_density.(G).(n);            % [x, densidad]
    po = oo.posterior_density.(G).(n);
    md = oo.posterior_mode.(G).(n);           % moda mode_compute=6
    ax = nexttile; hold(ax,'on'); box(ax,'on');
    h1 = plot(pr(:,1),pr(:,2),'-','Color',[0.6 0.6 0.6],'LineWidth',1.5);
    h2 = plot(po(:,1),po(:,2),'-','Color','k','LineWidth',1.5);
    h3 = xline(md,'--','Color',[0 0.6 0],'LineWidth',1.3);
    title(ax, nombre_tex(n),'Interpreter','latex','FontSize',11);
    set(ax,'FontSize',7,'TickLabelInterpreter','latex');
end
lg = legend([h1 h2 h3],{'prior','posterior','moda'}, ...
            'Interpreter','latex','Orientation','horizontal','FontSize',10);
lg.Layout.Tile = 'south';
exportgraphics(f, fullfile(outdir,'E2_priors_post.pdf'),'ContentType','vector');
fprintf('Guardado: output/E2_priors_post.pdf (%d parámetros)\n', size(lista,1));

% ---------- nombres de Dynare -> notación algebraica ----------
function s = nombre_tex(n)
tabla = {'eps_xi','$\sigma_\xi$'; 'eps_theta','$\sigma_\theta$'; 'eps_z','$\sigma_z$'; ...
         'eps_g','$\sigma_g$'; 'eps_gm','$\sigma_{g^m}$'; 'eps_zm','$\sigma_{z^m}$'; ...
         'phi','$\phi$'; 'alfa_pai','$\alpha_\pi$'; 'alfa_y','$\alpha_y$'; ...
         'gamma_m','$\gamma_m$'; 'gamma_i','$\gamma_I$'; 'delta','$\delta$'; ...
         'rho_xi','$\rho_\xi$'; 'rho_theta','$\rho_\theta$'; 'rho_z','$\rho_z$'; ...
         'rho_g','$\rho_g$'; 'rho_gm','$\rho_{g^m}$'; 'rho_zm','$\rho_{z^m}$'; ...
         'R11','$R_{11}$'; 'R22','$R_{22}$'; 'R33','$R_{33}$'};
s = tabla{strcmp(tabla(:,1),n),2};
end
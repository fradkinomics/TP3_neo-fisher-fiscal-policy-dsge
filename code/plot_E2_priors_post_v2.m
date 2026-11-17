%% plot_E2_priors_post_v2.m — prior vs posterior MH Uribe-A, grilla 4x6
%  Salida: output/E2_priors_post_v2.pdf
assert(exist('code_dir','var')==1,'Corré setting.m primero.');
outdir = fullfile(code_dir,'..','output');
R  = load(fullfile(code_dir,'uribe_A_E2','Output','uribe_A_E2_results.mat'),'oo_');  oo = R.oo_;
lista = {};  grupos = {'shocks_std','parameters'};
for g = 1:2
    fn = fieldnames(oo.posterior_density.(grupos{g}));
    for k = 1:numel(fn), lista(end+1,:) = {grupos{g}, fn{k}}; end %#ok<SAGROW>
end
f = figure('Color','w','Units','centimeters','Position',[2 2 16 12.5]);
tiledlayout(4,6,'TileSpacing','compact','Padding','compact');
usados = zeros(1,4);
for k = 1:size(lista,1)
    G = lista{k,1};  n = lista{k,2};
    fila = fila_de(n);  usados(fila) = usados(fila) + 1;
    ax = nexttile((fila-1)*6 + usados(fila)); hold(ax,'on'); box(ax,'on');
    pr = oo.prior_density.(G).(n);  po = oo.posterior_density.(G).(n);  md = oo.posterior_mode.(G).(n);
    h1 = plot(pr(:,1),pr(:,2),'-','Color',[0.6 0.6 0.6],'LineWidth',1.3);
    h2 = plot(po(:,1),po(:,2),'-','Color','k','LineWidth',1.3);
    h3 = xline(md,'--','Color',[0 0.6 0],'LineWidth',1.1);
    title(ax, nombre_tex(n),'Interpreter','latex','FontSize',10);
    set(ax,'FontSize',6,'TickLabelInterpreter','latex');
end
lg = legend([h1 h2 h3],{'prior','posterior','moda mc6'}, ...
            'Interpreter','latex','Orientation','horizontal','FontSize',9);
lg.Layout.Tile = 'south';
exportgraphics(f, fullfile(outdir,'E2_priors_post_v2.pdf'),'ContentType','vector');
disp('Guardado: output/E2_priors_post_v2.pdf');

function r = fila_de(n)
if startsWith(n,'eps_'), r = 1;
elseif startsWith(n,'rho_'), r = 3;
elseif startsWith(n,'R'),    r = 4;
else,                        r = 2;
end
end

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
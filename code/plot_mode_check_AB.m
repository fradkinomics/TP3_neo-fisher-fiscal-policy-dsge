%% plot_mode_check_AB.m — Fase 7: mode_check de E1 (Uribe-A) y E7 (Uribe-B)
%  Redibuja los cortes de la posterior con los datos que guardó Dynare en
%  graphs/*_check_plot_data.mat. NO re-estima. Títulos algebraicos y una
%  sola leyenda. Salidas: output/E1_mode_check.pdf y output/E7_mode_check.pdf
assert(exist('code_dir','var')==1,'Corré setting.m primero.');
outdir = fullfile(code_dir,'..','output');
mods = {'uribe_A_E1','uribe_B_E7'};
outs = {'E1_mode_check.pdf','E7_mode_check.pdf'};

for m = 1:2
    S  = load(fullfile(code_dir,mods{m},'graphs',[mods{m} '_check_plot_data.mat']));
    C  = S.mcheck.cross;            % por parámetro: [x, log-post, log-lik kernel]
    E  = S.mcheck.emode;            % valor de la moda de cada parámetro
    nm = fieldnames(C);

    f = figure('Color','w','Units','centimeters','Position',[2 2 16 21]);
    tiledlayout(7,3,'TileSpacing','compact','Padding','compact');
    for k = 1:numel(nm)
        ax = nexttile; hold(ax,'on'); box(ax,'on');
        d  = C.(nm{k});
        h1 = plot(d(:,1),d(:,2),'-','Color',[0 0.447 0.741],'LineWidth',1.2);
        h2 = plot(d(:,1),d(:,3),'-','Color',[0.850 0.325 0.098],'LineWidth',1.2);
        xline(E.(nm{k}),'-','Color',[0.3 0.75 0.93],'LineWidth',1.2);
        xlim(ax,[min(d(:,1)) max(d(:,1))]);
        bad = isnan(d(:,2));        % valores donde la posterior no se puede evaluar
        if any(bad)
            yl = ylim(ax);
            plot(d(bad,1), yl(1)*ones(sum(bad),1),'o','Color','r','MarkerFaceColor','r','MarkerSize',3);
            ylim(ax,yl);
        end
        title(ax, nombre_tex(nm{k}),'Interpreter','latex','FontSize',11);
        set(ax,'FontSize',7,'TickLabelInterpreter','latex');
    end
    lg = legend([h1 h2],{'log-posterior','kernel de la log-verosimilitud'}, ...
                'Interpreter','latex','Orientation','horizontal','FontSize',10);
    lg.Layout.Tile = 'south';
    exportgraphics(f, fullfile(outdir,outs{m}),'ContentType','vector');
    fprintf('Guardado: output/%s (%d parámetros)\n', outs{m}, numel(nm));
end

% ---------- nombres de Dynare -> notación algebraica ----------
function s = nombre_tex(n)
n = erase(n,'SE_');
tabla = {'eps_xi','$\sigma_\xi$'; 'eps_theta','$\sigma_\theta$'; 'eps_z','$\sigma_z$'; ...
         'eps_g','$\sigma_g$'; 'eps_gm','$\sigma_{g^m}$'; 'eps_zm','$\sigma_{z^m}$'; ...
         'eps_zm2','$\sigma_{z^{m2}}$'; 'phi','$\phi$'; 'alfa_pai','$\alpha_\pi$'; ...
         'alfa_y','$\alpha_y$'; 'gamma_m','$\gamma_m$'; 'gamma_i','$\gamma_I$'; ...
         'delta','$\delta$'; 'rho_xi','$\rho_\xi$'; 'rho_theta','$\rho_\theta$'; ...
         'rho_z','$\rho_z$'; 'rho_g','$\rho_g$'; 'rho_gm','$\rho_{g^m}$'; ...
         'rho_zm','$\rho_{z^m}$'; 'R11','$R_{11}$'; 'R22','$R_{22}$'; 'R33','$R_{33}$'};
s = tabla{strcmp(tabla(:,1),n),2};
end
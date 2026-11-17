%% plot_mode_check_AB_v2.m — mode_check E1 (Uribe-A) y E7 (Uribe-B), grilla 4x6
%  Una fila por grupo: desvíos, estructurales, persistencias, errores de medición.
%  Salidas: output/E1_mode_check_v2.pdf y output/E7_mode_check_v2.pdf
assert(exist('code_dir','var')==1,'Corré setting.m primero.');
outdir = fullfile(code_dir,'..','output');
mods = {'uribe_A_E1','uribe_B_E7'};
outs = {'E1_mode_check_v2.pdf','E7_mode_check_v2.pdf'};
for m = 1:2
    S  = load(fullfile(code_dir,mods{m},'graphs',[mods{m} '_check_plot_data.mat']));
    C  = S.mcheck.cross;  E = S.mcheck.emode;  nm = fieldnames(C);
    f = figure('Color','w','Units','centimeters','Position',[2 2 16 12.5]);
    tiledlayout(4,6,'TileSpacing','compact','Padding','compact');
    usados = zeros(1,4);
    for k = 1:numel(nm)
        fila = fila_de(nm{k});  usados(fila) = usados(fila) + 1;
        ax = nexttile((fila-1)*6 + usados(fila)); hold(ax,'on'); box(ax,'on');
        d  = C.(nm{k});
        h1 = plot(d(:,1),d(:,2),'-','Color',[0 0.447 0.741],'LineWidth',1.1);
        h2 = plot(d(:,1),d(:,3),'-','Color',[0.850 0.325 0.098],'LineWidth',1.1);
        xline(E.(nm{k}),'-','Color',[0.3 0.75 0.93],'LineWidth',1.1);
        xlim(ax,[min(d(:,1)) max(d(:,1))]);
        bad = isnan(d(:,2));
        if any(bad)
            yl = ylim(ax);
            plot(d(bad,1), yl(1)*ones(sum(bad),1),'o','Color','r','MarkerFaceColor','r','MarkerSize',2.5);
            ylim(ax,yl);
        end
        title(ax, nombre_tex(nm{k}),'Interpreter','latex','FontSize',10);
        set(ax,'FontSize',6,'TickLabelInterpreter','latex');
    end
    lg = legend([h1 h2],{'log-posterior','kernel de la log-verosimilitud'}, ...
                'Interpreter','latex','Orientation','horizontal','FontSize',9);
    lg.Layout.Tile = 'south';
    exportgraphics(f, fullfile(outdir,outs{m}),'ContentType','vector');
    fprintf('Guardado: output/%s\n', outs{m});
end

function r = fila_de(n)
if startsWith(n,'SE_') || startsWith(n,'eps_'), r = 1;
elseif startsWith(n,'rho_'), r = 3;
elseif startsWith(n,'R'),    r = 4;
else,                        r = 2;
end
end

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
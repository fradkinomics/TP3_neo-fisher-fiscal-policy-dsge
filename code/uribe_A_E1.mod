// ============================================================
//  uribe_A_E1.mod — Uribe (2022) NK — ENTREGABLE E1, versión CALIBRADA
// ============================================================

// ---------- VARIABLES ENDÓGENAS (19) ----------
var
  y h lam pai i w mc paitil       // 8 estructurales
  xi theta z g zm zm2 gm          // 7 procesos exógenos (AR1)
  dy_obs r_obs di_obs dpi_obs     // 4 observables (medición)
;

// ---------- INNOVACIONES (7) ----------
varexo eps_xi eps_theta eps_z eps_g eps_zm eps_zm2 eps_gm  me_dy me_r me_di ;

// ---------- PARÁMETROS ----------
parameters
  sigma alfa eta gss betta_tilde betta thetass mu
  phi alfa_pai alfa_y gamma_m gamma_i delta
  rho_xi rho_theta rho_z rho_g rho_gm rho_zm rho_zm2
  sig_xi sig_theta sig_z sig_g sig_gm sig_zm sig_zm2
  R11 R22 R33 ;

// ---------- CALIBRACIÓN (Tabla 4) ----------
sigma       = 2;
alfa        = 0.75;
eta         = 6;
gss         = 0.004131;
betta_tilde = 0.99;
betta       = betta_tilde*exp(sigma*gss);   // = 0.9982 (Tabla 4)
thetass     = -log(2/3);                     // = 0.4055 (fija h=1/3)
mu          = eta/(eta-1);                   // markup SS derivado = 1.2

// ---------- ESTIMADOS, fijados en POSTERIOR MEAN (Tabla 5) ----------
phi       = 146;
alfa_pai  = 2.32;
alfa_y    = 0.188;
gamma_m   = 0.606;
gamma_i   = 0.242;
delta     = 0.258;

rho_xi    = 0.915;   rho_theta = 0.708;   rho_z   = 0.700;
rho_g     = 0.221;   rho_gm    = 0.248;   rho_zm  = 0.306;   rho_zm2 = 0;

sig_xi    = 0.0287;    sig_theta = 0.00164;   sig_z   = 0.00122;
sig_g     = 0.00758;   sig_gm    = 0.000848;  sig_zm  = 0.000832;  sig_zm2 = 0; // Uribe-A: apaga z^{m2}
R11 = 0.0378;  R22 = 0.0208;  R33 = 0.00236;   // = R_ii(paper) × 100^2, se sobreescriben al estimar


// ============================================================
//  MODELO (no lineal; Dynare linealiza con order=1)
// ============================================================
model;

#chi = ( alfa*(1/3)^(alfa-1)/mu ) * ( 1 - exp(thetass)/3 )
       / ( exp(thetass) * (1/3)^alfa * ( 1 - delta/exp(gss) ) );
#A   = (1/betta_tilde) / ( ((1/3)^alfa)^alfa_y );

// ---------- (1) FOC consumo → utilidad marginal ----------
lam = exp(xi) * ( y - delta*y(-1)/exp(g) )^(-sigma)
             * ( 1 - exp(theta)*h )^( chi*(1-sigma) );

// ---------- (2) Oferta laboral ----------
w = chi * exp(theta) * ( y - delta*y(-1)/exp(g) ) / ( 1 - exp(theta)*h );

// ---------- (3) Euler ----------
lam = betta*(1+i) * lam(+1)/(1+pai(+1)) * exp( -gm(+1) - sigma*g(+1) );

// ---------- (4) Producción ----------
y = exp(z) * h^alfa;

// ---------- (5) Costo marginal real ----------
mc = w / ( alfa*exp(z)*h^(alfa-1) );

// ---------- (6) Curva de Phillips (Rotemberg) ----------
(1+pai)/(1+paitil) * ( (1+pai)/(1+paitil) - 1 )
   = betta * exp((1-sigma)*g(+1)) * lam(+1)/lam
        * (1+pai(+1))/(1+paitil(+1)) * ( (1+pai(+1))/(1+paitil(+1)) - 1 )
     + 1/(phi*(mu-1)) * ( mu*mc - 1 ) * y ;

// ---------- (7) Regla de Taylor (forma del código: dividida por e^{zm2}) ----------
(1+i)/exp(zm2) =
     ( A * ( (1+pai)/exp(zm2) )^alfa_pai * y^alfa_y )^(1-gamma_i)
   * ( (1+i(-1))/exp(zm2(-1)) )^gamma_i
   * exp(zm) ;

// ---------- (8) Inflación de referencia (backward-looking) ----------
1+paitil = exp(-gamma_m*gm) * (1+paitil(-1))^gamma_m * (1+pai)^(1-gamma_m) ;

// ---------- PROCESOS EXÓGENOS AR(1) (7) ----------
xi    = rho_xi*xi(-1)                                 + eps_xi/100 ;
theta = (1-rho_theta)*thetass + rho_theta*theta(-1)   + eps_theta/100 ;
z     = rho_z*z(-1)                                   + eps_z/100 ;
g     = (1-rho_g)*gss + rho_g*g(-1)                   + eps_g/100 ;
zm    = rho_zm*zm(-1)                                 + eps_zm/100 ;
zm2   = rho_zm2*zm2(-1)                               + eps_zm2/100 ;
gm    = rho_gm*gm(-1)                                 + eps_gm/100 ;

// ---------- ECUACIONES DE MEDICIÓN (4 observables) ----------
dy_obs  = 100*( ( log(y) - log(y(-1)) ) + ( g - steady_state(g) ) )        + sqrt(R11)*me_dy ;
r_obs   = 100*( ( i - pai ) - ( steady_state(i) - steady_state(pai) ) )    + sqrt(R22)*me_r ;
di_obs  = 100*( ( i - i(-1) ) + gm )                                       + sqrt(R33)*me_di ;
dpi_obs = 100*( ( pai - pai(-1) ) + gm );

end;


// ============================================================
//  STEADY STATE (analítico; derivado de nk_ss.m)
// ============================================================
steady_state_model;
  // shocks en su media
  theta   = thetass;
  g       = gss;
  z       = 0;
  xi      = 0;
  zm      = 0;
  zm2     = 0;
  gm      = 0;
  chi_ss  = ( alfa*(1/3)^(alfa-1)/mu ) * ( 1 - exp(thetass)/3 )
            / ( exp(thetass) * (1/3)^alfa * ( 1 - delta/exp(gss) ) );
      
  // nominales detrendizados
  pai     = 0;
  paitil  = 0;

  // reales
  h       = 1/3;
  y       = h^alfa;
  w       = alfa*h^(alfa-1)/mu;
    lam     = ( y - delta*y/exp(g) )^(-sigma) * ( 1 - exp(theta)*h )^( chi_ss*(1-sigma) );
  mc      = 1/mu;
  i       = 1/betta_tilde - 1;

  // observables: media cero en SS
  dy_obs  = 0;
  r_obs   = 0;
  di_obs  = 0;
  dpi_obs = 0;
end;

// ============================================================
//  CHEQUEOS
// ============================================================
resid;                       // residuos de cada ecuación (deben ser ~0)
steady;                      // calcula y muestra el estado estacionario
check;                       // verifica Blanchard-Kahn (determinación)
disp('--- STEADY STATE Y BK: OK ---');


varobs dy_obs r_obs di_obs;



estimated_params;
// --- Estructurales (priors de Uribe, SIN reescalar) ---
phi,       146,   , , gamma_pdf,   50,    20;
alfa_pai,  2.32,  , , gamma_pdf,   1.5,   0.25;
alfa_y,    0.188, , , gamma_pdf,   0.125, 0.1;
gamma_m,   0.606, , , uniform_pdf, , , 0, 1;
gamma_i,   0.242, , , uniform_pdf, , , 0, 1;
delta,     0.258, , , uniform_pdf, , , 0, 1;

// --- Persistencias (Beta, SIN reescalar) ---
rho_xi,    0.915, , , beta_pdf, 0.7, 0.2;
rho_theta, 0.708, , , beta_pdf, 0.7, 0.2;
rho_z,     0.700, , , beta_pdf, 0.7, 0.2;
rho_g,     0.221, , , beta_pdf, 0.3, 0.2;
rho_gm,    0.248, , , beta_pdf, 0.3, 0.2;
rho_zm,    0.306, , , beta_pdf, 0.3, 0.2;

// --- Desvíos de shocks: NORMAL TRUNCADA EN 0, prior x100 ---
stderr eps_xi,    2.87,   0, , normal_pdf, 1,    1;
stderr eps_theta, 0.164,  0, , normal_pdf, 1,    1;
stderr eps_z,     0.122,  0, , normal_pdf, 1,    1;
stderr eps_g,     0.758,  0, , normal_pdf, 1,    1;
stderr eps_gm,    0.0848, 0, , normal_pdf, 0.25, 0.25;
stderr eps_zm,    0.0832, 0, , normal_pdf, 0.25, 0.25;

// --- Varianzas error de medición R_ii: NORMAL TRUNCADA EN 0, prior x100^2 ---
R11, 0.0446,  0, , normal_pdf, 0.0378,  0.0218;
R22, 0.0455,  0, , normal_pdf, 0.0208,  0.012;
R33, 0.00174, 0, , normal_pdf, 0.00236, 0.00136;
end;


shocks;
  var eps_zm2 = 0;   // Uribe-A: z^{m2} apagado
  var me_dy   = 1;   // error de medición: varianza unitaria (la magnitud va en sqrt(R_ii))
  var me_r    = 1;
  var me_di   = 1;
end;


estimation(order=1,
           datafile='../data/Datos.xlsx', xls_sheet=data,
           mode_compute=5, mode_check,
           mh_replic=0, plot_priors=0);
// ============================================================
//  uribe_calib.mod — Modelo NK de Uribe (2022), versión CALIBRADA
//  Objetivo: replicar IRFs de Figuras 11 y 12 (entregable E0)
//  Params: Tabla 4 (calibrados) + Tabla 5 posterior mean (fijados)
// ============================================================

// ---------- VARIABLES ENDÓGENAS (19) ----------
var
  y h lam pai i w mc paitil       // 8 estructurales
  xi theta z g zm zm2 gm          // 7 procesos exógenos (AR1)
  dy_obs r_obs di_obs dpi_obs     // 4 observables (medición)
;

// ---------- INNOVACIONES (7) ----------
varexo eps_xi eps_theta eps_z eps_g eps_zm eps_zm2 eps_gm ;

// ---------- PARÁMETROS ----------
parameters
  sigma alfa eta gss betta_tilde betta thetass chi mu   // calibrados/derivados
  phi alfa_pai alfa_y gamma_m gamma_i delta A           // rigidez, Taylor, hábito
  rho_xi rho_theta rho_z rho_g rho_gm rho_zm rho_zm2     // persistencias
  sig_xi sig_theta sig_z sig_g sig_gm sig_zm sig_zm2     // desvíos de shocks
;

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
rho_g     = 0.221;   rho_gm    = 0.248;   rho_zm  = 0.306;   rho_zm2 = 0.796;

sig_xi    = 0.0287;    sig_theta = 0.00164;   sig_z   = 0.00122;
sig_g     = 0.00758;   sig_gm    = 0.000848;  sig_zm  = 0.000832;  sig_zm2 = 0.00131;

// ---------- DERIVADOS del SS (dependen de delta) ----------
// chi se re-deriva para mantener h=1/3 dado delta (igual que nk_ss.m).
// Tabla 4 reporta 0.625, pero ese valor es para delta=0; con delta=0.258 → chi≈0.841.
chi = ( alfa*(1/3)^(alfa-1)/mu ) * ( 1 - exp(thetass)/3 )
      / ( exp(thetass) * (1/3)^alfa * ( 1 - delta/exp(gss) ) );

// A (constante de la regla de Taylor): se deriva del SS (pai_ss=0, y_ss=(1/3)^alfa)
A = (1/betta_tilde) / ( ((1/3)^alfa)^alfa_y );


// ============================================================
//  MODELO (no lineal; Dynare linealiza con order=1)
// ============================================================
model;

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
xi    = rho_xi    * xi(-1)              + eps_xi    ;
theta = (1-rho_theta)*thetass + rho_theta*theta(-1) + eps_theta ; // media = thetass
z     = rho_z     * z(-1)               + eps_z     ;
g     = (1-rho_g)*gss + rho_g*g(-1)     + eps_g     ;             // media = gss
zm    = rho_zm    * zm(-1)              + eps_zm    ;
zm2   = rho_zm2   * zm2(-1)             + eps_zm2   ;
gm    = rho_gm    * gm(-1)              + eps_gm    ;

// ---------- ECUACIONES DE MEDICIÓN (4 observables) ----------
dy_obs  = 100*( ( log(y) - log(y(-1)) ) + ( g - steady_state(g) ) );
r_obs   = 100*( ( i - pai ) - ( steady_state(i) - steady_state(pai) ) );
di_obs  = 100*( ( i - i(-1) ) + gm );
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

  // nominales detrendizados
  pai     = 0;
  paitil  = 0;

  // reales
  h       = 1/3;
  y       = h^alfa;
  w       = alfa*h^(alfa-1)/mu;
  lam     = ( y - delta*y/exp(g) )^(-sigma) * ( 1 - exp(theta)*h )^( chi*(1-sigma) );
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


// ============================================================
//  SHOCKS
//  Monetarios normalizados a 0.0025 = 0.25% trimestral = 1% anual
//  (misma convención que Uribe para las IRFs de Figs 11/12)
// ============================================================
shocks;
var eps_xi    = sig_xi^2;
var eps_theta = sig_theta^2;
var eps_z     = sig_z^2;
var eps_g     = sig_g^2;
var eps_gm    = 0.0025^2;
var eps_zm    = 0.0025^2;
var eps_zm2   = 0.0025^2;
end;

// ============================================================
//  RESOLUCIÓN + IRFs
//  order=1  →  ¡ACÁ se linealiza! (Taylor de primer orden en el SS)
// ============================================================
stoch_simul(order=1, irf=21, nograph) di_obs dpi_obs dy_obs ;

// ---- Guardar IRFs (reproducibilidad; independiente de la memoria) ----
irfs_E0 = oo_.irfs;
save(fullfile('..','data','E0_irfs.mat'), 'irfs_E0');
disp('--- IRFs E0 guardadas en data/E0_irfs.mat ---');

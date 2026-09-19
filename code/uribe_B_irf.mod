// ============================================================
//  uribe_B_irf.mod — Uribe-B — GENERADOR de IRFs (E8)
//  Base: uribe_A_irf.mod. Cambios Uribe-B: g^m APAGADO (rho_gm=0,
//  eps_gm off); z^{m2} activo y MUY persistente (rho_zm2=0.999).
//  Shocks monetarios activos: z^{m2} y z^m, normalizados a 0.0025=1% anual.
//  Parametrización ÚNICA horneada = moda E7 (fuente: output/E7_moda_sd.csv).
// ============================================================

var
  y h lam pai i w mc paitil
  xi theta z g zm zm2 gm
  dy_obs r_obs di_obs dpi_obs
;

varexo eps_xi eps_theta eps_z eps_g eps_zm eps_zm2 eps_gm ;

parameters
  sigma alfa eta gss betta_tilde betta thetass mu
  phi alfa_pai alfa_y gamma_m gamma_i delta
  rho_xi rho_theta rho_z rho_g rho_gm rho_zm rho_zm2
  sig_xi sig_theta sig_z sig_g sig_gm sig_zm sig_zm2 ;

// ---------- CALIBRACIÓN (Tabla 4) ----------
sigma=2; alfa=0.75; eta=6; gss=0.004131; betta_tilde=0.99;
betta=betta_tilde*exp(sigma*gss);
thetass=-log(2/3);
mu=eta/(eta-1);

// ---------- DEFAULTS = media MH (los sobreescribe el driver) ----------
phi=142.28; alfa_pai=2.4085; alfa_y=0.084379;
gamma_m=0.6414; gamma_i=0.093805; delta=0.22431;
rho_xi=0.90542; rho_theta=0.88124; rho_z=0.87976;
rho_g=0.10432;  rho_gm=0;        rho_zm=0.2216;   rho_zm2=0.999;   // Uribe-B (moda E7)

sig_xi=0.026015; sig_theta=0.0003281; sig_z=0.00018636;
sig_g=0.0084315; sig_gm=0;         sig_zm=0.00055366; sig_zm2=0.0015351;

model;
#chi = ( alfa*(1/3)^(alfa-1)/mu ) * ( 1 - exp(thetass)/3 )
       / ( exp(thetass) * (1/3)^alfa * ( 1 - delta/exp(gss) ) );
#A   = (1/betta_tilde) / ( ((1/3)^alfa)^alfa_y );

lam = exp(xi) * ( y - delta*y(-1)/exp(g) )^(-sigma)
             * ( 1 - exp(theta)*h )^( chi*(1-sigma) );

w = chi * exp(theta) * ( y - delta*y(-1)/exp(g) ) / ( 1 - exp(theta)*h );

lam = betta*(1+i) * lam(+1)/(1+pai(+1)) * exp( -gm(+1) - sigma*g(+1) );

y = exp(z) * h^alfa;

mc = w / ( alfa*exp(z)*h^(alfa-1) );

(1+pai)/(1+paitil) * ( (1+pai)/(1+paitil) - 1 )
   = betta * exp((1-sigma)*g(+1)) * lam(+1)/lam
        * (1+pai(+1))/(1+paitil(+1)) * ( (1+pai(+1))/(1+paitil(+1)) - 1 )
     + 1/(phi*(mu-1)) * ( mu*mc - 1 ) * y ;

(1+i)/exp(zm2) =
     ( A * ( (1+pai)/exp(zm2) )^alfa_pai * y^alfa_y )^(1-gamma_i)
   * ( (1+i(-1))/exp(zm2(-1)) )^gamma_i
   * exp(zm) ;

1+paitil = exp(-gamma_m*gm) * (1+paitil(-1))^gamma_m * (1+pai)^(1-gamma_m) ;

// ---------- AR(1): "tanto por uno" (SIN /100) ----------
xi    = rho_xi*xi(-1)                                 + eps_xi ;
theta = (1-rho_theta)*thetass + rho_theta*theta(-1)   + eps_theta ;
z     = rho_z*z(-1)                                   + eps_z ;
g     = (1-rho_g)*gss + rho_g*g(-1)                   + eps_g ;
zm    = rho_zm*zm(-1)                                 + eps_zm ;
zm2   = rho_zm2*zm2(-1)                               + eps_zm2 ;
gm    = rho_gm*gm(-1)                                 + eps_gm ;

// ---------- MEDICIÓN (sin error de medición: son IRFs) ----------
dy_obs  = 100*( ( log(y) - log(y(-1)) ) + ( g - steady_state(g) ) ) ;
r_obs   = 100*( ( i - pai ) - ( steady_state(i) - steady_state(pai) ) ) ;
di_obs  = 100*( ( i - i(-1) ) + gm ) ;
dpi_obs = 100*( ( pai - pai(-1) ) + gm ) ;
end;

steady_state_model;
  theta=thetass; g=gss; z=0; xi=0; zm=0; zm2=0; gm=0;
  chi_ss = ( alfa*(1/3)^(alfa-1)/mu ) * ( 1 - exp(thetass)/3 )
           / ( exp(thetass) * (1/3)^alfa * ( 1 - delta/exp(gss) ) );
  pai=0; paitil=0;
  h=1/3; y=h^alfa; w=alfa*h^(alfa-1)/mu;
  lam=( y - delta*y/exp(g) )^(-sigma) * ( 1 - exp(theta)*h )^( chi_ss*(1-sigma) );
  mc=1/mu; i=1/betta_tilde-1;
  dy_obs=0; r_obs=0; di_obs=0; dpi_obs=0;
end;

resid;
steady;
check;
disp('--- uribe_B_irf: SS y BK OK ---');

// ---------- SHOCKS: monetarios normalizados a 1% anual; z^{m2} OFF ----------
shocks;
var eps_xi    = sig_xi^2;
var eps_theta = sig_theta^2;
var eps_z     = sig_z^2;
var eps_g     = sig_g^2;
var eps_gm    = 0;              // Uribe-B: g^m apagado
var eps_zm    = 0.0025^2;       // z^m transitorio (1% anual)
var eps_zm2   = 0.0025^2;       // z^{m2} persistente — neo-Fisher (1% anual)
end;

stoch_simul(order=1, irf=21, nograph) di_obs dpi_obs dy_obs ;
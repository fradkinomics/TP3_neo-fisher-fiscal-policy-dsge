// ============================================================
//  uribe_A_smoother.mod — Uribe-A — Kalman smoother (E6)
//  Escala de estimacion (eps/100, sqrt(R)*me, medicion x100).
//  Defaults = media MH. calib_smoother corre el smoother con
//  parametros FIJOS (sin re-estimar). El driver inyecta los 3 vec.
// ============================================================
var
  y h lam pai i w mc paitil
  xi theta z g zm zm2 gm
  dy_obs r_obs di_obs dpi_obs ;

varexo eps_xi eps_theta eps_z eps_g eps_zm eps_zm2 eps_gm  me_dy me_r me_di ;

parameters
  sigma alfa eta gss betta_tilde betta thetass mu
  phi alfa_pai alfa_y gamma_m gamma_i delta
  rho_xi rho_theta rho_z rho_g rho_gm rho_zm rho_zm2
  R11 R22 R33 ;

sigma=2; alfa=0.75; eta=6; gss=0.004131; betta_tilde=0.99;
betta=betta_tilde*exp(sigma*gss); thetass=-log(2/3); mu=eta/(eta-1);

// defaults = media MH
phi=149.64; alfa_pai=2.357; alfa_y=0.18446;
gamma_m=0.61073; gamma_i=0.29149; delta=0.25864;
rho_xi=0.91107; rho_theta=0.71332; rho_z=0.71631;
rho_g=0.23697; rho_gm=0.19926; rho_zm=0.32987; rho_zm2=0;
R11=0.04409; R22=0.044203; R33=0.0019132;

model;
#chi = ( alfa*(1/3)^(alfa-1)/mu ) * ( 1 - exp(thetass)/3 )
       / ( exp(thetass) * (1/3)^alfa * ( 1 - delta/exp(gss) ) );
#A   = (1/betta_tilde) / ( ((1/3)^alfa)^alfa_y );

lam = exp(xi) * ( y - delta*y(-1)/exp(g) )^(-sigma) * ( 1 - exp(theta)*h )^( chi*(1-sigma) );
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
   * ( (1+i(-1))/exp(zm2(-1)) )^gamma_i * exp(zm) ;
1+paitil = exp(-gamma_m*gm) * (1+paitil(-1))^gamma_m * (1+pai)^(1-gamma_m) ;

xi    = rho_xi*xi(-1)                                 + eps_xi/100 ;
theta = (1-rho_theta)*thetass + rho_theta*theta(-1)   + eps_theta/100 ;
z     = rho_z*z(-1)                                   + eps_z/100 ;
g     = (1-rho_g)*gss + rho_g*g(-1)                   + eps_g/100 ;
zm    = rho_zm*zm(-1)                                 + eps_zm/100 ;
zm2   = rho_zm2*zm2(-1)                               + eps_zm2/100 ;
gm    = rho_gm*gm(-1)                                 + eps_gm/100 ;

dy_obs  = 100*( ( log(y) - log(y(-1)) ) + ( g - steady_state(g) ) )        + sqrt(R11)*me_dy ;
r_obs   = 100*( ( i - pai ) - ( steady_state(i) - steady_state(pai) ) )    + sqrt(R22)*me_r ;
di_obs  = 100*( ( i - i(-1) ) + gm )                                       + sqrt(R33)*me_di ;
dpi_obs = 100*( ( pai - pai(-1) ) + gm );
end;

steady_state_model;
  theta=thetass; g=gss; z=0; xi=0; zm=0; zm2=0; gm=0;
  chi_ss = ( alfa*(1/3)^(alfa-1)/mu ) * ( 1 - exp(thetass)/3 )
           / ( exp(thetass) * (1/3)^alfa * ( 1 - delta/exp(gss) ) );
  pai=0; paitil=0; h=1/3; y=h^alfa; w=alfa*h^(alfa-1)/mu;
  lam=( y - delta*y/exp(g) )^(-sigma) * ( 1 - exp(theta)*h )^( chi_ss*(1-sigma) );
  mc=1/mu; i=1/betta_tilde-1;
  dy_obs=0; r_obs=0; di_obs=0; dpi_obs=0;
end;

resid; steady; check;
disp('--- uribe_A_smoother: SS y BK OK ---');

varobs dy_obs r_obs di_obs;

shocks;
var eps_xi    = 2.6954^2;
var eps_theta = 0.18682^2;
var eps_z     = 0.15113^2;
var eps_g     = 0.73889^2;
var eps_gm    = 0.12887^2;
var eps_zm    = 0.11113^2;
var eps_zm2   = 0;
var me_dy = 1; var me_r = 1; var me_di = 1;
end;

calib_smoother(datafile='../data/Datos.xlsx', xls_sheet=data);
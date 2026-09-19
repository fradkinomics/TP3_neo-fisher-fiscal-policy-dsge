# TP3 Macroeconometría — Punto 1: DSGE de Uribe (2022) en Dynare

Réplica y estimación bayesiana del modelo Nuevo Keynesiano de **Uribe (2022, sección IV)** en
**Dynare**, en dos versiones: **Uribe-A** (shock permanente a la meta `g^m`) y **Uribe-B** (shock
transitorio muy persistente `z^{m2}`, `ρ=0.999`). Cubre IRFs, descomposición de varianza y suavizado de
la inflación.

> **Detalle completo de decisiones metodológicas, hallazgos y prompt de arranque para IA:** ver
> [`Registro_TP3_macrometrics.md`](Registro_TP3_macrometrics.md).

---

## Requisitos

- **MATLAB** R2021a (o similar).
- **Dynare 7.0** ([descarga](https://www.dynare.org/download/)).
- Sistema operativo: Windows (probado). Debería funcionar en Mac/Linux ajustando rutas.

## Setup (una sola vez)

1. Cloná o descargá este repositorio.
2. Abrí `code/setting.m` y editá **solo** la variable `DYNARE_PATH` para que apunte a tu instalación de
   Dynare (p. ej. `C:\dynare\7.0\matlab`).
3. En MATLAB, abrí `code/setting.m` y apretá **Run** (botón verde). Esto carga Dynare, arma los paths y
   hace `cd(code/)`. **Corré `setting.m` al inicio de cada sesión, siempre.**

> Los `.mod` corren desde `code/` y leen los datos con `'../data/...'`. No cambies la estructura de
> carpetas.

## Estructura

```
TP3_macrometrics/
├─ code/        scripts .m y modelos .mod
├─ data/        Datos.xlsx (insumo de estimación) + .mat generados
├─ data_raw/    Excel crudos de Uribe (gdplev, LNU, fedfunds)
├─ output/      figuras y tablas que van al PDF (entregables)
├─ tools/       utilidades de la cátedra (estilo de gráficos, smoother)
├─ literature/  papers + consigna
└─ Registro_TP3_macrometrics.md   bitácora completa del trabajo
```

---

## Cómo reproducir la corrida (en orden)

Todos los comandos se escriben en la **Command Window** de MATLAB. **Corré `setting.m` primero.**
Las corridas `order=1` / IRF / smoother son **instantáneas**; solo **E2 (Metropolis-Hastings) tarda
~1h40m**.

### Uribe-A

| # | Comando(s) | Genera |
|---|---|---|
| 1 | `dynare uribe_calib` → `plot_E0_irfs` | **E0** — `output/E0_Fig11.pdf`, `E0_Fig12.pdf` |
| 2 | `dynare uribe_A_E1` → `guardar_E1` | **E1** — `output/E1_moda_sd.csv`, `E1_mode_check_0*.pdf` |
| 3 | `dynare uribe_A_E2` → `guardar_E2` *(MH, ~1h40m)* | **E2** — `output/E2_posterior.csv`, `E2_priors_post_0*.pdf` |
| 4 | `build_params_A` | `data/params_A.mat` (consolida las 3 parametrizaciones) |
| 5 | `build_E4_irfs` → `plot_E4` | **E4** — `output/E4_irfs_A.pdf` |
| 6 | `build_E5_vardec` → `plot_E5` | **E5** — `output/E5_vardec_A.csv`, `E5_vardec_A.pdf` |
| 7 | `build_infl_obs` → `build_E6_smooth` → `plot_E6` | **E6** — `output/E6_infl_nivel_A.pdf` |

### Uribe-B

| # | Comando(s) | Genera |
|---|---|---|
| 8 | `dynare uribe_B_E7` → `guardar_E7` | **E7** — `output/E7_moda_sd.csv`, `E7_mode_check_0*.pdf` |
| 9 | `build_E8_irfs` → `plot_E8` | **E8** — `output/E8_irfs_B.pdf` |
| 10 | `build_E9_vardec` | **E9** — `output/E9_vardec_B.csv` (se reporta como tabla) |
| 11 | `build_E10_smooth` → `plot_E10` | **E10** — `output/E10_infl_nivel_B.pdf` |

**Notas de reproducibilidad:**
- `guardar_E1/E2/E7` leen la moda de **memoria** (`oo_`) — corrélos **inmediatamente después** del
  `dynare ...` correspondiente, sin cerrar figuras.
- Los drivers de Uribe-A (`build_E4/E5/E6`) necesitan `data/params_A.mat` (paso 4) hecho primero.
- Los drivers de Uribe-B (`build_E8/E9/E10`) tienen la moda de E7 **horneada** en su `.mod`; corren
  `dynare` internamente, no necesitan un `params_B.mat`.
- Cada entregable se reproduce corriendo su propio script de cero; los `.mod` que ya funcionan **no se
  sobrescriben**.

---

## Datos

`data/Datos.xlsx` (hoja `data`, 255 obs, 1954Q4–2018Q2) ya está listo. Para regenerarlo desde los Excel
crudos de `data_raw/`: `make_data.m` / `read_data.m` / `observables.m` (fórmulas originales de Uribe).
La serie de inflación nivel (ancla de E6) la genera `build_infl_obs.m` → `data/infl_obs_A.mat`.

## Nota sobre el replication package

El paquete de replicación original de Uribe (`literature/replication_uribe_neo_fisher/`, ~195 MB) **no
está en este repo** por exceder el límite de tamaño de GitHub. Es público: se consigue en el sitio del
autor / repositorio de la AEA (*The Neo-Fisher Effect: Econometric Evidence…*, AEJ: Macroeconomics 2022).
No es necesario para reproducir la corrida (todo el código Dynak está en `code/`); sirve solo como
referencia de las ecuaciones y el steady state.

## Créditos

Trabajo grupal — Maestría en Economía, Universidad de San Andrés (2026), Macroeconometría.

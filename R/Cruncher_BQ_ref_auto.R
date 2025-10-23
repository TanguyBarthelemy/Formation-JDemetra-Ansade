# ---------------------------------------------------------------------------- #
# Description: Cruncher et génération de bilan qualité -----------------------
# ---------------------------------------------------------------------------- #


## Chargement packages ---------------------------------------------------------

library("dplyr")
library("rjwsacruncher")
library("JDCruncheR")
library("rjd3workspace")


# Création WS ------------------------------------------------------------------

# Si vous voulez utiliser votre WS, il faut mettre à jour le chemin vers le WS
file <- normalizePath("WS/example_1.xml")

ws_example <- jws_open(file)
path_ws_ref <- normalizePath("WS/ws_ref.xml", mustWork = FALSE)
path_ws_auto <- normalizePath("WS/ws_auto.xml", mustWork = FALSE)
save_workspace(jws = ws_example, file = path_ws_ref, replace = TRUE)
save_workspace(jws = ws_example, file = path_ws_auto, replace = TRUE)


## Options et paramètres -------------------------------------------------------

# Mettre votre chemin menant au cruncher
cruncher_bin_path <- normalizePath("C:/Users/UTZK0M/Software/jdemetra-related/jwsacruncher-3.5.1/bin/")
cruncher_bin_path

options(
    cruncher_bin_directory = cruncher_bin_path,
    is_cruncher_v3 = TRUE,
    default_matrix_item = c(
        "span.start",
        "span.end",
        "span.n",
        "arima",
        "arima.mean",
        "arima.p",
        "arima.d",
        "arima.q",
        "arima.bp",
        "arima.bd",
        "arima.bq",
        "m-statistics.m7",
        "m-statistics.q",
        "m-statistics.q-m2",
        "diagnostics.out-of-sample.mean:2",
        "diagnostics.out-of-sample.mse:2",
        "diagnostics.fcast-outsample-mean:2",
        "diagnostics.fcast-outsample-variance:2",
        "regression.nout",
        "residuals.kurtosis:3",
        "residuals.skewness:3",
        "residuals.lb2:3",
        "diagnostics.seas-sa-qs:2",
        "diagnostics.seas-sa-qs",
        "diagnostics.seas-sa-f:2",
        "diagnostics.seas-i-qs:2",
        "diagnostics.seas-i-qs",
        "diagnostics.seas-i-f:2",
        "diagnostics.td-sa-last:2",
        "diagnostics.td-i-last:2",
        "residuals.lb:3",
        "residuals.dh:3",
        "residuals.doornikhansen:3"
    )
)

getOption("default_matrix_item")

getOption("default_tsmatrix_series")
options(default_tsmatrix_series = c("s", "s_f", "sa", "sa_f"))


## Lecture pondérations --------------------------------------------------------

POND_NAF4 <- read.csv(
    file.path("Donnees", "Ponderations_2024.csv"),
    encoding = "UTF-8",
    dec = ","
)
colnames(POND_NAF4)
colnames(POND_NAF4)[1] <- "series"
colnames(POND_NAF4)


## Appel du cruncher -----------------------------------------------------------

# WS ref
cruncher_and_param(
    workspace = path_ws_ref,
    rename_multi_documents = TRUE,
    delete_existing_file = TRUE,
    policy = "lastoutliers",
    csv_layout = "vtable",
    short_column_headers = FALSE,
    log_file = "WS/ws_ref.log"
)


# WS automatique
cruncher_and_param(
    workspace = path_ws_auto,
    rename_multi_documents = TRUE,
    delete_existing_file = TRUE,
    policy = "complete",
    csv_layout = "vtable",
    short_column_headers = FALSE,
    log_file = "WS/ws_auto.log"
)


## Generation BQ ---------------------------------------------------------------

score_pond <- c(
    qs_residual_sa_on_sa = 30L,
    f_residual_sa_on_sa = 30L,
    qs_residual_sa_on_i = 20L,
    f_residual_sa_on_i = 20L,
    f_residual_td_on_sa = 30L,
    f_residual_td_on_i = 20L,
    oos_mean = 15L,
    residuals_homoskedasticity = 5L,
    residuals_skewness = 5L,
    m7 = 120L,
    q_m2 = 2L
)

demetra_path_ref <- "WS/ws_ref/Output/SAProcessing-1/demetra_m.csv"
demetra_path_auto <- "WS/ws_auto/Output/SAProcessing-1/demetra_m.csv"

BQ_ref <- demetra_path_ref |>
    extract_QR() |>
    compute_score(n_contrib_score = 3L, score_pond = score_pond)

BQ_auto <- demetra_path_auto |>
    extract_QR() |>
    compute_score(n_contrib_score = 3L, score_pond = score_pond)


# Si vous avez des pondérations, vous pouvez les ajouter
BQ_ref <- BQ_ref |>
    add_indicator(POND_NAF4) |>
    weighted_score("ponderation")
BQ_auto <- BQ_auto |>
    add_indicator(POND_NAF4) |>
    weighted_score("ponderation")


## Extraction score ------------------------------------------------------------

scores_ref <- extract_score(BQ_ref, weighted_score = FALSE) |>
    rename(score_ref = score)
scores_auto <- extract_score(BQ_auto, weighted_score = FALSE) |>
    rename(score_auto = score)

scores <- merge(scores_ref, scores_auto, by = "series", all = TRUE)

cat(
    "Il y a",
    sum(scores[["score_auto"]] < scores[["score_ref"]], na.rm = TRUE),
    "séries mieux ajustées par le WS automatique que par le WS ref.\n",
    "Il y a",
    sum(scores[["score_ref"]] < scores[["score_auto"]], na.rm = TRUE),
    "séries mieux ajustées par le WS ref que par le WS automatique.\n"
)


## Export ----------------------------------------------------------------------

write.table(
    x = scores,
    file = "BQ/score_ref_auto.csv",
    quote = FALSE,
    sep = ";",
    row.names = FALSE,
    dec = ".",
    na = ""
)

export_xlsx(
    x = BQ_ref,
    file = "BQ/BQ_ref.xlsx"
)
export_xlsx(
    x = BQ_auto,
    file = "BQ/BQ_auto.xlsx"
)

# ---------------------------------------------------------------------------- #
# Description: Cruncher et génération de bilan qualité -----------------------
# ---------------------------------------------------------------------------- #


## Chargement packages ---------------------------------------------------------

library("rjwsacruncher")
library("JDCruncheR")
library("rjd3workspace")

# Changement chemin -------------------------------------------------------

# Si vous voulez utiliser notre WS, il faut mettre à jour le chemin vers les données brutes

# Chemin pour rendre les ws  ref et auto crunchable
donnees <- normalizePath("Donnees/IPI_nace4.csv")
donnees

# update path
file <- normalizePath("WS/example_1.xml")
ws_example <- jws_open(file)
txt_update_path(
    jws = ws_example,
    new_path = donnees,
    idx_sap = 1
)
save_workspace(jws = ws_example, file = file, replace = TRUE)


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

# attention: faire une copie avant de cruncher (ex: copie to repo cruncher)
# cruncher : mise à jour du workspace
getwd()
cruncher_and_param(
    # Mettre le chemin menant à votre WS
    workspace = "WS/example_1.xml",
    rename_multi_documents = TRUE,
    delete_existing_file = TRUE,
    policy = "complete",
    csv_layout = "vtable",
    short_column_headers = FALSE,
    log_file = "WS/example_1.log"
)


## Lecture pondérations --------------------------------------------------------

POND_NAF4 <- read.csv(
    "Donnees/Ponderations_2024.csv",
    encoding = "UTF-8",
    dec = ","
)
colnames(POND_NAF4)
colnames(POND_NAF4)[1] <- "series"
colnames(POND_NAF4)


## Generation BQ ---------------------------------------------------------------

demetra_path <- "WS/example_1/Output/SAProcessing-1/demetra_m.csv"

BQ_example <- demetra_path |>
    extract_QR() |>
    compute_score(n_contrib_score = 3L) # score_pond= formule


# Si vous avez des pondérations, vous pouvez les ajouter
BQ_example <- BQ_example |>
    add_indicator(POND_NAF4) |>
    weighted_score("ponderation")


class(BQ_example)
str(BQ_example)


# Formule score

# score_pond <- c(
#     qs_residual_sa_on_sa = 30L,
#     f_residual_sa_on_sa = 30L,
#     qs_residual_sa_on_i = 20L,
#     f_residual_sa_on_i = 20L,
#     f_residual_td_on_sa = 30L,
#     f_residual_td_on_i = 20L,
#     oos_mean = 15L,
#     residuals_homoskedasticity = 5L,
#     residuals_skewness = 5L,
#     m7 = 5L,
#     q_m2 = 5L
# )

head(BQ_example$values)

## Extraction score ------------------------------------------------------------

scores_example <- extract_score(BQ_example, weighted_score = TRUE)


## Export ----------------------------------------------------------------------

export_xlsx(
    x = BQ_example,
    file = "BQ/BQ_example.xlsx"
)

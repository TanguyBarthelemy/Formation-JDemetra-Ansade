# Ajustement Saisonnier en R avec JDemetra + -----------------------------------

## Chargement des packages -----------------------------------------------------

library("openxlsx")
library("RJDemetra")
library("rjd3x13")
library("rjd3tramoseats")


## Import des données ----------------------------------------------------------

# Données CSV
ipi <- read.csv2("Projets R/data/IPI_nace4.csv")
str(ipi)
ipi$date <- as.Date(ipi$date, format = "%d/%m/%Y")
ipi[, -1] <- sapply(ipi[, -1], as.numeric)
# View(ipi)

# Donnees excel
ipi_nace4_ind <- read.xlsx(
    file.path("Donnees", "IPI_nace4_ind.xlsx"),
    detectDates = TRUE
)
ipi_nace4_ind$date <- as.Date(ipi_nace4_ind$date)
# View(ipi_nace4_ind)

# Visualisation de la série
ipi[1, "RF3030"]


## Manipulation des données ----------------------------------------------------

# Création d'un objet ts en R
y_raw <- ts(
    ipi[, "RF3030"],
    frequency = 12,
    start = c(1990, 1),
    end = c(2024, 1)
)
y_raw[1]


## CVS -------------------------------------------------------------------------

# En version 2 avec RJDemetra
sa_x13_v2 <- RJDemetra::x13(y_raw, spec = "RSA5c")
sa_ts_v2 <- RJDemetra::tramoseats(y_raw, spec = "RSAfull")

# En version 3 avec rjd3x13
sa_x13_v3 <- rjd3x13::x13(y_raw, spec = "RSA3")
sa_ts_v3 <- rjd3tramoseats::tramoseats(y_raw, spec = "RSAfull")


## Uniquement le pré-ajustement ------------------------------------------------

# En version 2

# Pré-ajustement REG-ARIMA de RJDemetra
regA_v2 <- RJDemetra::regarima_x13(y_raw, spec = "RG5c")
regA_v2

# Pré-ajustement Tramo de RJDemetra
tramo_v2 <- RJDemetra::regarima_tramoseats(y_raw, spec = "TRfull")
tramo_v2


# En version 3

# Pré-ajustement REG-ARIMA de rjd3x13
sa_regarima_v3 <- rjd3x13::regarima(y_raw, spec = "RG3")
summary(sa_regarima_v3)

# Pré-ajustement Tramo de rjd3tramoseats
sa_tramo_v3 <- rjd3tramoseats::tramo(y_raw, spec = "TRfull")


# Uniquement la décomposition ---------------------------------------------

# En version 2, décomposition X11
X11_v2 <- RJDemetra::x13(y_raw, spec = "X11")
X11_v2

# En version 3, décomposition X11 avec rjd3x13
x11_v3 <- rjd3x13::x11(ts = y_raw)

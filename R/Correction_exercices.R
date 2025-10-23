################################################################################
######                        Correction exercices                        ######
################################################################################

# Séquence 1 -------------------------------------------------------------------


# first -------------------------------------------------------------------


## Exercice 2.2
BC <- 13
AC <- 5
AB <- sqrt(BC ** 2 - AC ** 2)

## Exercice 2.3
nom <- "Keihanaikukauakahihuliheekahaunaele"
nchar(nom)

## Exercice 2.4
set.seed(45)
min(sample(x = 1:100, size = 3))

## Exercice 2.5
racine <- sqrt(1:100)

## Exercice 2.6
annees_bissextiles <- seq(from = 2004, to = 2050, by = 4)

|> 

## Exercice 2.7
letters[23]

# Séquence 2 -------------------------------------------------------------------

## Exercice pratique - dplyr ---------------------------------------------------

library("dplyr")

population <- data.frame(
    code = c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J"),
    dep = c(42L, 42L, 7L, 91L, 91L, 7L, 7L, 7L, 42L, 42L),
    nb = c(530, 150542, 24561, 1021312, 552654, 202135,
            88541, 12021, 2100000, 987661)
)

# Tri de la table
population %>%
    arrange(dep, nb)

# Récupération plus petite commune
population %>%
    filter(nb == min(nb), .by = dep)

# Calcul d'un ratio
population %>%
    summarise(ratio = min(nb) / max(nb), .by = dep)


## Exercice pratique - tidyr ---------------------------------------------------

library("tidyr")

# Import de la table
ipi <- read.csv("V:/Formations-Stats/Series-Temporelles-R_Initiation/Data/IPI_nace4.csv", sep = ";") %>%
    mutate(date = as.Date(date, format = "%d/%m/%Y"))

# Filtrage
ipi %>% filter(date >= as.Date("2012-01-01") & date < as.Date("2021-01-01"))

# Calcul plus grande ou petite valeur
ipi %>%
    pivot_longer(cols = -date) %>%
    filter(value == min(value) | value == max(value))

ipi

# -------------

ipi2 <- ipi %>%
    select(date, RF0899) %>%
    mutate(month = month(date)) %>%
    mutate(month_mean = mean(RF0899), .by = month) %>%
    mutate(month_mean = month_mean - mean(month_mean),
           RF0899_sa = RF0899 - month_mean)


ipi3 <- ipi %>% pivot_longer(cols = -date) %>%
    mutate(month = month(date)) %>%
    mutate(month_mean = mean(value), .by = c(month, name)) %>%
    mutate(month_mean = month_mean - mean(month_mean), .by = name) %>%
    mutate(value_sa = value - month_mean) %>%
    pivot_wider(id_cols = date, values_from = value_sa)


library(dplyr)
ipi |>  pivot_longer(cols = -date) 

%>%
  filter(value == min(value) | value == max(value))
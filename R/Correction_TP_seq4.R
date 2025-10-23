
# install.packages(c("zoo", "xts", "tsibble", "lubridate","tsbox", "imputeTS"))

library(dplyr)
library(zoo)
library(xts)
#library(tsibble)
library(tsbox)
library(imputeTS)
library(lubridate)

# ### Exercice 1: Import de data frame et Création d'objets TS
# 
# - importer ipi_nace4.csv du repertoire Data

# importer ipi_nace4.csv du repertoire 
getwd()
ipi <- read.csv2("data/IPI_nace4.csv")
class(ipi)
# quels formatages sont necessaires ?
str(ipi)
ipi$date <- as.Date(ipi$date, format = "%d/%m/%Y")

ipi[, -1] <- sapply(ipi[, -1], as.numeric)
str(ipi)

1:100
a<-ts(1:100)


# creer un objet TS avec la serie RF3030 (attention au start)
y_raw <- ts(ipi[, "RF3030"], start=c(1990,1),frequency = 12)
y_raw
class(y_raw)

### graphique simple en attendant de voir plus sphistiqué
plot.ts(y_raw)
# # ajout autre courbe
lines(1.5*y_raw, col = "red")
plot.ts(1.5*y_raw, col = "red")

# 
# - afficher valeurs janvier 2000 et décembre 2019

# afficher valeurs janvier 2000 et decembre 2019
y_j2000<-window(y_raw,start=c(2000,1),end=c(2000,1))
y_j2000
y_d2019<-window(y_raw,start=c(2019,12),end=c(2019,12))
y_d2019


# avec tsbox
library(tsbox) # voir aide fonction ts_span
j2000<-ts_span(y_raw,start="2000-01-01",end="2000-01-01")
j2000

d2019<-ts_span(y_raw,start="2019-12",end="2019-12")
d2019
 
# avec attribut time
time(y_raw)
y_raw[time(y_raw)==2000.000]
y_raw[time(y_raw)==2019.000+11/12]

# en transformant l'attribut time en date (zoo)
y_raw[zoo::as.Date(time(y_raw))=="2000-01-01"]
y_raw[zoo::as.Date(time(y_raw))=="2019-12-01"]

# afficher les 3 dernières années et les 4 derniers mois
y_3y<-ts_span(y_raw, "-3 years") #dynamique
y_3y
class(y_3y)

y_4m<-ts_span(y_raw, "-4 months") #dynamique
y_4m

y_jan <-y_3y[cycle(y_3y) == 1]
y_jan
class(y_jan) # ! attention

# liste vide pour stocker
liste_ts <- as.list(rep(NA, 12))
liste_ts

start(y_3y)

#afficher date de debut, de fin et frequence des 2 dernieres séries créées
start(y_3y)
class(start(y_3y))
start(y_3y)[1]
end(y_3y)
frequency(y_3y)

ts_summary(y_3y)


# créer un objet TS par type de mois (janvier, février) pour les 3 dernieres années de la série

liste_ts <- as.list(rep(NA, 12))
liste_ts

for(i in 1:12){
  liste_ts[[i]]<-ts(y_3y[cycle(y_3y) == i], start=start(y_3y)[1], frequency=1)
}
#liste_ts
str(liste_ts)
class(liste_ts[[12]])

## Exercice 2

# importer données US_construction.csv du repertoire Data 

# ouvrir fichier et voir que 7 premieres lignes = meta data 

x <- read.csv("V:/Formations-Stats/Series-Temporelles-R_Initiation/Data/US-construction-data.csv", skip = 7)
head(x)
str(x)

# formater la date
library(dplyr)
library(lubridate) #voir cheat sheet
data_const <- x |>
  rename(date = Period) |> mutate(date= lubridate::my(date))

head(data_const)
class(data_const)
str(data_const)

# convertir en objet TS
# solution 1
View(data_const)
ts_c<-ts(data_const[,2],start=c(2002,1), frequency=12)
ts_c

# avec ts box (time value)
# solution 2
ts_const<-ts_ts(data_const)
class(ts_const)

## tester égalité entre ts c et ts const pour verifier que  la conversion marche bien 

all.equal(ts_const, ts_c)

### Exercice 3: Séquences de dates et création de data frames


# creer une serie de dates mensuelles entre fevrier 2019 et novembre 2023

d <- seq(from = as.Date("2019-02-01"), 
         to = as.Date("2023-11-01"), 
         by = "month")
d


# creer un objet TS avec la serie RF3030 (attention au start)
y_raw <- ts(ipi$RF3030, start=c(1990,1),frequency = 12)
y_raw
class(y_raw)

# extraire les valeurs de l'année 2020 de la serie Ipi RF3030 (y_raw)

y_2020 <-tsbox::ts_span(y_raw,"2020") # attention faux
y_2020
y_2020 <-ts_span(y_raw,start="2020-01", end="2020-12")

y_2020<-window(y_raw,start=c(2020,1), end=c(2020,12))
y_2020

# creer un data frame serie Ipi RF3030 pour l'année 2020
df_2020<-ts_data.frame(y_2020) # on utilise la date del'objet TS
View(df_2020)

# creer un data frame avec valeurs Ipi RF3030 de 2020 mais avec date correspondante en 2024

df_2024<- data.frame(
  date=seq(from = as.Date("2024-01-01"), 
           to = as.Date("2024-12-01"), 
           by = "month"),
  ipi=y_2020
)
View(df_2024)

df_2020<- data.frame(
  date=seq(from = as.Date("2020-01-01"), 
           to = as.Date("2020-12-01"), 
           by = "month"),
  ipi=y_2020
)
View(df_2020)

df_2020<- data.frame(
  date=as.Date(time(y_2020)),
  ipi=y_2020
)
View(df_2020)

### Exercice 4: Serie temporelle avec valeurs ad hoc 

# Option 1 : utiliser la fonction `window()`

ts_zeros <- ts(0, start = 2000, end = 2020, frequency = 12)
ts_zeros
window(ts_zeros, start = c(2009, 4), end = c(2009, 4)) <- 1



#Option 2 : utiliser `time()` directement

ts_zeros <- ts(0, start = 2000, end = 2020, frequency = 12)
ts_zeros[time(ts_zeros)==2009+3/12]<-1

ts_zeros[zoo::as.Date(time(ts_zeros))=="2009-04-01"]<-1
ts_zeros 

### Exercice 5: Jointures 

# créer le TS correspondant à la serie ipi RF1011
y_1011 <- ts(ipi[, "RF1011"], start=c(1990,1),frequency = 12)
y_1011
end(y_1011)

# créer un mts avec RF3030 et RF1011 entre 2020 et 2023

y_raw1<-window(y_raw,start=c(2020,1),end=c(2023,12))

y_1011_1<-window(y_1011,start=c(2020,1),end=c(2023,12))

mts_u<-ts.union(y_raw1,y_1011_1)
mts_u
class(mts_u)

# créer UNE serie ayant les valeurs de RF3030 entre 2010 et 2020
# et les valeurs de RF1011 entre 2021 et la fin de la serie 
y_raw1<-window(y_raw,start=c(2010,1),end=c(2020,12))
y_raw1

y_1011_1<-window(y_1011,start=c(2020,1),end=c(2023,12))
y_1011_1

ts_u<-ts_bind(y_raw1,y_1011_1)
ts_u

ts_summary(ts_c(y_raw1,y_1011_1,ts_u))
df_u<-ts_df(ts_c(y_raw1,y_1011_1,ts_u))
View(df_u) # format long 

df_u_wide<-ts_wide(df_u)
View(df_u_wide)
# retour 

df_u_long<-ts_long(df_u_wide)
View(df_u_long)

### Exercice 6: Taux de variation 

# ecrire une fonction taux de variation par rapport à la période précedente
# mensuelle ou trimestrielle 

ts1<-ts(100+(20:30), start=c(2024,1), frequency = 4)
ts1
### package stats
ev <- function(x){
  result <- (x/stats::lag(x, k = -1) - 1) * 100
  return(result)
}
ev(ts1)

# Ou de manière équivalente :
ev2 <- function(x){
  # Attention ici c'est bien k = 1 dans la fonction diff
  # et k = -1 dans la fonction lag
  result <- (diff(x, lag = 1) /lag(x, k = -1)) * 100
  return(result)
}

### package dplyr : sur un vecteur

tx_cr <- function(v) {
  w <- (v - lag(v)) / lag(v) * 100
  return(w)
}
tx_12 <- function(v) {
  w <- (v - lag(v, 12)) / lag(v, 12) * 100
  return(w)
}
tx_cr(as.vector(ts1))

### package tsbox: fonctions directes 

ts1 <-ts(1:12, start=c(2024,1), frequency = 12)
ts_diff(ts1)
ts_pc(ts1)
ts_pcy(ts1)

### Exercice 7: Fonctions statistiques 


# calculer moyenne/ mediane/ecart type de la serie IPI RF3030
mean(y_raw)
median(y_raw)
sd(y_raw)

# calculer moyenne annuelle / trimestrielle de la serie IPI RF3030
# en utilisant le package xts
# stocker les resultats dans un data frame
library(xts) # voir cheat sheet
moy_an <- apply.yearly(as.xts(y_raw), mean)
moy_an
class(moy_an)
moy_an_mts<-ts_ts(moy_an)
class(moy_an_mts)
df_moy_an<-ts_df(moy_an)
ts_moy_an<-ts_ts(moy_an)
View(df_moy_an) # arranger les dates

moy_q <- apply.quarterly(as.xts(y_raw), mean)
moy_q
class(moy_q)
moy_q_mts<-ts_ts(moy_q)
class(moy_q_mts)
View(moy_q) 

### Exercice 8: Fonctions statistiques sur tsibble  


## transformer le mts avec RF3030 et RF1011 entre 2020 et 2023 en tsibble
library(tsibble)
mts_u
tsib_u<-as_tsibble(mts_u)
class(tsib_u)
View(tsib_u) # empilement
table(tsib_u$key)
str(tsib_u)
#format de la date 
class(tsib_u$index) # date en year month 


# calculer les moyennes timestrielles de RF3030 et RF1011
# Indice: il faut utiliser à la fois group_by_key()` (identifiant série)
# et `index_by` qui permet de regrouper des dates  
#
moy_t<-tsib_u |> 
  group_by_key() |>  
  index_by(date = ~ yearquarter(.)) |> 
  summarise(moyenne_t = mean(value))

View(moy_t)

# À l'aide du package `lubridate`, extraire toutes les données du mois de janvier et 
# juillet du tsibble precedent (construire une variable mois)

tsib_u<-tsib_u |>  mutate(month = lubridate::month(index))
View(tsib_u)

tsib_u2 <-tsib_u |> 
  filter(month(index) %in% c(1,7))


View(tsib_u2)

#À l'aide du package `lubridate`, extraire toutes les données à partir de aout 2020
# utiliser `tsibble::make_yearmonth()` 

make_yearmonth(2020,8)
class(make_yearmonth(2020,8)) # le format date du tsibble

tsib_u3<-tsib_u |> 
  filter(index >= make_yearmonth(2020,8)) #variable date = index 
View(tsib_u3)



### Exercice 9: Valeurs manquantes 


serie_avec_NA <- ts(c(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0, 0, 0, 0, 
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NA, 
                      NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 
                      NA, NA, NA, NA, NA, NA, NA, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
                      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, NA, NA, NA, NA, NA, NA, 
                      NA, NA, NA, NA, NA, NA), start = 2000, frequency = 12)
serie_avec_NA

# Reperer les positions des valeurs manquantes

p_na<-which(is.na(serie_avec_NA))
p_na

# Enlever les valeurs manquantes au début de la série

etape_1 <- zoo::na.trim(serie_avec_NA, sides = "left")
etape_1

# Interpoler de manière linéaire les valeurs manquantes entre les 0 et les 1

etape_2 <- na.approx(etape_1, na.rm = FALSE) # na.rm = FALSE : on veut garder les NA de la fin
etape_2


# Remplacer les valeurs manquantes à la fin de la série par la dernière valeur observée
etape_3 <- na_locf(etape_2)
etape_3







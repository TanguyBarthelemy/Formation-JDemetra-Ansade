# Navigation dans les objets ---------------------------------------------------

# En version 2
# V2 avec x13 et tramoseats
sa_x13_v2 # Naviguer avec $...

class(sa_ts_v2$final$series)
sa_ts_v2$final$forecasts

# X13 en version 3

# sa_x13_v3$result$preadjust
# sa_x13_v3$result$decomposition
sa_x13_v3$result$final$d11final
sa_x13_v3$result$mstats
sa_x13_v3$result$diagnostics

plot(y_raw, col = "red")
lines(sa_x13_v3$result$final$d11final, col = "blue")

sa_x13_v3$estimation_spec$x11
sa_x13_v3$estimation_spec$benchmarking

sa_x13_v3$result_spec
sa_x13_v3$user_defined

# Tramo seats en version 3
print(sa_ts_v3)
summary(sa_ts_v3)

sa_ts_v3$result

sa_ts_v3$result$preprocessing
sa_ts_v3$result$decomposition
sa_ts_v3$result$final
sa_ts_v3$result$diagnostics

sa_ts_v3$estimation_spec

sa_ts_v3$estimation_spec$tramo
sa_ts_v3$estimation_spec$seats
sa_ts_v3$estimation_spec$benchmarking

sa_ts_v3$result_spec

sa_ts_v3$user_defined


# Version 2 : display of Main Results table (from GUI)
sa_x13_v2$final$series #y, sa,t,s,i
sa_x13_v2$final$forecasts

# Version 3
sa_x13_v3$result
sa_x13_v3$estimation_spec
sa_x13_v3$result_spec
sa_x13_v3$user_defined

# final seasonally adjusted series
sa_x13_v3$result$final$d11final

### Pre adjustment series

# Version 2
y_lin <- sa_x13_v2$regarima$model$effects[, 1]

#forecast accessible only via user defined output (cf below)

# Version 3: "x11 names" : preadjustement effets as stored in the A table
# see doc chap x11 for names

sa_x13_v3$result$preadjust

# Decomposition (no preadjustment effect)
# Version 3
sa_x13_v3$result$decomposition$d5 #tables from D1 to D13


# Version 2
print(sa_x13_v2)
sa_x13_v2$decomposition$mstats
sa_x13_v2$decomposition$s_filter
sa_x13_v2$decomposition$t_filter

# version 3 (more diagnostics available by default)
print(sa_x13_v2)
sa_x13_v3$result$diagnostics$td.ftest.i

# User defined output
# Version 2
user_defined_variables("X13-ARIMA")
user_defined_variables("TRAMO-SEATS")

# exemple doc
y <- ipi_c_eu[, "FR"]
user_defined_variables("X13-ARIMA")
m <- x13(
    y,
    "RSA5c",
    userdefined = c("decomposition.b1", "ycal", "residuals.kurtosis")
)
m$user_defined$decomposition.b1 # serie linearisee
m$user_defined$ycal
m$user_defined$residuals.kurtosis
user_defined_variables("TRAMO-SEATS")
m <- tramoseats(
    y,
    "RSAfull",
    userdefined = c("ycal", "variancedecomposition.seasonality")
)
m$user_defined$ycal
m$user_defined$variancedecomposition.seasonality


# Version 3: more specific functions
tramoseats_full_dictionary()
x13_full_dictionary()


# version 3
ud <- x13_full_dictionary()[15:17] #b series
ud
sa_x13_v3_UD <- rjd3x13::x13(y_raw, "RSA5c", userdefined = ud)
sa_x13_v3_UD$user_defined #names

# retrieve the object
sa_x13_v3_UD$user_defined$likelihood.bic2


## Plots in v3

library("ggdemetra3")

# Plot of the final decomposition
plot(sa_x13_v3)
# avec le format autoplot
autoplot(sa_x13_v3)

# Plot SI ratios
siratioplot(sa_x13_v3)
# avec le format autoplot
ggsiratioplot(sa_x13_v3)

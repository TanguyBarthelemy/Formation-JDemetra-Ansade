# Specification customization --------------------------------------------------

library("rjd3toolkit")
library("RJDemetra")

## Version 2 -------------------------------------------------------------------

## (att: bien preciser le package ) pour les fonctions qui ont un nom identique

#changing estimation span, imposing additive model and
# adding user defined outliers

#  first create a new spec modifying the previous one
spec_1 <- RJDemetra::x13_spec("RSA3") # from a default spec
#or
spec_1 <- RJDemetra::x13_spec(sa_x13_v2) # extracting from a model


spec_2 <- RJDemetra::x13_spec(
    spec_1,
    estimate.from = "2015-01-01",
    usrdef.outliersEnabled = TRUE,
    usrdef.outliersType = c("LS", "AO"),
    usrdef.outliersDate = c("2008-10-01", "2018-01-01"),
    transform.function = "None"
) # additive model

# here the reg-arima model will be estimated from  "2004-01-01"
# the decomposition will be run on the whole span

# Estimation with new spec  (new sa processing)
sa_x13_v2_2 <- RJDemetra::x13(y_raw, spec_2)
# print spec and see
spec_2

sa_x13_v2_2$regarima$specification$regression$userdef$outliers


## Version 3 -------------------------------------------------------------------

# start with default spec

spec_1 <- x13_spec("RSA3")
#or start with existing spec (no extraction function needed)

# ##### set basic : series span for the estimation
x13_spec_d <- rjd3toolkit::set_basic(
    spec_1,
    type = "From",
    d0 = "2014-01-01",
    preliminary.check = TRUE,
    preprocessing = TRUE
)


print(x13_spec_d)
# check results
m <- rjd3x13::x13(y_raw, x13_spec_d)
start(m$result$final$d11final)


## define span until d1, excluded
x13_spec_d <- set_basic(
    x13_spec_d,
    type = "From",
    d0 = "2014-01-01",
    preliminary.check = TRUE,
    preprocessing = TRUE
)

y_raw
print(x13_spec_d)
# check results
m <- rjd3x13::x13(y_raw, x13_spec_d)
m$result$final$d11final
start(m$result$final$d11final)
end(m$result$final$d11final)

## Last observation (dynamic choice)
x13_spec_d <- set_basic(
    x13_spec_d,
    type = "Last",
    n1 = 60,
    preliminary.check = TRUE,
    preprocessing = TRUE
)

print(x13_spec_d)
# check results
m <- rjd3x13::x13(y_raw, x13_spec_d)
start(m$result$final$d11final)
end(m$result$final$d11final)

# Excluding : N first and P Last obs
x13_spec_d <- set_basic(
    x13_spec_d,
    type = "Excluding",
    n0 = 5,
    n1 = 3,
    preliminary.check = TRUE,
    preprocessing = TRUE
)


print(x13_spec_d)
# check results
m <- rjd3x13::x13(y_raw, x13_spec_d)
start(m$result$final$d11final)
end(m$result$final$d11final)


# set estimate : length for the arima model only, can be combined with series span
x13_spec_d <- rjd3x13::x13_spec("rsa3") # re init
x13_spec_d <- rjd3toolkit::set_estimate(x13_spec_d, "From", d0 = "2015-01-01")


print(x13_spec_d)
# check results
m <- rjd3x13::x13(y_raw, x13_spec_d)
start(m$result$final$d11final)
end(m$result$final$d11final)


## set  transform : log or not
##
x13_spec_d <- rjd3toolkit::set_transform(
    x13_spec_d,
    fun = "Log",
    outliers = TRUE
) # when auto choice: big outlier detection for test: new v3 feature


print(x13_spec_d)
# check results
m <- rjd3x13::x13(y_raw, x13_spec_d)
start(m$result$final$d11final)
end(m$result$final$d11final)

## Modify automatic outlier detection parameters
x13_spec_d <- rjd3toolkit::set_outlier(
    x13_spec_d,
    span.type = "From",
    d0 = "2012-01-01",
    outliers.type = c("LS", "AO"), # LS are excluded
    critical.value = 5,
    tc.rate = 0.85
)


print(x13_spec_d)
# check results
m <- rjd3x13::x13(y_raw, x13_spec_d)
start(m$result$final$d11final)
end(m$result$final$d11final)

# Modify automatic arima model estimation parameters (not advised to tweak this)
x13_spec_d <- set_automodel(
    x13_spec_d,
    enabled = TRUE, # automatic detection
    cancel = 0.06,
    ub1 = 1.05,
    ub2 = 1.15,
    reducecv = 0.15,
    ljungboxlimit = 0.96,
    tsig = 1.5,
    ubfinal = 1.06,
    checkmu = FALSE,
    balanced = TRUE
)

# Customized arima model specification
x13_spec_d <- rjd3x13::x13_spec("rsa3") # re init
# disable automatic arima modelling
x13_spec_d <- set_automodel(x13_spec_d, enabled = FALSE)
# customize arima model
x13_spec_d <- set_arima(
    x13_spec_d,
    mean = 0.2,
    mean.type = "Fixed",
    p = 1,
    d = 2,
    q = 0,
    bp = 1,
    bd = 1,
    bq = 0,
    coef = c(0.6, 0.7),
    coef.type = c("Initial", "Fixed")
)


print(x13_spec_d)
# check results
m <- rjd3x13::x13(y_raw, x13_spec_d)
summary(m)


# ### set benchmarking
x13_spec_d <- rjd3toolkit::set_benchmarking(
    x13_spec_d,
    enabled = TRUE,
    target = "ORIGINAL",
    rho = 0.8,
    lambda = 0.5,
    forecast = FALSE,
    bias = "None"
)
# output will have to be retrieved in user defined output
userdefined_variables_x13() # list of items
sa_x13_d <- rjd3x13::x13(y_raw, x13_spec_d, userdefined = "benchmarking.result")
y_bench <- sa_x13_d$user_defined$benchmarking.result
plot(y_bench)
# creating a spec from default
x13_spec_d <- rjd3x13::x13_spec("rsa3")


### set_tradingdays
# JD+ built in regressors, no national calendar unless defined)
x13_spec_d <- rjd3toolkit::set_tradingdays(
    x13_spec_d,
    option = "WorkingDays",
    test = "None",
    coef = 0,
    # coef.type = c("Fixed", "Estimated", "Fixed"),
    leapyear = "LeapYear"
)

print(x13_spec_d)
# check results
m <- rjd3x13::x13(y_raw, x13_spec_d)

summary(m)

m$result$preprocessing$description$preadjustment

m$result$preprocessing$estimation$parameters$description

# ### set_easter
x13_spec_d <- rjd3x13::x13_spec("rsa3") # re init
x13_spec_d <- set_easter(x13_spec_d, enabled = TRUE, duration = 12)


print(x13_spec_d)
# check results
m <- rjd3x13::x13(y_raw, x13_spec_d)
m$result$preprocessing$description

### Pre specified outliers
x13_spec_d <- rjd3x13::x13_spec("rsa3") # re init
# Pre-specified outliers
x13_spec_d <- rjd3toolkit::add_outlier(
    x13_spec_d,
    type = c("AO", "LS"),
    date = c("2020-03-01", "2020-04-01")
)


print(x13_spec_d)
# check results
m <- rjd3x13::x13(y_raw, x13_spec_d)


# Adding a ramp
x13_spec_d <- rjd3toolkit::add_ramp(
    x13_spec_d,
    start = "2021-01-01",
    end = "2021-12-01"
)

print(x13_spec_d)
# check results
m <- rjd3x13::x13(y_raw, x13_spec_d)

# auxiliary regressors
m$result$preprocessing$estimation$X

### X11 parameters

spec_2 <- rjd3x13::set_x11(spec_1, henderson.filter = 13)
rjd3x13::x13(y_raw, spec_2)

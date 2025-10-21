library("rjd3toolkit")
library("dplyr")
library("rjd3production")

fetes <- openxlsx::read.xlsx(
    xlsxFile = "C:\\Users\\INSEE_User\\Documents\\Projets R\\Formation_CVS_MRT___Données_nationales_\\rim_calendar.xlsx",
    sheet = "Holidays",
    startRow = 3, detectDates = TRUE
) |>
    filter(!Description %in% c("New year", "Independence Day")) |>
    mutate(date = as.character(Observance.date))

cal_MRT <- national_calendar(c(
    list(
        special_day("NEWYEAR"),
        fixed_day(month = 11, day = 28)
    ),
    lapply(fetes$date, single_day)
))

regs_cjo_MRT_t <- create_insee_regressors(
    start = c(2010, 1),
    frequency = 4,
    length = 80,
    cal = cal_MRT
)

regs_cjo_MRT_m <- create_insee_regressors(
    start = c(2010, 1),
    frequency = 12,
    length = 240,
    cal = cal_MRT
)

write.table(regs_cjo_MRT_t, file = "C:/Users/INSEE_User/Documents/Projets R/Formation-JD+-Ansade/Donnees/reg_cjo_MRT_t.csv", sep = ";", quote = F, row.names = F)
write.table(regs_cjo_MRT_m, file = "C:/Users/INSEE_User/Documents/Projets R/Formation-JD+-Ansade/Donnees/reg_cjo_MRT_m.csv", sep = ";", quote = F, row.names = F)

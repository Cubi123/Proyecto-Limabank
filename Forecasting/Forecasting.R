set.seed(111)
library(tidyverse)
library(lubridate)
library(xts)
library(forecast)
library(corrplot)
library(timetk)
library(tidyquant)
library(xgboost) 
library(caret) 
library(skimr)
library(tidymodels)
library(pander)


setwd("C:/Users/Christian/Desktop/Ciclo Cubi/Temas IOP/Proyecto-Limabank/Data")

clientes_limabank <- read_csv("Clientes_Limabank.csv")

datos_agencia <- read_csv("Datos_Agencia.csv")%>%
  select(-GRUPO)

dates_agencia <- seq.Date(from=dmy("01-01-2014"),
                          to=dmy("01-03-2019"),by="month")

datos_agencia$INDICADOR <- c("ArribosTotales","TiempoEspera","TiempoAtencion",
                             "StaffTurnoMañana","StaffTurnoTarde","Ventas_1",
                             "Ventas_2","Ventas_3","Ventas_4")


xts_agencia<-datos_agencia%>%
  gather(key = "Date", value = value, 2:ncol(datos_agencia)) %>% 
  spread_(key = names(datos_agencia)[1],value = 'value')%>%
  select(-Date)%>%
  xts(.,order.by = dates_agencia)

skim(coredata(xts_agencia))

xts_agencia$Ventas_2 <- na.approx(xts_agencia$Ventas_2)
xts_agencia$Ventas_3 <- na.approx(xts_agencia$Ventas_3)
xts_agencia$ArribosTotales <- na.approx(xts_agencia$ArribosTotales)

autoplot(xts_agencia[,c("StaffTurnoMañana","StaffTurnoTarde")])

autoplot(xts_agencia[,c("Ventas_1","Ventas_2","Ventas_3","Ventas_4")])

autoplot(xts_agencia[,c("TiempoEspera","TiempoAtencion")])

autoplot(xts_agencia[,c("ArribosTotales")])


fit_arima <- auto.arima(xts_agencia$ArribosTotales)
summary(fit_arima)
checkresiduals(fit_arima)
autoplot(forecast(fit_arima,h=9))

fit_ets <- ets(xts_agencia$ArribosTotales)
summary(fit_ets)
checkresiduals(fit_ets)
autoplot(forecast(fit_ets,h=9),ylab="")

simulate(fit_arima,future = TRUE,seed = 3)

cor.mtest <- function(mat, ...) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat<- matrix(NA, n, n)
  diag(p.mat) <- 0
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- cor.test(mat[, i], mat[, j], ...)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
    }
  }
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
  p.mat
}

p.mat <- cor.mtest(xts_agencia)
corr_ts <-cor(xts_agencia)

col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(corr_ts,type="upper", tl.srt=45,tl.col="black",
         diag=FALSE,addCoef.col = "black",
         p.mat = p.mat, sig.level = 0.01, insig = "blank",
         method="color", col=col(200))


TiempoEspera <- xts_agencia$TiempoEspera

fit_tiempo_espera <- auto.arima(xts_agencia$TiempoEspera,
                                xreg=xts_agencia[,-5])

summary(fit_tiempo_espera)

ggtsdisplay(arima.errors(fit_tiempo_espera),
              main="ARIMA errors")

ggtsdisplay(residuals(fit_tiempo_espera),
            main="ARIMA residuals")

agencia <- as.data.frame(coredata(xts_agencia))

data <- tk_augment_timeseries_signature(xts_agencia)

fit_lm_tiempo_espera <- stats::lm(TiempoEspera~.,data)
fit_lm_tiempo_espera

anova(fit_lm_tiempo_espera)

fit_lm <- lm(TiempoEspera~ArribosTotales+StaffTurnoTarde+half,data)

anova(fit_lm)
library(earth)

m1 <- earth(TiempoEspera~ArribosTotales+StaffTurnoTarde+half,data=data,
      nfold=10, ncross=30,varmod.method="lm",keepxy=TRUE)

summary(m1)
plot(m1)
plot(m1, which=1, col.rsq=0)
evimp(m1, trim=FALSE)
plotmo(m1)

set.seed(111)

nsimulations <- 1000
abril <- rep(0,nsimulations)
mayo <- rep(0,nsimulations)
junio <- rep(0,nsimulations)
for (i in 1:nsimulations){
  test_data <- data.frame(ArribosTotales =c(simulate(fit_arima,future = TRUE,nsim = 3)),
                          StaffTurnoTarde=6,
                          half=1)
  
  tiemposEspera_predicted <- predict(m1,test_data)
  abril[i] <- tiemposEspera_predicted[1]
  mayo[i] <- tiemposEspera_predicted[2]
  junio[i] <-tiemposEspera_predicted[3]
}

par(mfrow=c(1,3))
hist(abril)
hist(mayo)
hist(junio)

autoplot(data[,c("TiempoEspera","StaffTurnoTarde","StaffTurnoMañana")])

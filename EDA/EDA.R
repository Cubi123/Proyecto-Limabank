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

clientes_limabank <- read_csv("Clientes_Limabank.csv")

datos_agencia <- read_csv("Datos_Agencia.csv")%>%
  select(-GRUPO)

dates_agencia <- seq.Date(from=dmy("01-01-2014"),
                          to=dmy("01-03-2019"),by="month")

datos_agencia$INDICADOR <- c("ArribosTotales","TiempoEspera","TiempoAtencion",
                             "StaffTeleferico_TM","StaffTeleferico_TT","Ventas_1",
                             "Ventas_2","Ventas_3","Ventas_4")

xts_agencia<-datos_agencia%>%
  gather(key = "Date", value = value, 2:ncol(datos_agencia)) %>% 
  spread_(key = names(datos_agencia)[1],value = 'value')%>%
  select(-Date)%>%
  xts(.,order.by = dates_agencia)

autoplot(xts_agencia[,c("StaffTeleferico_TM","StaffTeleferico_TT")])

autoplot(xts_agencia[,c("Ventas_1","Ventas_2","Ventas_3","Ventas_4")])

xts_agencia$Ventas_2 <- na.approx(xts_agencia$Ventas_2)
xts_agencia$Ventas_3 <- na.approx(xts_agencia$Ventas_3)

autoplot(xts_agencia[,c("TiempoEspera","TiempoAtencion")])

autoplot(xts_agencia[,c("ArribosTotales")])

xts_agencia$ArribosTotales <- na.approx(xts_agencia$ArribosTotales)

acf(xts_agencia$ArribosTotales)

fit_arima <- auto.arima(xts_agencia$ArribosTotales)
summary(fit_arima)
checkresiduals(fit_arima)
autoplot(forecast(fit_arima,h=9))

fit_ets <- ets(xts_agencia$ArribosTotales)
summary(fit_ets)
checkresiduals(fit_ets)
autoplot(forecast(fit_ets,h=9),ylab="")


forecast(fit_arima,h=9)
arima.sim(model = list(order=c(0,1,1),ma=0.3816),3)

fit_arima


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

fit_lm_tiempo_espera <- lm(TiempoEspera~.,agencia)
anova(fit_lm_tiempo_espera)


data <- tk_augment_timeseries_signature(xts_agencia)

ymd(index(xts_agencia))

class(xts_agencia)



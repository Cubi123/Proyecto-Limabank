library(tidyverse)
library(clustMD)

encode_categorical <- function(x, order = unique(x)) {
  x <- as.numeric(factor(x, levels = order, exclude = NULL))
  x
}

data <- read_csv("LimaBank_Data_Grupo1.csv")

data_clean<- data%>%
  na.omit()%>%
  select(-CODIGO_CLIENTE,-EDAD_2)


continuos_variables <- c ('INGRESO','EDAD','SBS_DEUTOTAL','Banco1_DEUTOTAL',
                     'Banco2_DEUTOTAL','Banco3_DEUTOTAL','Banco4_DEUTOTAL',
                     'OTROS_DEUTOTAL','CANTIDAD_PRODUCTOS')

binary_variables <- c('FORMAL','FLG_SBS_201909','FLG_MD_NEGATIVO',
                      'FLG_DEUDASBS','FLG_SEGUROS','FLG_ACTIVOS',
                      'FLG_PASIVOS','FLG_INVERSION','FLG_PASIV_INV')

ordinal_variables <- c('EDU','DIGITAL','TIPNIVELEDUCACIONAL',
                       'PERFIL_VINCULACION','SEMENTO_RIESGO')

nominal_variables <- c('TIPESTCIVIL','CODPAISNACIONALIDAD'
                       ,'DESTIPPROVINCIA','DIGITALIDAD')

orden_nivel_educacion <- c("PRI","SEC","TEC","SUP","BAC","LIC","TIT","MAE","DOC")
orden_vinculacion <- c("1. NADA VINCULADO","2. POCO VINCULADO",
                       "3. MEDIO VINCULADO","4. VINCULADO","5. MUY VINCULADO")
orden_riesgo <- c("A","B","C","D","E")

data_clean$EDU <- as.numeric(factor(data_clean$EDU))
data_clean$DIGITAL <-as.numeric(factor(data_clean$DIGITAL))
data_clean$TIPNIVELEDUCACIONAL <- encode_categorical(data_clean$TIPNIVELEDUCACIONAL,orden_nivel_educacion)
data_clean$PERFIL_VINCULACION <- encode_categorical(data_clean$PERFIL_VINCULACION,orden_vinculacion)
data_clean$SEMENTO_RIESGO <- encode_categorical(data_clean$SEMENTO_RIESGO,orden_riesgo)

data_clean$TIPESTCIVIL <- encode_categorical(data_clean$TIPESTCIVIL)
data_clean$CODPAISNACIONALIDAD <- encode_categorical(data_clean$CODPAISNACIONALIDAD)
data_clean$DESTIPPROVINCIA <- encode_categorical(data_clean$DESTIPPROVINCIA)
data_clean$DIGITALIDAD <- encode_categorical(data_clean$DIGITALIDAD)

data_clean_ordered <- data_clean[,c(continuos_variables,binary_variables,ordinal_variables,nominal_variables)]
data_clean_ordered[,10:18] <- data_clean_ordered[,10:18] + 1
data_clean_ordered[, 1:9] <- scale(data_clean_ordered[, 1:9])

res<-clustMDparallel(data_clean_ordered,G = 5, CnsInd=9,OrdIndx=23,
                     Nnorms=20000, MaxIter=500, model=c("EVI"),
                     store.params=FALSE,scale=TRUE,startCL="kmeans",
                     autoStop=TRUE,ma.band=30, stop.tol=0.0001)

res2 <- clustMD(data_clean_ordered,G = 5, CnsInd=9,OrdIndx=23,
                Nnorms=20000, MaxIter=500, model="EVI")


is.na(data_clean_ordered)

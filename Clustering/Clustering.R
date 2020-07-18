library(tidyverse)
library(clustMD)
library(skimr)

encode_categorical <- function(x, order = unique(x)) {
  x <- as.numeric(factor(x, levels = order, exclude = NULL))
  x
}

columna_dummy <- function(df, columna) {
  df %>% 
    mutate_at(columna, ~paste(columna, eval(as.symbol(columna)), sep = "_")) %>% 
    mutate(valor = 1) %>% 
    spread(key = columna, value = valor, fill = 0)
}

crear_dummies <- function(df, nombres) {
  map(c(nombres), columna_dummy, df = df) %>% 
    reduce(inner_join) %>% 
    select(-c(nombres))
}

data <- read_csv("LimaBank_Data_Grupo1.csv")

data_clean<- data%>%
  select(-CODIGO_CLIENTE,-EDAD_2)

skim(data_clean)

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

orden_nivel_educacion <- c("ANA","NDI","PRI","SEC","FAR","TEI","TEC","SUP","BAC","LIC","TIT","MAE","DOC")
orden_vinculacion <- c("1. NADA VINCULADO","2. POCO VINCULADO",
                       "3. MEDIO VINCULADO","4. VINCULADO","5. MUY VINCULADO")
orden_riesgo <- c("A","B","C","D","E")

missing_continuos <- c('Banco1_DEUTOTAL','SBS_DEUTOTAL',
                       'Banco2_DEUTOTAL','Banco3_DEUTOTAL','Banco4_DEUTOTAL',
                       'OTROS_DEUTOTAL','CANTIDAD_PRODUCTOS')

index_na <- is.na(data_clean$SBS_DEUTOTAL)
data_clean$SBS_DEUTOTAL[index_na] <- mean(data_clean$SBS_DEUTOTAL[!index_na])

index_na <- is.na(data_clean$Banco1_DEUTOTAL)
data_clean$Banco1_DEUTOTAL[index_na] <- mean(data_clean$Banco1_DEUTOTAL[!index_na])

index_na <- is.na(data_clean$Banco2_DEUTOTAL)
data_clean$Banco2_DEUTOTAL[index_na] <- mean(data_clean$Banco2_DEUTOTAL[!index_na])

index_na <- is.na(data_clean$Banco3_DEUTOTAL)
data_clean$Banco3_DEUTOTAL[index_na] <- mean(data_clean$Banco3_DEUTOTAL[!index_na])

index_na <- is.na(data_clean$Banco4_DEUTOTAL)
data_clean$Banco4_DEUTOTAL[index_na] <- mean(data_clean$Banco4_DEUTOTAL[!index_na])

index_na <- is.na(data_clean$OTROS_DEUTOTAL)
data_clean$OTROS_DEUTOTAL[index_na] <- mean(data_clean$OTROS_DEUTOTAL[!index_na])

index_na <- is.na(data_clean$CANTIDAD_PRODUCTOS)
data_clean$CANTIDAD_PRODUCTOS[index_na] <- mean(data_clean$CANTIDAD_PRODUCTOS[!index_na])


data_clean$EDU <- as.numeric(factor(data_clean$EDU))
data_clean$DIGITAL <-as.numeric(factor(data_clean$DIGITAL))
data_clean$TIPNIVELEDUCACIONAL <- encode_categorical(data_clean$TIPNIVELEDUCACIONAL,orden_nivel_educacion)
data_clean$PERFIL_VINCULACION <- encode_categorical(data_clean$PERFIL_VINCULACION,orden_vinculacion)
data_clean$SEMENTO_RIESGO <- encode_categorical(data_clean$SEMENTO_RIESGO,orden_riesgo)

cod_peru_ven <- data_clean$CODPAISNACIONALIDAD=="PER" | data_clean$CODPAISNACIONALIDAD=="VEN"
data_clean$CODPAISNACIONALIDAD[!cod_peru_ven] <- "OTRO"

data_clean_dummy <- crear_dummies(data_clean, nominal_variables)  


#data_clean_ordered <- data_clean[,c(continuos_variables,binary_variables,ordinal_variables,nominal_variables)]
#data_clean_ordered[,10:18] <- data_clean_ordered[,10:18] + 1
#data_clean_ordered[, 1:9] <- scale(data_clean_ordered[, 1:9])

##res<-clustMDparallel(data_clean_ordered,G = 5, CnsInd=9,OrdIndx=23,
##                     Nnorms=20000, MaxIter=500, model=c("EVI"),
##                     store.params=FALSE,scale=TRUE,startCL="kmeans",
##                     autoStop=TRUE,ma.band=30, stop.tol=0.0001)

res2 <- clustMD(data_clean_ordered,G = 5, CnsInd=9,OrdIndx=23,
                Nnorms=20000, MaxIter=500, model="EVI")


is.na(data_clean_ordered)

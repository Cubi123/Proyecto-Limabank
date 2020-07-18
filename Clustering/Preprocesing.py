# %% codecell
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

data = pd.read_csv("Data/LimaBank_Data_Grupo1.csv")
backup= data.copy(deep=True)

#Dropenando vacios
to_drop=['CODIGO_CLIENTE',
         'TIPESTCIVIL',
         'CODPAISNACIONALIDAD',
         'INGRESO',
         'EDAD',
         'EDU',
         'FORMAL',
         'DIGITAL',
         'DESTIPPROVINCIA',
         'EDAD_2',
         'TIPNIVELEDUCACIONAL',
         'FLG_SBS_201909',
         'FLG_MD_NEGATIVO',
         'PERFIL_VINCULACION',
         'FLG_DEUDASBS',
         'DIGITALIDAD',
         'CANTIDAD_PRODUCTOS',
         'FLG_SEGUROS',
         'FLG_ACTIVOS',
         'FLG_PASIVOS',
         'FLG_INVERSION',
         'FLG_PASIV_INV',
         'SEMENTO_RIESGO']

data.dropna(axis=0,inplace=True,subset=to_drop)

#elimino EDAD_2
data.drop("EDAD_2",axis=1,inplace=True)

#CANTIDAD_PRODUCTOS  normalizar
# data["CANTIDAD_PRODUCTOS"] = (data["CANTIDAD_PRODUCTOS"] -data["CANTIDAD_PRODUCTOS"].mean())/

# %% codecell
from  Clustering.setup import *
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import missingno as msno

data = pd.read_csv("Data/LimaBank_Data_Grupo1.csv")

# %% codecell
#se descartó (no eliminó) codigo de clientes por no ser util para el análisis
variables_continuas=['INGRESO',
                     'EDAD',
                     'EDAD_2',
                     'SBS_DEUTOTAL',
                     'Banco1_DEUTOTAL',
                     'Banco2_DEUTOTAL',
                     'Banco3_DEUTOTAL',
                     'Banco4_DEUTOTAL',
                     'OTROS_DEUTOTAL',]

variables_discretas=['FORMAL',
                     'DIGITAL',
                     'FLG_SBS_201909',
                     'FLG_MD_NEGATIVO',
                     'FLG_DEUDASBS',
                     'CANTIDAD_PRODUCTOS',
                     'FLG_SEGUROS',
                     'FLG_ACTIVOS',
                     'FLG_PASIVOS',
                     'FLG_INVERSION',
                     'FLG_PASIV_INV',]

variables_ordinales=['EDU',
                     'TIPNIVELEDUCACIONAL',
                     'PERFIL_VINCULACION',
                     'SEMENTO_RIESGO',
                     ]

variables_nominales=['TIPESTCIVIL',
                     'CODPAISNACIONALIDAD',
                     'DESTIPPROVINCIA',
                     'DIGITALIDAD',]

# %% codecell
_ = pd.concat([data.dtypes.to_frame(),
           data.sample(3).T]  ,
          axis=1)
_.columns=["dtype","example0","example1","example2"]
display(_)

# %% markdown
# # VACIOS

# %% codecell
# matriz de vacios
with sns.axes_style("dark"), sns.plotting_context("paper"):
    msno.matrix(data,labels=True , color=(0.2,0.2,0.2))
    plt.xticks(rotation=90, horizontalalignment='center')
    plt.show()
    plt.close()

# %% codecell
# barras ordenadas
with sns.axes_style("darkgrid"), sns.plotting_context("paper"):
    g = msno.bar(data,sort="descending",color="gray",labels=True)
    g.set_xticklabels(g.get_xticklabels(), rotation=90, horizontalalignment='center')
    plt.xticks(rotation=90, horizontalalignment='center', )
    plt.tick_params(axis="x",direction="in", pad=-60)
    plt.show()
    plt.close()

# %% codecell
# correlacion de vacios
g= msno.heatmap(data)
plt.show()

# %% codecell
#dendograma de correlaciones de vacios
msno.dendrogram(data)
plt.show()
plt.close()

# %% markdown
# # Matriz de correlaciones
# %% codecell
fig, (ax) = plt.subplots(1,1,figsize=(14,14))
sns.heatmap(data.corr(),
            ax = ax,
            vmin = -1, vmax = 1,
            cmap ="coolwarm",
            annot = True,
            fmt = ".1f",
            linewidths=.05,
            )
plt.show()
plt.close()

# %% markdown
# # VARIABLES
# %% codecell
with sns.axes_style("darkgrid"), sns.plotting_context("talk"):
    continous_grid(data, variables_continuas, 3,6,25, 30, 0.5,0.3)
    plt.show()
    plt.close()
# %% codecell
with sns.axes_style("darkgrid"), sns.plotting_context("talk"):
    discrete_grid(data, variables_discretas,4,6,25,1 )
    plt.show()
    plt.close()

# %% codecell
with sns.axes_style("darkgrid"), sns.plotting_context("paper"):
    discrete_grid(data, variables_nominales,4 ,2,15,1 )
    plt.show()
    plt.close()

# %% codecell
with sns.axes_style("darkgrid"), sns.plotting_context("paper"):
    discrete_grid(data, variables_ordinales,4,2,15,1 )
    plt.show()

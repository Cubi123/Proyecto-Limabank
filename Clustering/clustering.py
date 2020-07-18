# %% markdown
# # Clustering
# En primer lugar, se cargan los datos provenientes de la limpieza de vacíos y el encoding de variables cardinales. Estos datos aún tienen diferente escala, lo cual es un problema para los modelos de clustering basados en distancia euclidiana.

# %% codecell
import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_samples, silhouette_score
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.preprocessing import MinMaxScaler
from  Clustering.setup import *

data = pd.read_csv("Data/data_clean.csv")

# %% markdown
# Para solucionar los problemas mencionados, en primer lugar, truncaremos las variables de ingreso y Deudas reemplazando sus fuertes colas a la derecha con el valor en el cuantil 95. Luego, escalaremos con MinMaxScaler.

# %% codecell
to_truncate = ["INGRESO","SBS_DEUTOTAL","Banco1_DEUTOTAL",
               "Banco2_DEUTOTAL","Banco3_DEUTOTAL",
               "Banco4_DEUTOTAL", "OTROS_DEUTOTAL"]

for col in to_truncate:
    limit = np.percentile(data[col],95)
    mask = data[col]>limit
    data.loc[mask,col] = limit

for col in data.columns:
    sca = MinMaxScaler()
    data[col] = sca.fit_transform(data[[col]])

data.describe().T
# %% markdown
# # Clustering por K-Means
# En este punto realizaremos el clustering por el algoritmo de k-means. Se usará el método del codo para determinar el número de clusters k óptimo

# %% codecell
df1 = data.copy(deep=True)
df1 = df1.sample(n=10000)
range_n_clusters = [i for i in range(2,10)]
silhouette_list=[]

for n_clusters in range_n_clusters:

    clusterer = KMeans(n_clusters=n_clusters, random_state=42)
    cluster_labels = clusterer.fit_predict(df1)

    # The silhouette_score gives the average value for all the samples.
    # This gives a perspective into the density and separation of the formed
    # clusters
    silhouette_avg = silhouette_score(df1, cluster_labels)
    print("For n_clusters =", n_clusters,
          "The average silhouette_score is :", silhouette_avg)

    # Compute the silhouette scores for each sample
    sample_silhouette_values = silhouette_samples(df1, cluster_labels)
    silhouette_list.append(silhouette_avg)

plt.title("Diagrama del codo")
plt.plot(range_n_clusters,silhouette_list)

# %% markdown
# Se observa que el número óptimo de clusters es 6. Entonces aplicaremos Kmeans con k=6. y describiremos a cada grupo encontrado.

# %% codecell
kmeans = KMeans(n_clusters=6, random_state=42).fit(data)
len(kmeans.labels_)

data_to_interpret = pd.read_csv("Data/data_clean_noimput.csv")
data_to_interpret.shape
data_to_interpret["cluster"] = kmeans.labels_
pd.Series(kmeans.labels_).value_counts()
plt.hist(kmeans.labels_)

# %% markdown
# # Interpretación de clusters

# %% codecell
from sklearn.tree import DecisionTreeRegressor
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(data,
                                                    kmeans.labels_,
                                                    test_size = 0.3)
modelo = DecisionTreeRegressor(criterion="mse",
                               max_depth=None,      # máxima profundidad del arbol
                               )
modelo.fit(X_train, y_train)  # ajusto los datos de entrenamiento

y_pred = modelo.predict(X_test)

rmse_test = np.sqrt(mean_squared_error(y_test, y_pred))
print("Root Mean Squared Error: {}".format(rmse_test))

from sklearn.tree import plot_tree
plt.figure(figsize=(10,5))
sns.set_context("talk")
plot_tree(modelo,
          max_depth=2,
          feature_names= data.columns,
          class_names=None,
          label="all",
          )
plt.show()
plt.close()


data_to_interpret = pd.read_csv("Data/data_clean_noimput.csv")
data_to_interpret["cluster"] = kmeans.labels_
data_to_interpret.shape

variables_continuas=['INGRESO',
                     'EDAD',
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


with sns.axes_style("darkgrid"), sns.plotting_context("talk"):
    continous_interpret(data_to_interpret, variables_continuas, "cluster",3,6,25, 30, 0.5,0.3,)
    plt.show()
    plt.close()

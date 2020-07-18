# %% markdown
# # Clustering
# En primer lugar, se cargan los datos provenientes de la limpieza de vacíos y el encoding de variables cardinales. Estos datos aún tienen diferente escala, lo cual es un problema para los modelos de clustering basados en distancia euclidiana.

# %% codecell
import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_samples, silhouette_score
import matplotlib.pyplot as plt
from sklearn.preprocessing import MinMaxScaler
from

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

# %% markdown
# # CLustering por K-KMeans
# En este punto realizaremos el clustering por el algoritmo de k-means. Se usará el método del codo para determinar el número de clusters k óptimo

# %% codecell
df1 = data.copy(deep=True)

range_n_clusters = [i for i in range(2,20)]
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
plt.plot(range_n_clusters,silhouette_list)

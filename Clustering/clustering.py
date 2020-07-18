import numpy as np
import seaborn
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans

rnorm = np.random.randn

x = rnorm(1000) * 10
y = np.concatenate([rnorm(500), rnorm(500) + 5])

fig, axes = plt.subplots(3, 1)

axes[0].scatter(x, y)
axes[0].set_title('Data (note different axes scales)')

km = KMeans(2)

clusters = km.fit_predict(np.array([x, y]).T)

axes[1].scatter(x, y, c=clusters, cmap='bwr')
axes[1].set_title('non-normalised K-means')

clusters = km.fit_predict(np.array([x / 10, y]).T)

axes[2].scatter(x, y, c=clusters, cmap='bwr')
axes[2].set_title('Normalised K-means')

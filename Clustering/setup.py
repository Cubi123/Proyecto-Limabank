
import math
from IPython.core import display as ICD
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import missingno as msno
import os

def dummies_inplace(df, colname):
    dummies = pd.get_dummies(df[colname],prefix=colname, prefix_sep="_")
    dummies.replace(to_replace=1,value=(1/len(df[colname]))**0.5, inplace=True)
    df.drop(colname, axis = 1, inplace = True)
    df = pd.concat([df,dummies], axis=1)

def continous_grid(df, X  ,n_rows, n_cols, bins=10, size = 10, size_ratio = 1,alpha=1,hue_col_name=None):

    fig, axes = plt.subplots(nrows=n_rows, ncols=n_cols, figsize=(size , size*size_ratio) )
    iter_variables = iter(X)
    counter = 0

    for i in range(n_rows):
            for j in range(n_cols):
                ax = axes[i][j]

                if counter < 2*len(X):
                    if j%2==0:
                        var_name = next(iter_variables)
                        sns.FacetGrid(df, hue=hue_col_name).map(sns.distplot, var_name ,bins=bins, ax=ax)
                        ax.set_title(var_name+" Distribution")
                        # ax.legend(loc="best")
                    else:
                        ax.set_axis_off()
                        # sns.scatterplot(x=var_name, y=y, hue=hue_col_name, data =df, alpha=alpha, ax=ax)
                        # ax.set_title(var_name + " Scatterplot")

                else:
                    ax.set_axis_off()

                counter += 1

    fig.tight_layout()
    sns.despine()


def discrete_grid(df, X ,n_rows, n_cols, size = 4, size_ratio = 1,alpha=1,hue_col_name=None, s=10):

    fig, axes = plt.subplots(nrows=n_rows, ncols=n_cols, figsize=(size , size*size_ratio))

    iter_variables = iter(X)
    counter = 0

    for i in range(n_rows):
            for j in range(n_cols):
                ax = axes[i][j]

                if counter < 2*len(X):
                    if j%2==0:
                        var_name = next(iter_variables)
                        sns.countplot(x= var_name , hue = hue_col_name ,
                                      data = df , ax=ax, palette ="muted")
                        ax.set_title(var_name+" Countplot")
                        # ax.legend(loc="best")
                    else:
                        ax.set_axis_off()

                        # sns.stripplot(x = var_name , y = y , hue = hue_col_name, s=s,
                        #                data = df , #scale="count", scale_hue=False
                        #                alpha = alpha, ax = ax, palette="muted")

                        # sns.violinplot( x = var_name , y = y , hue = hue_col_name,
                        #                data = df , #scale="count", scale_hue=False
                        #                alpha = alpha, ax = ax, palette="muted")

                        # ax.legend().set_visible(False) # esto debido a que en test nunca tenemos y, solo X
                        # ax.set_title(var_name + " Stripplot")

                else:
                    ax.set_axis_off()

                counter += 1

    fig.tight_layout()
    sns.despine()

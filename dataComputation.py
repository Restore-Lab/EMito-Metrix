import os
import pandas as pd
import numpy as np
import sklearn
import umap.umap_ as umap
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, RegularPolygon
from matplotlib.path import Path
from matplotlib.projections import register_projection
from matplotlib.projections.polar import PolarAxes
from matplotlib.spines import Spine
from matplotlib.transforms import Affine2D
import xgboost
import sklearn.ensemble
import sklearn.neural_network
import sklearn.cluster
import seaborn as sns
import scipy.cluster.hierarchy as shc
import pickle
import shap
import sys
import getopt

import warnings

from sklearn.model_selection import RandomizedSearchCV, StratifiedKFold
from sklearn.pipeline import Pipeline
    
def measurements_to_df(measurements_dir):
    df = pd.DataFrame()
    for root, dirs, files in os.walk(measurements_dir):
        if not root.endswith("tromc"):
            for file in files:
                if file.endswith("measurements.txt"):
                    measurement_df = pd.read_csv(os.path.join(root, file), sep="\t")
                    df = pd.concat([df, measurement_df], ignore_index=True)
    return df

def draw_2D(df, condition, method="UMAP", draw=True, savefig=True, prefix_save='', k=5, col_color=[], palette=None,
            drop_cols=["Mito_CentroidX", "Mito_CentroidY", "Mito_FeretX", "Mito_FeretY"]):
    if method=="UMAP":
        reducer = umap.UMAP()
    elif method=="PCA":
        reducer = sklearn.decomposition.PCA()
    else:
        print("Please choose either UMAP or PCA as projection method")

    ss = sklearn.preprocessing.StandardScaler()
    reducer.fit(ss.fit_transform(df.loc[:, "Mito_Area":].drop(drop_cols,
                                                              axis=1, errors="ignore")))

    if method=="UMAP":
        embedding = reducer.embedding_
    elif method=="PCA":
        embedding = reducer.transform(ss.fit_transform(df.loc[:, "Mito_Area":].drop(drop_cols,
                                                                                    axis=1, errors="ignore")))
    if col_color=="all":
        conditions = [condition, "KMeans"] + df.drop(drop_cols + [condition], axis=1, errors="ignore").columns.to_list()
    else:
        conditions = [condition] + col_color

    for colorcoding_condition in conditions:
        plt.figure(figsize=(16,10))
        if colorcoding_condition=="KMeans":
            KMeans_labels = sklearn.cluster.KMeans(n_clusters=k).fit_predict(embedding)
            palette = {cluster:color for cluster, color in zip(np.sort(np.unique(KMeans_labels)),
                                                               sns.color_palette(n_colors=len(np.unique(KMeans_labels))))}
            for cluster in np.unique(KMeans_labels):
                plt.scatter(embedding[KMeans_labels==cluster,0],
                            embedding[KMeans_labels==cluster,1],
                            s=10, label=cluster, color=palette[cluster])
            plt.legend(title="Cluster", fontsize=12, title_fontsize=14)
            plt.title(method+" colored by KMeans", fontsize=20)

        elif not pd.api.types.is_any_real_numeric_dtype(df[colorcoding_condition]): #category
            df[colorcoding_condition] = df[colorcoding_condition].astype(str)
            if (palette is None) or (colorcoding_condition != condition):
                palette = {condition_name:color for condition_name, color in zip(np.unique(df[colorcoding_condition]),
                                                                                sns.color_palette(n_colors=len(np.unique(df[colorcoding_condition]))))}
            for condition_name in np.unique(df[colorcoding_condition]):
                plt.scatter(embedding[df[colorcoding_condition]==condition_name,0],
                            embedding[df[colorcoding_condition]==condition_name,1],
                            s=10, label=condition_name, color=palette[condition_name])
            plt.legend(title=colorcoding_condition, fontsize=12, title_fontsize=14)
            plt.title(method+" colored by "+colorcoding_condition, fontsize=20)
        else: #metric
            sc = plt.scatter(embedding[:,0],
                        embedding[:,1],
                        s=10, label=colorcoding_condition, c=df[colorcoding_condition])
            clb = plt.colorbar(sc)
            clb.ax.set_title(colorcoding_condition, fontsize=16)
            clb.ax.tick_params(axis="both", labelsize=12)
            plt.setp(clb.ax.spines.values(), linewidth=2)
            plt.title(method+" colored by "+colorcoding_condition, fontsize=20)
        plt.xlabel(method+" first dimension", fontsize=20)
        plt.ylabel(method+" second dimension", fontsize=20)
        plt.tick_params(axis='both', which='both', left=False, bottom=False, labelbottom=False, labelleft=False)
        if savefig: plt.savefig(prefix_save+"/"+method+"_"+colorcoding_condition+".png", bbox_inches='tight', dpi=300)
        if draw: plt.show(block=False)
        if draw: plt.close()
        

def PCA_components(df, ratio_threshold=0.9, savefig=True, prefix_save='', draw=True, drop_cols=["Mito_CentroidX", "Mito_CentroidY", "Mito_FeretX", "Mito_FeretY"]):
    pca = sklearn.decomposition.PCA()
    ss = sklearn.preprocessing.StandardScaler()
    pca.fit(ss.fit_transform(df.loc[:, "Mito_Area":].drop(drop_cols,
                                                                                           axis=1, errors="ignore")))

    plt.plot(range(1,len(pca.components_)+1),np.cumsum(pca.explained_variance_ratio_))
    plt.axhline(0.9, color='red')
    plt.xlabel("Number of components")
    plt.ylabel("Total explained variance ratio")
    if savefig: plt.savefig("PCA_Ratio_Components.png", bbox_inches='tight')
    if draw: plt.show(block=False)
    if draw: plt.close()

    n_compo = (np.cumsum(pca.explained_variance_ratio_) < ratio_threshold).sum()+1
    fig, ax = plt.subplots(1, n_compo, figsize=(6*n_compo,6), sharey=True)
    for i in range(n_compo):
        ax[i].barh(y=range(0, len(pca.components_[i])), width=pca.components_[i])
        ax[i].set_yticks(np.arange(len(pca.components_[i])))
        ax[i].set_yticklabels(df.loc[:,"Mito_Area":].drop(["Mito_CentroidX", "Mito_CentroidY", "Mito_FeretX", "Mito_FeretY"],
                                                                                               axis=1, errors="ignore").columns.to_list())
        ax[i].set_title("Component "+str(i+1)+"\nExplained variance ratio : "+str(np.round(pca.explained_variance_ratio_[i],2)))
    plt.tight_layout()
    if savefig: plt.savefig(prefix_save+"/"+"PCA_"+str(n_compo)+"_components.png", bbox_inches='tight', dpi=300)
    if draw: plt.show(block=False)
    if draw: plt.close()

def correlations(df, savefig=True, prefix_save='', draw=True, drop_cols=["Mito_CentroidX", "Mito_CentroidY", "Mito_FeretX", "Mito_FeretY"], precision=2):
    fig = plt.figure(figsize=(12,9))
    corr = df.loc[:,"Mito_Area":].drop(drop_cols,
                                       axis=1, errors="ignore").corr()
    linkage = shc.linkage(corr.abs())
    sns.clustermap(corr, annot=True, center=0, row_linkage=linkage, col_linkage=linkage, fmt='.'+str(precision)+'f')
    if savefig: plt.savefig(prefix_save+"/"+"correlation.png", bbox_inches='tight', dpi=300)
    if draw: plt.show(block=False)
    if draw: plt.close()

def histograms(df, condition, savefig=True, prefix_save='', draw=True, kind="density", palette=None, legend=True,
               drop_cols=["Mito_CentroidX", "Mito_CentroidY", "Mito_FeretX", "Mito_FeretY"]):
    df_densities=df.loc[:,"Mito_Area":].drop(drop_cols,
                                                                              axis=1, errors="ignore").astype('float')
    if palette is None:
        palette = {condition:color for condition, color in zip(np.unique(df[condition]),
                                                               sns.color_palette(n_colors=len(np.unique(df[condition]))))}
        
    n = len([col for col in df_densities.columns if col!=condition])
    fig, axes = plt.subplots(n//3+1, 3, figsize=(25,18))
    for i, col in enumerate([col for col in df_densities.columns if col!=condition]):
        df[col] = df[col].astype('float')
        print(col)
        if kind=="violin":
            sns.violinplot(data=df, y=col, x=condition, hue=condition, palette=palette, ax=axes[i//3, i%3])
            axes[i//3, i%3].tick_params(axis='both', labelsize=16)
            axes[i//3, i%3].set_title(col, fontsize=20)
            axes[i//3, i%3].set_xlabel(None)
        if kind=="histogram":
            sns.histplot(data=df, x=col, hue=condition, hue_order=np.unique(df[condition]), palette=palette, stat="density", common_norm=False, ax=axes[i//3, i%3])
            axes[i//3, i%3].tick_params(axis='x', labelsize=16)
            axes[i//3, i%3].set_xlabel(col, fontsize=20)
            if not legend: axes[i//3, i%3].get_legend().remove()
        elif kind=="density":
            sns.kdeplot(data=df, x=col, hue=condition, hue_order=np.unique(df[condition]), palette=palette, common_norm=False, ax=axes[i//3, i%3])
            axes[i//3, i%3].tick_params(axis='x', labelsize=16)
            axes[i//3, i%3].set_xlabel(col, fontsize=20)
            if not legend: axes[i//3, i%3].get_legend().remove()
        #plot.legend(title_fontsize=14, fontsize=12)
        #if not legend: axes[i//3, i%3].get_legend().remove()
    plt.tight_layout()
    if savefig: plt.savefig(prefix_save+"/"+kind+".png", bbox_inches='tight', dpi=300)
    if draw: plt.show(block=False)
    if draw: plt.close()
    
def radar_factory(num_vars, frame='circle'):
    """
    Create a radar chart with `num_vars` axes.

    This function creates a RadarAxes projection and registers it.

    Parameters
    ----------
    num_vars : int
        Number of variables for radar chart.
    frame : {'circle', 'polygon'}
        Shape of frame surrounding axes.

    """
    # calculate evenly-spaced axis angles
    theta = np.linspace(0, 2*np.pi, num_vars, endpoint=False)

    class RadarTransform(PolarAxes.PolarTransform):

        def transform_path_non_affine(self, path):
            # Paths with non-unit interpolation steps correspond to gridlines,
            # in which case we force interpolation (to defeat PolarTransform's
            # autoconversion to circular arcs).
            if path._interpolation_steps > 1:
                path = path.interpolated(num_vars)
            return Path(self.transform(path.vertices), path.codes)

    class RadarAxes(PolarAxes):

        name = 'radar'
        PolarTransform = RadarTransform

        def __init__(self, *args, **kwargs):
            super().__init__(*args, **kwargs)
            # rotate plot such that the first axis is at the top
            self.set_theta_zero_location('N')

        def fill(self, *args, closed=True, **kwargs):
            """Override fill so that line is closed by default"""
            return super().fill(closed=closed, *args, **kwargs)

        def plot(self, *args, **kwargs):
            """Override plot so that line is closed by default"""
            lines = super().plot(*args, **kwargs)
            for line in lines:
                self._close_line(line)

        def _close_line(self, line):
            x, y = line.get_data()
            # FIXME: markers at x[0], y[0] get doubled-up
            if x[0] != x[-1]:
                x = np.append(x, x[0])
                y = np.append(y, y[0])
                line.set_data(x, y)

        def set_varlabels(self, labels):
            self.set_thetagrids(np.degrees(theta), labels)

        def _gen_axes_patch(self):
            # The Axes patch must be centered at (0.5, 0.5) and of radius 0.5
            # in axes coordinates.
            if frame == 'circle':
                return Circle((0.5, 0.5), 0.5)
            elif frame == 'polygon':
                return RegularPolygon((0.5, 0.5), num_vars,
                                      radius=.5, edgecolor="k")
            else:
                raise ValueError("Unknown value for 'frame': %s" % frame)

        def _gen_axes_spines(self):
            if frame == 'circle':
                return super()._gen_axes_spines()
            elif frame == 'polygon':
                # spine_type must be 'left'/'right'/'top'/'bottom'/'circle'.
                spine = Spine(axes=self,
                              spine_type='circle',
                              path=Path.unit_regular_polygon(num_vars))
                # unit_regular_polygon gives a polygon of radius 1 centered at
                # (0, 0) but we want a polygon of radius 0.5 centered at (0.5,
                # 0.5) in axes coordinates.
                spine.set_transform(Affine2D().scale(.5).translate(.5, .5)
                                    + self.transAxes)
                return {'polar': spine}
            else:
                raise ValueError("Unknown value for 'frame': %s" % frame)

    register_projection(RadarAxes)
    return theta

def plot_radar_chart(df, condition, scaler=sklearn.preprocessing.MinMaxScaler(feature_range=(0,100)), savefig=True, prefix_save='', draw=True, palette=None,
                     drop_cols=["Mito_CentroidX", "Mito_CentroidY", "Mito_FeretX", "Mito_FeretY"]):

    df_data = df.loc[:,"Mito_Area":].drop(drop_cols, axis=1, errors="ignore")
    data = pd.DataFrame(scaler.fit_transform(df_data),columns=df_data.columns, index=df.index)
    
    N = len(df_data.columns)
    theta = radar_factory(N, frame='polygon')
    spoke_labels = df_data.columns

    fig, ax = plt.subplots(figsize=(9, 9), subplot_kw=dict(projection='radar'))
    fig.subplots_adjust(wspace=0.25, hspace=0.20, top=0.85, bottom=0.05)

    # Plot the four cases from the example data on separate axes
    #ax.set_rgrids([0.2, 0.4, 0.6, 0.8])
    #ax.set_title("Test", weight='bold', size='medium', position=(0.5, 1.1),horizontalalignment='center', verticalalignment='center')
    for condition_name in np.unique(df[condition]):
        ax.plot(theta, data.loc[df[condition]==condition_name].mean(), color=palette[condition_name], label=condition_name)
        ax.fill(theta, data.loc[df[condition]==condition_name].mean(), facecolor=palette[condition_name], alpha=0.25, label='_nolegend_')
    ax.set_varlabels([spoke_label[5:] if spoke_label.startswith("Mito_") else spoke_label for spoke_label in spoke_labels])
    ax.tick_params(axis='both', which='major', pad=50)

    # add legend relative to top-left plot
    labels = np.unique(df[condition])
    legend = ax.legend(labels, loc=(0.9, .95),
                              labelspacing=0.1, fontsize='small')

    fig.text(0.5, 0.965, 'Radar plot',
             horizontalalignment='center', color='black', weight='bold',
             size='large')

    if savefig: plt.savefig(prefix_save+"radar_plot.png", bbox_inches='tight', dpi=300)
    if draw: plt.show(block=False)
    if draw: plt.close()

def spatial_clustering(df, draw=True, draw_histograms=False, savefig=False, export_csv=False, prefix_save=''):
    """
    For each image in the DataFrame, show a spatial representation of mitochondria and
    perform HDBSCAN clustering on them. Optionnally, save a csv with mean characteristics
    of each cluster
    """
    
    for image in df.loc[:,"Image_Name"].unique().astype(str):
        df_pos = df.loc[df["Image_Name"]==image].copy()
        if df_pos.shape[0] > 5:
            hdbscan = sklearn.cluster.HDBSCAN()
            hdbscan.fit(df_pos.loc[:, ["Mito_CentroidX", "Mito_CentroidY"]])
            labels = hdbscan.labels_

            plt.figure()
            plt.scatter(df_pos.loc[:, "Mito_CentroidX"], df_pos.loc[:, "Mito_CentroidY"], c="black")
            plt.title(image)
            if savefig:
                os.makedirs(prefix_save+image+"/", exist_ok=True)
                plt.savefig(prefix_save+image+"/x_y_plot.png", bbox_inches='tight', dpi=300)

            plt.figure()
            for l in np.sort(np.unique(labels)):
                plt.scatter(df_pos.loc[labels==l, "Mito_CentroidX"], df_pos.loc[labels==l, "Mito_CentroidY"], label=l)
            plt.title(image)
            if savefig:
                os.makedirs(prefix_save+image+"/", exist_ok=True)
                plt.savefig(prefix_save+image+"/spatial_clustering.png", bbox_inches='tight', dpi=300)
            if draw: plt.show(block=False)

            if draw_histograms:
                df_pos["Cluster"] = labels
                os.makedirs(prefix_save+image+"/", exist_ok=True)
                histograms(df_pos, condition="Cluster", savefig=savefig, prefix_save=prefix_save+image+"/", legend=False)

            if export_csv:
                os.makedirs(prefix_save+image+"/", exist_ok=True)
                df_pos._get_numeric_data().groupby("Cluster").mean().to_csv(prefix_save+image+"/clusters.csv")

def all_figures(df, condition, savefig=True, prefix_save='', draw=True, palette=None, col_color="all",
                drop_cols=["Mito_CentroidX", "Mito_CentroidY", "Mito_FeretX", "Mito_FeretY"]):
    draw_2D(df, condition, method="UMAP", draw=draw, col_color=col_color, savefig=savefig, prefix_save=prefix_save, palette=palette, drop_cols=drop_cols)
    draw_2D(df, condition, method="PCA", draw=draw, col_color=col_color, savefig=savefig, prefix_save=prefix_save, palette=palette, drop_cols=drop_cols)
    histograms(df, condition, savefig=savefig, prefix_save=prefix_save, draw=draw, kind="violin", palette=palette, drop_cols=drop_cols)
    histograms(df, condition, savefig=savefig, prefix_save=prefix_save, draw=draw, kind="density", palette=palette, drop_cols=drop_cols)
    #histograms(df, condition, savefig=savefig, prefix_save=prefix_save, draw=draw, kind="histogram", palette=palette, drop_cols=drop_cols)
    plot_radar_chart(df, condition, savefig=savefig, prefix_save=prefix_save+"/MinMaxScaler_", draw=draw, palette=palette, drop_cols=drop_cols)
    plot_radar_chart(df, condition, savefig=savefig, prefix_save=prefix_save+"/StandardScaler_", scaler=sklearn.preprocessing.StandardScaler(), draw=draw, palette=palette, drop_cols=drop_cols)
    spatial_clustering(df, draw=draw, draw_histograms=draw, savefig=savefig, export_csv=draw, prefix_save=prefix_save+"spatial_clustering/")

def draw_figures(df, condition, savefig=True, prefix_save='', draw=True, palette=None, legend_histo=True, col_color=[],
                 drop_cols=["Mito_CentroidX", "Mito_CentroidY", "Mito_FeretX", "Mito_FeretY"],
                 dict_figs={fig:True for fig in ["PCA","UMAP","violin","density","histogram","radar", "spatial_clustering"]}):
    if dict_figs["UMAP"]:
        draw_2D(df, condition, method="UMAP", draw=draw, savefig=savefig, col_color=col_color, prefix_save=prefix_save, palette=palette, drop_cols=drop_cols)
    if dict_figs["PCA"]:
        draw_2D(df, condition, method="PCA", draw=draw, savefig=savefig, col_color=col_color, prefix_save=prefix_save, palette=palette, drop_cols=drop_cols)
    if dict_figs["violin"]:
        histograms(df, condition, savefig=savefig, prefix_save=prefix_save, draw=draw, kind="violin", legend=legend_histo, palette=palette, drop_cols=drop_cols)
    if dict_figs["density"]:
        histograms(df, condition, savefig=savefig, prefix_save=prefix_save, draw=draw, kind="density", legend=legend_histo, palette=palette, drop_cols=drop_cols)
    if dict_figs["histogram"]:
        histograms(df, condition, savefig=savefig, prefix_save=prefix_save, draw=draw, kind="histogram", legend=legend_histo, palette=palette, drop_cols=drop_cols)
    if dict_figs["radar"]:
        plot_radar_chart(df, condition, savefig=savefig, prefix_save=prefix_save+"/MinMaxScaler_", draw=draw, palette=palette, drop_cols=drop_cols)
        plot_radar_chart(df, condition, savefig=savefig, prefix_save=prefix_save+"/StandardScaler_", scaler=sklearn.preprocessing.StandardScaler(), draw=draw, palette=palette, drop_cols=drop_cols)
    if dict_figs["spatial_clustering"]:
        spatial_clustering(df, draw=draw, draw_histograms=draw, savefig=savefig, export_csv=draw, prefix_save=prefix_save+"spatial_clustering/")

def main(argv):
    #dir = r'\\restore-share2.inserm.lan\Restore-EQ-PLT\Public\Projets_RESTORE\EQ3_Mitochondries_ME\Processed_data\Zebrafish\analysis_0723_SPECIFIC'
    #dir_save = r'\\restore-share2.inserm.lan\Restore-EQ-PLT\Public\Projets_RESTORE\EQ3_Mitochondries_ME\Processed_data\Zebrafish\analysis_0723_SPECIFIC\Prediction_analysis'
    dir = './'
    dir_save = './'
    condition = "Condition_Name"

    list_figs = ["PCA","UMAP","violin","density","histogram","radar","spatial_clustering"]

    list_cols = ['Condition_Name', 'Image_Name', 'Mito_ID', 'Mito_Area',
       'Mito_Perimeter', 'AreaPerimeter_Ratio', 'Mito_MeanInt', 'Mito_MedianInt', 'Mito_TotalInt', 'Intensity_SD',
       'Intensity_SD_percent', 'Mito_MeanInt_CORR', 'Mito_MedianInt_CORR', 'Mito_TotalInt_CORR', 'Intensity_SD_CORR', 'Intensity_SD_percent_CORR', 'Mito_CentroidX', 'Mito_CentroidY', 'Mito_Circularity', 'Mito_Roundness', 'Mito_Solidity',
       'Mito_AR', 'Mito_Feret_Diameter', 'Mito_FeretX', 'Mito_FeretY', 'Skewness', 'Kurtosis', 'CristaeOrientation_Major', 'CristaeOrientation_Minor', 'CristaeOrientation_Angle', 'CristaeOrientation_Area']
    
    keep_cols = []
    default_cols = False
    
    dict_figs = {fig:False for fig in list_figs}
    draw=True
    savefig=True


    help_message = '''processing.py -i <measurementsfolder> -o <output> --options --fig1 --fig2 --col1 --col2...
Options include :
--no-draw: do not open figures visualisations
--no-save: do not save figures
--default-cols: use default columns for analysis
--all-figs: compute all figures
Figs include :
--'''+ '\n--'.join(list_figs)
    try:
        opts, args = getopt.getopt(argv,"hi:o:", list_figs + list_cols + ["no-draw","no-save","default-cols","all-figs"])
    except getopt.GetoptError as err:
        print(err)
        print(help_message)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print (help_message)
            sys.exit()
        if opt == '-i':
            dir = arg
        if opt == '-o':
            dir_save = arg
        if opt == '--no-draw':
            draw=False
        if opt == '--no-save':
            savefig=False
        if opt == '--default-cols':
            default_cols = True
        if opt == '--all-figs':
            dict_figs = {fig:True for fig in list_figs}
        if opt[2:] in list_figs:
            dict_figs[opt[2:]] = True
        if opt[2:] in list_cols:
            keep_cols.append(opt[2:])
    
    if not default_cols:
        drop_cols = np.setdiff1d(list_cols, keep_cols)
    else:
        drop_cols = ["Mito_CentroidX", "Mito_CentroidY", "Mito_FeretX", "Mito_FeretY"]

    print("Searching through directory : ",dir)
    df = measurements_to_df(dir)

    #df["age"]=df["Condition_Name"].str[:2].astype(int) #Difficile à automatiser...
    palette = sns.color_palette()
    condition_palette = {condition:color for condition, color in zip(df[condition].unique(), palette)}
    #all_figures(df, condition, palette=condition_palette, prefix_save=dir_save, draw=True)

    draw_figures(df,
                 condition,
                 palette=condition_palette, 
                 prefix_save=dir_save, 
                 savefig=savefig, 
                 draw=draw, 
                 drop_cols=drop_cols, 
                 dict_figs=dict_figs)

    #input("Press enter to end the program")

if __name__== "__main__":
    main(sys.argv[1:])
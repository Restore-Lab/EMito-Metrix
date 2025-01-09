import getopt
import os
import pickle
import sys
import warnings
import sklearn
import numpy as np
import pandas as pd
from sklearn.exceptions import ConvergenceWarning
from sklearn.model_selection import RandomizedSearchCV, StratifiedKFold
from sklearn.pipeline import Pipeline
from sklearn.neural_network import MLPClassifier
import sklearn.preprocessing
import xgboost
import matplotlib.pyplot as plt
import shap

def measurements_to_df(measurements_dir):
    df = pd.DataFrame()
    for root, dirs, files in os.walk(measurements_dir):
        if not root.endswith("tromc"):
            for file in files:
                if file.endswith("measurements.txt"):
                    measurement_df = pd.read_csv(os.path.join(root, file), sep="\t")
                    df = pd.concat([df, measurement_df], ignore_index=True)
    return df

def train_models(X, y, save_model=True, save_name='', random_state=0, list_models=["LR","RF","XGB","MLP"]):
    warnings.filterwarnings("ignore", category=ConvergenceWarning)

    X_train, X_test, y_train, y_test = sklearn.model_selection.train_test_split(X,
                                                                                y,
                                                                                test_size=0.25,
                                                                                stratify=y)
    pipe_xgb = Pipeline([
        ("ml", xgboost.XGBClassifier())
    ])
    pipe_rf = Pipeline([
        ("scaler", sklearn.preprocessing.StandardScaler()),
        ("ml", sklearn.ensemble.RandomForestClassifier())
    ])
    pipe_lr = Pipeline([
        ("scaler", sklearn.preprocessing.StandardScaler()),
        ("ml", sklearn.linear_model.LogisticRegression())
    ])
    pipe_mlp = Pipeline([
        ("scaler", sklearn.preprocessing.StandardScaler()),
        ("ml", MLPClassifier())
    ])

    params_xgb = [
        {
            "ml": [xgboost.XGBClassifier()],
            "ml__eval_metric": ["logloss"],
            "ml__objective": ["binary:logistic"],
            #"ml__use_label_encoder":[False],
            "ml__max_depth": [2,3,4],
            "ml__learning_rate": [0.01, 0.005, 0.001, 0.0005],
            "ml__colsample_bytree": [0.5, 0.1, np.round(np.sqrt(X.shape[1]) / X.shape[1], decimals=2)],
            "ml__n_estimators": [100],
            "ml__subsample": [0.1,0.25,0.5,0.75,1]
        }
    ]
    params_rf = [
        {
            "ml": [sklearn.ensemble.RandomForestClassifier()],
            "ml__max_depth": [3, 4, 5],
            "ml__max_samples": [0.2, 0.5, 1],
            "ml__max_features": [0.3, 0.5, "sqrt", 1],
            "ml__n_estimators": [1000]
        }
    ]

    params_lr = [
        {
            "ml": [sklearn.linear_model.LogisticRegression()],
            "ml__solver": ["saga"],
            "ml__penalty": ["elasticnet"], 
            "ml__l1_ratio": [0, 0.25, 0.5, 0.75, 1],
	    "ml__max_iter": [10000]
        }
    ]
    params_mlp = [
        {
            "ml": [sklearn.neural_network.MLPClassifier()],
            "ml__hidden_layer_sizes": [(100,),(50,),(25,),(50,25),(50,50)],
            "ml__activation": ["tanh","relu"],
            "ml__solver": ["lbfgs","adam"],
            "ml__max_iter": [5000],
            "ml__alpha": [0.0001,0.001,0.01]
        }
    ]

    dict_params = {"LR":params_lr, "RF":params_rf, "XGB":params_xgb, "MLP": params_mlp}
    dict_pipes = {"LR":pipe_lr, "RF":pipe_rf, "XGB":pipe_xgb, "MLP": pipe_mlp}

    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=random_state)

    dict_gs = {name:{'pipe':pipe, 
                     'params':params, 
                     'gs': None, 
                     'results': None} for name, pipe, params in zip(list_models,
                                                                    [dict_pipes[model] for model in list_models],
                                                                    [dict_params[model] for model in list_models])}
    
    for model_name in dict_gs:
        dict_gs[model_name]['gs'] = RandomizedSearchCV(
            estimator=dict_gs[model_name]['pipe'],
            param_distributions=dict_gs[model_name]['params'],
            cv=cv,
            n_iter=1000,
            verbose=1,
            return_train_score=True,
            n_jobs=-1,
            random_state=random_state,
            #scoring="roc_auc"
        )

        dict_gs[model_name]['gs'].fit(X_train, y_train)

        dict_gs[model_name]['results'] = pd.DataFrame.from_dict(dict_gs[model_name]['gs'].cv_results_).drop(["mean_fit_time", "std_fit_time", "mean_score_time", "std_score_time"], axis=1).sort_values("rank_test_score")

    dict_gs.update({"X_train":X_train,"X_test":X_test,"y_train":y_train,"y_test":y_test})
    
    if save_model:
        os.makedirs("models/", exist_ok=True)
        with open("models/"+save_name+".pkl", 'wb') as f:
            pickle.dump(dict_gs, f)
    return dict_gs

def draw_confusion_matrixes(dict_gs, display_labels, savefig=True, prefix_save='', normalize="true", draw=True):
    X_train, X_test, y_train, y_test = dict_gs["X_train"], dict_gs["X_test"], dict_gs["y_train"], dict_gs["y_test"]
    for model_name in dict_gs:
        if not (model_name.startswith("X_") or model_name.startswith("y_")):
            fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(14,6))
            sklearn.metrics.ConfusionMatrixDisplay.from_predictions(y_train, dict_gs[model_name]['gs'].best_estimator_.predict(X_train),
                                                                    display_labels=display_labels, ax=axes[0], normalize=normalize, text_kw={'fontsize':10, 'weight':'bold'})
            axes[0].set_title("Train confusion matrix\nTrain accuracy score : {:.4f}\nTrain f1 score : {:.4f}".format(sklearn.metrics.accuracy_score(y_train,dict_gs[model_name]['gs'].best_estimator_.predict(X_train)),
                                                                                                                      sklearn.metrics.f1_score(y_train,dict_gs[model_name]['gs'].best_estimator_.predict(X_train), average="macro")))
            sklearn.metrics.ConfusionMatrixDisplay.from_predictions(y_test, dict_gs[model_name]['gs'].best_estimator_.predict(X_test),
                                                                    display_labels=display_labels, ax=axes[1], normalize=normalize, text_kw={'fontsize':10, 'weight':'bold'})
            axes[1].set_title("Test confusion matrix\nTest accuracy score : {:.4f}\nTest f1 score : {:.4f}".format(sklearn.metrics.accuracy_score(y_test,dict_gs[model_name]['gs'].best_estimator_.predict(X_test)),
                                                                                                                   sklearn.metrics.f1_score(y_test,dict_gs[model_name]['gs'].best_estimator_.predict(X_test),average="macro")))
            plt.suptitle(model_name)
            if savefig:
                os.makedirs(prefix_save+"/"+model_name+"/", exist_ok=True)
                plt.savefig(prefix_save+"/"+model_name+"/"+"confusion_matrix.png", bbox_inches='tight', dpi=300)
            if draw:
                plt.show(block=False)
                plt.close()
            
def treeshap_beeswarms(model, X, class_names, savefig=True, prefix_save='', draw=True):
    explainer = shap.Explainer(model, approximate=True, output_names=class_names, feature_names=[x[5:] if x.startswith("Mito_") else x for x in X.columns])
    explanation = explainer(X.values)
    
    if len(explanation.shape)>2:
        if explanation.shape[2]>2:
            for i in range(explanation.shape[2]):
                shap.plots.beeswarm(explanation[:,:,i], max_display=15, show=False)
                plt.title("Summary plot for "+class_names[i]+ " prediction")
                if savefig:
                    os.makedirs(prefix_save+"/",exist_ok=True)
                    plt.savefig(prefix_save+"/"+class_names[i]+"_beeswarm.png", bbox_inches='tight', dpi=300)
                if draw:
                    plt.tight_layout()
                    plt.show(block=False)
                    plt.close()     
        else:
            shap.plots.beeswarm(explanation[:,:,1], max_display=15, show=False)
            plt.title("Summary plot for "+class_names[1]+" prediction")
            if savefig:
                os.makedirs(prefix_save+"/",exist_ok=True)
                plt.savefig(prefix_save+"/"+"_beeswarm.png", bbox_inches='tight', dpi=300)
            if draw:
                plt.tight_layout()
                plt.show(block=False)
                plt.close()     
    else:
        shap.plots.beeswarm(explanation, max_display=15, show=False)
        plt.title("Summary plot for "+class_names[1]+" prediction")
        if savefig:
            os.makedirs(prefix_save+"/",exist_ok=True)
            plt.savefig(prefix_save+"/"+"_beeswarm.png", bbox_inches='tight', dpi=300)
        if draw:
            plt.tight_layout()
            plt.show(block=False)
            plt.close()
    return explanation
            
def kernelshap_beeswarms(model, X, class_names, savefig=True, prefix_save='', draw=True):
    explainer = shap.Explainer(model, X.values, feature_names=X.columns, output_names=class_names, silent=True)
    explanation = explainer(X.values)
    
    if len(explanation.shape)>2:
        if explanation.shape[2]>2:
            for i in range(explanation.shape[2]):
                shap.plots.beeswarm(explanation[:,:,i], show=False)
                plt.title("Summary plot for "+class_names[i]+ " prediction")
                if savefig:
                    os.makedirs(prefix_save+"/",exist_ok=True)
                    plt.savefig(prefix_save+"/"+class_names[i]+"_beeswarm.png", bbox_inches='tight', dpi=300)
                if draw:
                    plt.tight_layout()
                    plt.show(block=False)
                    plt.close()             
        else:
            shap.plots.beeswarm(explanation[:,:,1], max_display=15, show=False)
            plt.title("Summary plot for "+class_names[1]+" prediction")
            if savefig:
                os.makedirs(prefix_save+"/",exist_ok=True)
                plt.savefig(prefix_save+"/"+"_beeswarm.png", bbox_inches='tight', dpi=300)
            if draw:
                plt.tight_layout()
                plt.show(block=False)
                plt.close()     
    else:
        shap.plots.beeswarm(explanation, max_display=15, show=False)
        plt.title("Summary plot for "+class_names[1]+" prediction")
        if savefig:
            os.makedirs(prefix_save+"/",exist_ok=True)
            plt.savefig(prefix_save+"/"+"_beeswarm.png", bbox_inches='tight', dpi=300)
        if draw:
            plt.tight_layout()
            plt.show(block=False)
            plt.close()
    return explanation


def main(argv):
    #dir = r'\\restore-share2.inserm.lan\Restore-EQ-PLT\Public\Projets_RESTORE\EQ3_Mitochondries_ME\Processed_data\Zebrafish\analysis_0723_SPECIFIC'
    #dir_save = r'\\restore-share2.inserm.lan\Restore-EQ-PLT\Public\Projets_RESTORE\EQ3_Mitochondries_ME\Processed_data\Zebrafish\analysis_0723_SPECIFIC\Prediction_analysis'
    dir = './'
    dir_save = './'
    condition = "Condition_Name"

    list_models = []
    list_possible_models = ["LR","RF","XGB","MLP"]

    list_cols = ['Condition_Name', 'Image_Name', 'Mito_ID', 'Mito_Area',
       'Mito_Perimeter', 'AreaPerimeter_Ratio', 'Mito_MeanInt', 'Mito_MedianInt', 'Mito_TotalInt', 'Intensity_SD',
       'Intensity_SD_percent', 'Mito_MeanInt_CORR', 'Mito_MedianInt_CORR', 'Mito_TotalInt_CORR', 'Intensity_SD_CORR', 'Intensity_SD_percent_CORR', 'Mito_CentroidX', 'Mito_CentroidY', 'Mito_Circularity', 'Mito_Roundness', 'Mito_Solidity',
       'Mito_AR', 'Mito_Feret_Diameter', 'Mito_FeretX', 'Mito_FeretY', 'Skewness', 'Kurtosis', 'CristaeOrientation_Major', 'CristaeOrientation_Minor', 'CristaeOrientation_Angle', 'CristaeOrientation_Area']
    
    keep_cols = []
    default_cols = False
    
    dict_models = {model:False for model in list_models}
    draw=True
    savefig=True
    explain=False


    help_message = '''models.py -i <measurementsfolder> -o <outputfolder> --options --model1 --model2 --col1 --col2 --explain...
Options include :
--no-draw: do not open visualisations
--no-save: do not save figures
--default-cols: use default columns for analysis
--all-models: compute all models
--explain: prints out the explanation for each model
Models include :
--'''+ '\n--'.join(list_possible_models)
    try:
        opts, args = getopt.getopt(argv,"hi:o:", list_possible_models + list_cols + ["no-draw","no-save","default-cols","all-models","explain"])
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
        if opt == '--all-models':
            list_models = list_possible_models
        if opt == '--explain':
            explain=True
        if opt[2:] in list_possible_models:
            list_models.append(opt[2:])
        if opt[2:] in list_cols:
            keep_cols.append(opt[2:])
    
    if not default_cols:
        drop_cols = np.setdiff1d(list_cols, keep_cols)
    else:
        drop_cols = ["Mito_CentroidX", "Mito_CentroidY", "Mito_FeretX", "Mito_FeretY"]

    print("Searching through directory : ",dir)
    df = measurements_to_df(dir)

    X = df.loc[:,"Mito_Area":].drop(drop_cols, axis=1)
    y, labels = df["Condition_Name"].factorize()

    print("Training models...")
    dict_gs = train_models(X, y, save_model=False, list_models=list_models)

    draw_confusion_matrixes(dict_gs, display_labels=labels, savefig=savefig, prefix_save=dir_save, draw=draw)

    if explain:
        print("Explaining models...")
        for model_name in dict_gs:
            if (model_name=="LR" or model_name=="MLP"):
                _ = kernelshap_beeswarms(dict_gs[model_name]["gs"].best_estimator_.steps[1][1].predict_proba,
                                         pd.DataFrame(sklearn.preprocessing.StandardScaler().fit_transform(X), columns=X.columns),
                                         class_names=labels, savefig=savefig,
                                         prefix_save=dir_save+"/"+model_name,
                                         draw=draw)
            elif model_name=="XGB":
                _ = treeshap_beeswarms(dict_gs[model_name]["gs"].best_estimator_.steps[0][1],
                                       X,
                                       class_names=labels,
                                       savefig=savefig,
                                       prefix_save=dir_save+"/"+model_name,
                                       draw=draw)
            elif model_name=="RF":
                _ = treeshap_beeswarms(dict_gs[model_name]["gs"].best_estimator_.steps[1][1],
                                       pd.DataFrame(sklearn.preprocessing.StandardScaler().fit_transform(X), columns=X.columns),
                                       class_names=labels,
                                       savefig=savefig,
                                       prefix_save=dir_save+"/"+model_name,
                                       draw=draw)

    #input("Press enter to end the program")

if __name__== "__main__":
    main(sys.argv[1:])
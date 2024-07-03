// EMito_Metrix_Fiji
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//
//
// PRE-REQUEST
// ------------------------------------------------------------------------------------------------------------------------------------------------------------
//
// --> Software configuration : 
//	   ------------------------------------
//
//		- Python/anaconda : Python 3.11 environment has to be installed on the processing station
//				   if not, use the following URL : https://www.anaconda.com/download
//				   
//
//		- Cellpose : To install Cellpose on Python environment, please follow these instruction : 
//					   1. Open an anaconda prompt / command prompt which has conda for python 3 in the path
//					   2. Create a new environment with the following command : conda create --name cellpose python=3.11
//					   3. Activate this new environment : conda activate cellpose
//					   4. To install cellpose and the GUI, run the following command : python -m pip install cellpose[gui]
//
//					   If you plan to install a GPU version of Cellpose, please follow these instructions : https://github.com/MouseLand/cellpose
//
//		- Fiji : Cellpose wrapper has to be installed (plugin BIOP). 
//				 If not, activate PTBIOP plugin with Fiji updater, and follow these instructions : https://github.com/BIOP/ijl-utilities-wrappers
//				 Bioformat Fiji plugin has to be installed. 
// 				 If not, activate Bio-Format plugin with Fiji updater. Then, restart Fiji
//
//		- Python dependancies : Install python dependencies with the following instructions : 
//									1. Open an anaconda prompt / command prompt which has conda for python 3 in the path
//									2. Run the following command : python -m pip install numpy pandas sklearn scikit-learn umap-learn seaborn xgboost shap 
//
//
//
//
// --> Expected files/directory : 
//	   --------------------------------------
//
//    - INPUT directory : protocole_name/condition_name/images.tiff
//						user must select "protocole_name" as source input
//						
//						------------------------------------------------------------------------------------------------------------------
//						!!!! Raw images must be saved in the “condition_name” folder, and not directly in the “protocole_name” folder !!!!
//						------------------------------------------------------------------------------------------------------------------
//
//						EMito-Metrix allows to process multiple conditions in one shot
//						
//	  - OUTPUT directory : protocole_name_result/
//					   	 user must select "protocole_name_result" as source output
//						 output_directory must be empty when lauching EMito-Metrix for the first time
//
//	  - EMito-Metrix files : 6 files saved in the same working directory
//									--> EMito-Metrix_Fiji.ijm : fiji macro file
//									--> data_computation.py : python file for data visualization and data computation	
//									--> Generalist_model_skeletal_tissue_EM : generalist model for mitochondria segmentation
//									--> Specialist_model_ZEBRAFISH_skeletal_tissue_EM : specialist model for Zebrafish mitochondria segmentation
//									--> Specialist_model_MOUSE_skeletal_tissue_EM : specialist model for Mouse mitochondria segmentation
//									--> Specialist_model_FLY_skeletal_tissue_EM : specialist model for Fly mitochondria segmentation
//							 
//
//
// 
// --> Plugin / General parameters : 
//	   --------------------------------------
//
//    1. Plugin configuration :
//		 --------------------
//
//		- Select the working directory containing all EMitoMetrix files : data_computation.py, EMitoMetrix_Fiji.ijm, as well as the four GM and SM models
//				All thses files must be localted in the same directory.
//				Do not change file names
//		- Select directory containing your cellpose-python virtual environment
//				Example : 'C:/Users/surname.name/.conda/envs/cellpose
//
//
//
//    2. Image analysis : General Parameters :
//		 -----------------------------------
//
//		- Model/Species/Experiment name
//		- Select workflow step to launch : 
//				Automatic Mitochondria Segmentation : detection and segmentation of mitochondria with Cellpose algorithms
//				Mitochondria Morphology Analysis : analysis of morphology and ultrastructure of mitochondria 
//								!! doesn't work without "Automatic Segmentation" !!
//				Mito Metrics Data computation : display of mitochondria measurements with various graph
//								!! doesn't work without "Automatic Segmentation" & "Morphology Analysis"!!
//		- Input Directory : directory containing the images to be processed
//				must contain nothing but the images
//		- Output Directory : directory used to save all output files
//				must be an empty directory
//
//
//
//    3. Image analysis : Parameters - part 1 :
//		 -----------------------------------
//
//		- Unit of length : unit used for all morphological measurements
//				Pixel or Micron
//		- Normalization type : Select the type of normalization for EM raw images. Allow to correct intensity heterogeneities
//				Standard score : normalization of the images by subtracting the mean and dividing the image by the standard deviation
//									normalized_value = (original_value - mean_value) / (std_value)
//				Min-Max Scaling : commonly used approach where the image intensity range gets transformed into the range from 0–1
//									normalized_value = (original_value - min_value) / (max_value - min_value)
//		- Cellpose, size across conditions : Mitochondria diameter used for cellpose segmentation
//				Same size : cellpose uses the same user-defined diameter for all condition and all images
//				Depending on Condition : cellpose uses specific user-defined diameter for each condition. But the same diameter within each condition
//				Depending on Image : cellpose uses specific user-defined diameter for each condition and each image within each condition
//				Metrics to compute : mitochondria measurements used for data computation / data display
//					default : all mitochondria measurements are automatically selected
//					custom : user manualy selects mitochondria measurements
//				Select distributions to display : graph used to display mitochondria measurements
//					default : all graph are automatically selected
//					custom : user manualy selects graph type
//
//
//
//    4. Image analysis : Part 2, Cellpose parameters :
//		 --------------------------------------------
//
//		- Trained model to use : Cellpose model used for mitochondria segmentation
//				nuclei, cyto & cyto2 : default model
//				custom model : re-trained cellpose models
//		- Custom Trained model to use : select the pretrained GM or pretrained SM models
//		- Diameter (pixel) : Mitochondria diameter (in pixels) used for cellpose segmentation
//						if 0 will use the diameter of the training labels used in the model, 
//							or with built-in model will estimate diameter for each image 
//
//
//
//
//    5. Image analysis : Part 3, Morphology analysis & data computation :
//		 ---------------------------------------------------------------
//
//		- Morphology and texture analysis : if custom, must select at least 3 metrics to be displayed
//		- Data computation : if custom, must select at least 1 graph to be displayed
//				Don't save output graphic option : selected graph are not saved in the OUTPUT directory
//				Don't display output graphi option : selected graph are not displayed
//
//
//
// Copyrights : CERT facilities - RESTORE UMR 1301-INSERM 5070-CNRS / Mathieu VIGNEAU (mathieu.vigneau@cnrs.fr), 
//			    Metabolink Team - RESTORE UMR 1301-INSERM 5070-CNRS / Jean-Philippe PRADERE (jean-philippe.pradere@inserm.fr)
//				Got-it Team - ESTORE UMR 1301-INSERM 5070-CNRS / Emmanuel DOUMARD (emmanuel.doumard@inserm.fr)
// 
//
// Publishing date : 27/06/2024
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
// 																Starting the morphological & quantitative analysis
//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


// Initialization
//------------------------------------------------------------------

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
error_plugin = 0;
error_configuration = 0;
error_cellpose = 0;
error_python_file = 0;
error_cellpose_diameter = 0;
error_morpho_choice = 0;
error_prediction_choice = 0;
error_input_tree = 0;
error_input_name = 0;
error_input_filename = 0;
error_output_tree = 0;
error_input_format = 0;
plugin_tofind1 = 0;
plugin_tofind2 = 0;
plugin_tofind3 = 0;


print("------------------STARTING EMITOMETRIX ANALYSIS----------------------\n\n");


dir_fiji = getDirectory("plugins");
list_plugins = getFileList(dir_fiji);


for (i=0;i<list_plugins.length;i++){
	plugin_tofind1_tmp = matches(list_plugins[i], ".*BIOP.*");
	plugin_tofind2_tmp = matches(list_plugins[i], ".*bio-formats.*");
	plugin_tofind3_tmp = matches(list_plugins[i], ".*EMito_Metrix.*");
	if (plugin_tofind1_tmp == 1){
		plugin_tofind1 = 1;
	} else if (plugin_tofind2_tmp == 1){
		plugin_tofind2 = 1;
	} else if (plugin_tofind3_tmp == 1){
		plugin_tofind3 = 1;
	}
}


if ((plugin_tofind1 == 0) || (plugin_tofind2 == 0) || (plugin_tofind3 == 0)){
	error_plugin = 1;
}

if (error_plugin == 0){

print("Checking FIJI plugin configuration----------------------------- OK\n");
	
	//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	// Analysis settings
	//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	// Settings selection
	//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
		// Checking general settings
		//--------------------------------------------------------------------------------------------
	
	print("Checking software and environment configuration--------------------------- PROCESSING");
	
	choice0 = newArray("Yes", "No");
	Dialog.create("Plugin execution : PRE-REQUEST ");
	Dialog.addMessage("Please check the following PLUGIN CONFIGURATION");
	Dialog.addMessage("\n1- SOFTWARE CONFIGURATION :");
	Dialog.addChoice("Python environment..............installed ?",choice0,"No");
	Dialog.addChoice("Python dependencies..............installed ?",choice0,"No");
	Dialog.addChoice("Cellpose environment..............installed ?",choice0,"No");
	Dialog.addChoice("Cellpose-FIJI wrapper..............installed ?",choice0,"No");
	Dialog.addMessage("\n2- INPUT FILES & FOLDERS :");
	Dialog.addChoice("Folder tree..............checked ?",choice0,"No");
	Dialog.addChoice("Folder name..............checked ?",choice0,"No");
	Dialog.addChoice("File name..............checked ?",choice0,"No");
	Dialog.addMessage("\n3- OUTPUT FOLDERS :");
	Dialog.addChoice("Folder location..............checked ?",choice0,"No");
	Dialog.addMessage("\n4- SEGMENTATION PARAMETERS :");
	Dialog.addChoice("Mitochondria diameter..............checked ?",choice0,"No");
	Dialog.addChoice("Trained model to use..............checked ?",choice0,"No");
	//Dialog.addHelp("https://github.com/MathieuVigneau/EMito-Metrix");
	Dialog.addMessage("\n\n\n(See Help Button for plugin instructions and installation)");
	Dialog.show();
	parameters1 = Dialog.getChoice();
	parameters2 = Dialog.getChoice();
	parameters3 = Dialog.getChoice();
	parameters4 = Dialog.getChoice();
	parameters5 = Dialog.getChoice();
	parameters6 = Dialog.getChoice();
	parameters7 = Dialog.getChoice();
	parameters8 = Dialog.getChoice();
	parameters9 = Dialog.getChoice();
	parameters10 = Dialog.getChoice();
	
		
	if ((parameters1 == "No") || (parameters2 == "No") || (parameters3 == "No") || (parameters4 == "No") || (parameters5 == "No") || (parameters6 == "No") || (parameters7 == "No") || (parameters8 == "No") || (parameters9 == "No") || (parameters10 == "No")){
		error_configuration = 1;
	}
		
	if (error_configuration == 0){
		
		print("Checking software and environment configuration--------------------------- OK\n");
		
		Dialog.create("Plugin configuration");
		Dialog.addMessage("Select folder with your CELLPOSE VIRTUAL ENVIRONMENT");
		Dialog.addDirectory("CELLPOSE folder", "");
		Dialog.addMessage("\n Did you install Cellpose with GPU computing ?");
		Dialog.addChoice("GPU computing ?",choice0,"No");
		//Dialog.addHelp("https://github.com/MathieuVigneau/EMito-Metrix");
		Dialog.addMessage("\n\n\n(See Help Button for plugin instructions and installation)");
		Dialog.show();
		directory_VE = Dialog.getString();
		gpu_choice = Dialog.getChoice();
		dir_python_tmp = dir_fiji+"EMito_Metrix/";
		dir_python = dir_python_tmp+"data_computation.py";
		
		
		// Checking both python and cellpose folder validity
		//--------------------------------------------------------------
		
		list_python_files = getFileList(dir_python_tmp);
		python_algo = 0;
		mod_GM = 0;
		mod_SM_fly = 0;
		mod_SM_mouse = 0;
		mod_SM_zebra = 0;
		mod_SM_human = 0;
		img = 0;
		
		print("Checking python and cellpose folders --------------------------- PROCESSING");
		
		while (((python_algo == 0) || (mod_GM == 0) || (mod_SM_fly == 0) || (mod_SM_mouse == 0) || (mod_SM_zebra == 0) || (mod_SM_human == 0)) && (img<list_python_files.length)){
			python_algo2 = matches(list_python_files[img], ".*data_computation.py");
			mod_GM2 = matches(list_python_files[img], ".*GeneralistModel_GM_EM.*");
			mod_SM_fly2 = matches(list_python_files[img], ".*SpecialistModel_SM_FLY_EM.*");
			mod_SM_mouse2 = matches(list_python_files[img], ".*SpecialistModel_SM_MOUSE_EM.*");
			mod_SM_zebra2 = matches(list_python_files[img], ".*SpecialistModel_SM_ZEBRAFISH_EM.*");
			mod_SM_human2 = matches(list_python_files[img], ".*SpecialistModel_SM_HUMAN_EM.*");
			if (python_algo2 == 1){
				python_algo = 1;
			}
			if (mod_GM2 == 1){
				mod_GM = 1;
			}
			if (mod_SM_fly2 == 1){
				mod_SM_fly = 1;
			}
			if (mod_SM_mouse2 == 1){
				mod_SM_mouse = 1;
			}
			if (mod_SM_zebra2 == 1){
				mod_SM_zebra = 1;
			}
			if (mod_SM_human2 == 1){
				mod_SM_human = 1;
			}
			img = img+1;
		}
		
		
		if ((python_algo == 0) || (mod_GM == 0) || (mod_SM_fly == 0) || (mod_SM_mouse == 0) || (mod_SM_zebra == 0) || (mod_SM_human == 0)){
			error_python_file = 1;
		}
		
		list_cellpose_files = getFileList(directory_VE+"/Scripts/");
		list_cellpose_files2 = getFileList(directory_VE+"/Lib/site-packages/");
		cellpose_appli = 0;
		cellpose_package = 0;
		img = 0;
		
		while ((cellpose_appli == 0) && (img<list_cellpose_files.length)){
			cellpose_appli2 = matches(list_cellpose_files[img], ".*cellpose.*");
			if (cellpose_appli2 == 1){
				cellpose_appli = 1;
			}
			img = img+1;
		}
		
		img = 0;
		while ((cellpose_package == 0) && (img<list_cellpose_files2.length)){
			cellpose_package2 = matches(list_cellpose_files2[img], ".*cellpose.*");
			if (cellpose_package2 == 1){
				cellpose_package = 1;
			}
			img = img+1;
		}
		
		if ((cellpose_appli == 0) || (cellpose_package == 0)){
			error_cellpose = 1;
		}
		
		
		if ((error_python_file == 0) && (error_cellpose == 0)){
			
			print("Checking python and cellpose folders --------------------------- OK\n");
			
			if (gpu_choice == "Yes"){
				run("Cellpose setup...", "cellposeenvdirectory="+directory_VE+" envtype=conda usegpu=true usemxnet=false usefastmode=false useresample=false version=2.0");
			} else if (gpu_choice == "No"){
				run("Cellpose setup...", "cellposeenvdirectory="+directory_VE+" envtype=conda usegpu=false usemxnet=false usefastmode=false useresample=false version=2.0");
			}
			
			run("Set Measurements...", "area mean standard min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction redirect=None decimal=3");
			intensity_type = "Darkest";
			setBackgroundColor(16777215);
			setForegroundColor(0);
			run("ROI Manager...");
			
			
			// Select workflow steps
			//--------------------------------------------------------------------------------------------
			
			print("Setting General EMitoMetrix parameters - part1 --------------------------- PROCESSING");
			
			Dialog.create("Image analysis : General parameters");
			Dialog.addString("1- Enter the EXPERIMENTAL NAME :", ""); 
			Dialog.addMessage("\n2- Select WORKFLOW STEP to perform");
			Dialog.addChoice("Mitochondria Segmentation.........",choice0,"Yes");
			Dialog.addChoice("Morphology & Ultrastructure Analysis.........",choice0,"Yes");
			Dialog.addChoice("Metrics Display & Computation.........",choice0,"Yes");
			Dialog.addMessage("\n3- Select INPUT folder containing raw images to process");
			Dialog.addDirectory("INPUT directory", "");
			Dialog.addMessage("\n4- Select OUPUT folder containing output files");
			Dialog.addDirectory("OUTPUT directory", "");
			//Dialog.addHelp("https://github.com/MathieuVigneau/EMito-Metrix");
			Dialog.addMessage("\n\n\n(See Help Button for plugin instructions and installation)");
			Dialog.show();
			condition_name = Dialog.getString();
			cellpose_choise = Dialog.getChoice();
			morpho_choice = Dialog.getChoice();
			prediction_choice = Dialog.getChoice();
			dir = Dialog.getString();
			dir2 = Dialog.getString();
			
			print("Setting General EMitoMetrix parameters - part1 --------------------------- OK\n");
			
			
			
			// Checking both input and output folders 
			//---------------------------------------------------------------------------------
			
			print("Checking input and output folders --------------------------- PROCESSING");
			
			list_dataset_in = getFileList(dir);
			list_dataset_out = getFileList(dir2);
			folder_in = 0;
			folder_out_I = 1;
			folder_out_M = 1;
			folder_out_P = 1;
			folder_out_P2 = 1;
			folder_out_R = 1;
			folder_out_L = 1;
			folder_out_MA = 1;
			folder_out_MT = 1;
			img=0;
			
			if (list_dataset_in.length > 0){
				while ((folder_in == 0) && (img<list_dataset_in.length)){
					folder_in2 = matches(list_dataset_in[img], ".*/");
					if (folder_in2 == 1){
						folder_in = 1;
					}
					img = img+1; 
				}
			}
			
			img=0;
			if (list_dataset_out.length > 0){
				while (((folder_out_I == 1) || (folder_out_M == 1) || (folder_out_P == 1) || (folder_out_P2 == 1) || (folder_out_R == 1) || (folder_out_L == 1) || (folder_out_MA == 1) || (folder_out_MT == 1)) && (img<list_dataset_out.length)){
					folder_out2_I = matches(list_dataset_out[img], "Image_output/");
					folder_out2_M = matches(list_dataset_out[img], "Measurements/");
					folder_out2_P = matches(list_dataset_out[img], "Prediction_analysis/");
					folder_out2_P2 = matches(list_dataset_out[img], "Prediction_analysisspatial_clustering/");
					folder_out2_R = matches(list_dataset_out[img], "ROI_mito/");
					folder_out2_L = matches(list_dataset_out[img], "Log_files/");
					folder_out2_MA = matches(list_dataset_out[img], "Measurements_ALL/");
					folder_out2_MT = matches(list_dataset_out[img], "Measurements_TMP/");
					
					if (folder_out2_I == 0){
						folder_out_I = 0;
					} else if (folder_out2_I == 1){
						folder_out_I = 1;
					}
					if (folder_out2_M == 0){
						folder_out_M = 0;
					} else if (folder_out2_M == 1){
						folder_out_M = 1;
					}
					if (folder_out2_P == 0){
						folder_out_P = 0;
					} else if (folder_out2_P == 1){
						folder_out_P = 1;
					}
					if (folder_out2_P2 == 0){
						folder_out_P2 = 0;
					} else if (folder_out2_P2 == 1){
						folder_out_P2 = 1;
					}
					if (folder_out2_R == 0){
						folder_out_R = 0;
					} else if (folder_out2_R == 1){
						folder_out_R = 1;
					}
					if (folder_out2_L == 0){
						folder_out_L = 0;
					} else if (folder_out2_L == 1){
						folder_out_L = 1;
					}
					if (folder_out2_MA == 0){
						folder_out_MA = 0;
					} else if (folder_out2_MA == 1){
						folder_out_MA = 1;
					}
					if (folder_out2_MT == 0){
						folder_out_MT = 0;
					} else if (folder_out2_MT == 1){
						folder_out_MT = 1;
					}
					img = img+1; 
				}
			}
			
			if (folder_in == 0){
				error_input_tree = 1;
			}
			
			if ((folder_out_I == 0) && (folder_out_M == 0) && (folder_out_P == 0) && (folder_out_P2 == 0) && (folder_out_R == 0) && (folder_out_L == 0) && (folder_out_MA == 0) && (folder_out_MT == 0)){
				error_output_tree = 1;
			}
			
			
			if ((error_input_tree == 0) && (error_output_tree == 0)){
				
				print("Checking input and output folders --------------------------- OK\n");
			
			
				// Check the workflow conditions : segmentation
				//---------------------------------------------------------------------------------
				
				print("Checking workflow conditions --------------------------- PROCESSING");
				
				if (cellpose_choise == "No"){
					list_dataset2 = getFileList(dir2);
					if (list_dataset2.length == 0){
						cellpose_choise = "Yes";
					} else if (list_dataset2.length != 0){
						list_dataset3 = getFileList(dir2+"Image_output/cellpose_mask/");
						if (list_dataset3.length == 0){
							cellpose_choise = "Yes";
						} else if (list_dataset3.length != 0){
							list_img2 =  getFileList(dir2+"Image_output/cellpose_mask/"+list_dataset3[0]);
							if (list_img2.length == 0){
								cellpose_choise = "Yes";
							}
						}
					}
				}
				
				
				// Check the workflow conditions : metric analysis
				//---------------------------------------------------------------------------------
				
				if ((prediction_choice == "Yes") && (morpho_choice == "No")){
					list_dataset2 = getFileList(dir2);
					if (list_dataset2.length == 0){
						morpho_choice = "Yes";
					} else if (list_dataset2.length != 0){
						list_dataset4 = getFileList(dir2+"Measurements/");
						if (list_dataset4.length == 0){
							morpho_choice = "Yes";
						} else if (list_dataset4.length != 0){
							list_img3 =  getFileList(dir2+"Measurements/"+list_dataset4[0]);
							if (list_img3.length == 0){
								morpho_choice = "Yes";
							}
						}
					}
				}
				
				print("Checking workflow conditions --------------------------- OK\n");
				
				
				// Setting morphological analysis and data computation
				//--------------------------------------------------------------------------------------------
				
				print("Setting General EMitoMetrix parameters - part2 --------------------------- PROCESSING");
				
				choice = newArray("pixel","calibrated");
				choice2 = newArray("Same size","Variable size");
				choice2_bis = newArray("Depending on Condition","Depending on Image");
				choice3 = newArray("Standard score","Min-Max Scaling");
				cellpose_model = newArray("nuclei","cyto","cyto2","cyto3","Custom model");
				prediction_model = newArray("default","custom");
				custom_list = newArray("Select Model","GeneralistModel_GM_EM","SpecialistModel_SM_FLY_EM","SpecialistModel_SM_MOUSE_EM","SpecialistModel_SM_ZEBRAFISH_EM","SpecialistModel_SM_HUMAN_EM");
				Dialog.create("Image analysis : Parameters - part 1");
				Dialog.addMessage("1- GENERAL PARAMETERS");
				Dialog.addChoice("Unit of length for output", choice);
				if (cellpose_choise == "Yes"){
					Dialog.addChoice("Normalization method", choice3);
					Dialog.addMessage("\n2- MITOCHONDRIA SEGMENTATION");
					Dialog.addChoice("Mitochondria size :", choice2);
					if (prediction_choice == "Yes"){
						Dialog.addMessage("\n3- MORPHOLOGICAL ANALYSIS");
						Dialog.addChoice("MitoMetrics to compute", prediction_model);
						Dialog.addMessage("\n4- Data DISPLAY & COMPUTATION");
						Dialog.addChoice("Graphic to display", prediction_model);
					}
				} else if (cellpose_choise == "No"){
					if (prediction_choice == "Yes"){
						Dialog.addMessage("\n2- MORPHOLOGICAL ANALYSIS");
						Dialog.addChoice("Select Metrics to compute", prediction_model);
						Dialog.addMessage("\n3- Data DISPLAY & COMPUTATION");
						Dialog.addChoice("Select graphic to display", prediction_model);
					}
				}
				//Dialog.addHelp("https://github.com/MathieuVigneau/EMito-Metrix");
				Dialog.addMessage("\n\n\n(See Help Button for plugin instructions and installation)");
				Dialog.show();
				unit_length = Dialog.getChoice();
				if (cellpose_choise == "Yes"){
					norm_type = Dialog.getChoice();
					mito_size = Dialog.getChoice();
				} else {
					norm_type = NaN;
					mito_size = NaN;
				}
				if (prediction_choice == "Yes"){
					morpho_measure = Dialog.getChoice();
					prediction_method = Dialog.getChoice();
				} else {
					morpho_measure = NaN;
					prediction_method = NaN;
				}
				
				
				
				// Image calibration
				//--------------------------------------------------------------------------------------------
				
				if (unit_length == "calibrated"){
					Dialog.create("Image analysis : Pixel dimensions");
					Dialog.addMessage("Please fill out the following parameters:");
					Dialog.addString("Unit of Length","");
					Dialog.addNumber("Pixel Width", "0");
					Dialog.addNumber("Pixel Height", "0");
					Dialog.show();
					unit_of_length = Dialog.getString();
					pixel_width2 = Dialog.getNumber();
					pixel_height2 = Dialog.getNumber();
				} else if (unit_length == "pixel"){
					unit_of_length = unit_length;
					pixel_width2 = 1.0000;
					pixel_height2 = 1.0000;
				}
				
				print("Setting General EMitoMetrix parameters - part2 --------------------------- OK\n");
				
				
				
				// Cellpose settings
				//--------------------------------------------------------------------------------------------
			
				if (cellpose_choise == "Yes"){
										
					if (mito_size == "Same size"){
						
						print("Setting Mitochondria Segmentation parameters --------------------------- PROCESSING");
						
						objectsize_tmp = 0;
						Dialog.create("Automatic Mitochondria Segmentation");
						Dialog.addMessage("1- Select CELLPOSE TRAINED MODEL used for segmentation :");
						Dialog.addChoice("Default model to use", cellpose_model);
						Dialog.addMessage("\n2- If CUSTOM MODEL, select the model used for segmentation");
						Dialog.addChoice("Custom model to use", custom_list);
						Dialog.addMessage("\n3- Mitochondria diameter for segmentation (0 for automatic estimation)");
						Dialog.addNumber("Diameter (pixel)", "0");
						//Dialog.addHelp("https://github.com/MathieuVigneau/EMito-Metrix");
						Dialog.addMessage("\n\n\n(See Help Button for plugin instructions and installation)");
						Dialog.show();
						object_detection_type = Dialog.getChoice();
						custom_model = Dialog.getChoice();
						object_detection_size = Dialog.getNumber();
						
						if (isNaN(object_detection_size) == 1){
							error_cellpose_diameter = 1;
						}
						
						if (object_detection_type == "Custom model"){
							if (custom_model == "Select Model"){
								Dialog.create("Cellpose : custom model");
								Dialog.addMessage("Select CUSTOM MODEL used for segmentation :");
								Dialog.addChoice("Custom model to use", custom_list);
								Dialog.show();
								custom_model = Dialog.getChoice();
							}
							object_detection_type2 = dir_python_tmp+custom_model;
						}
						mito_size_type = NaN;
						
						if (error_cellpose_diameter == 0){
							print("Setting Mitochondria Segmentation parameters --------------------------- OK\n");
						}
					}
					
				} else {
					object_detection_type = NaN;
					custom_model = NaN;
					object_detection_size = NaN;
				}
				
				
				
				// Morphology and texture analysis : custom analysis
				//--------------------------------------------------------------------------------------------
				
				if (prediction_choice == "Yes"){
					
					print("Setting Morphology Analysis parameters --------------------------- PROCESSING");
					
					labels = newArray("Condition_Name", "Mito_ID", "Mito_CentroidX", "Mito_CentroidY", "Mito_Area", "Mito_Perimeter", "AreaPerimeter_Ratio",  "Mito_Circularity", "Mito_Roundness", "Mito_Solidity", "Mito_AR", "Mito_Feret_Diameter", "Mito_FeretX", "Mito_FeretY", "Mito_MeanInt", "Mito_MedianInt", "Mito_TotalInt", "Intensity_SD", "Intensity_SD_percent", "Mito_MeanInt_CORR", "Mito_MedianInt_CORR", "Mito_TotalInt_CORR", "Intensity_SD_CORR", "Intensity_SD_percent_CORR", "Skewness", "Kurtosis", "CristaeOrientation_Major", "CristaeOrientation_Minor","CristaeOrientation_Angle","CristaeOrientation_Area");
					labels1 = newArray("Condition_Name", "Mito_ID", "Mito_CentroidX", "Mito_CentroidY");
					labels2 = newArray("Mito_Area", "Mito_Perimeter", "AreaPerimeter_Ratio",  "Mito_Circularity", "Mito_Roundness", "Mito_Solidity", "Mito_AR", "Mito_Feret_Diameter", "Mito_FeretX", "Mito_FeretY");
					labels3 = newArray("Mito_MeanInt", "Mito_MedianInt", "Mito_TotalInt", "Intensity_SD", "Intensity_SD_percent");
					labels4 = newArray("Mito_MeanInt_CORR", "Mito_MedianInt_CORR", "Mito_TotalInt_CORR", "Intensity_SD_CORR", "Intensity_SD_percent_CORR");
					labels5 = newArray("Skewness", "Kurtosis", "CristaeOrientation_Major", "CristaeOrientation_Minor","CristaeOrientation_Angle","CristaeOrientation_Area");
					if (morpho_measure == "default"){
						default_metrics = "True"; 
						
					} else if (morpho_measure == "custom"){
						default_metrics = "False"; 
						string_arg = newArray(0);
						n_images = 30;
						compt_metrics = 0;
						fieldSize_X1 = 4;
						fieldSize_X2 = 5;
						fieldSize_X3 = 6;
						fieldSize_Y1 = 1;
						fieldSize_Y2 = 2;
						defaults = newArray(n_images);
						defaults1 = newArray(4);
						defaults2 = newArray(10);
						defaults3 = newArray(5);
						defaults4 = newArray(6);
						for (l=0; l<4; l++) {
			    			defaults1[l] = true;
						}
						for (l=0; l<10; l++) {
			    			defaults2[l] = true;
						}
						for (l=0; l<5; l++) {
			    			defaults3[l] = true;
						}
						for (l=0; l<6; l++) {
			    			defaults4[l] = true;
						}
						Dialog.create("Mitochondria Metrix Analysis");
						Dialog.addMessage("Select AT LEAST 3 mitochondria metrics to compute");
						Dialog.addMessage("\n\n1- GENERAL PARAMETERS :");
						Dialog.addCheckboxGroup(fieldSize_Y1,fieldSize_X1,labels1,defaults1);
						Dialog.addMessage("\n\n2- MORPHOLOGICAL MEASUREMENTS :");
						Dialog.addCheckboxGroup(fieldSize_Y2,fieldSize_X2,labels2,defaults2);
						Dialog.addMessage("\n\n3- TEXTURE MEASUREMENTS :");
						Dialog.addCheckboxGroup(fieldSize_Y1,fieldSize_X2,labels3,defaults3);
						Dialog.addMessage("\n\n3- TEXTURE MEASUREMENTS - CORRECTED :");
						Dialog.addCheckboxGroup(fieldSize_Y1,fieldSize_X2,labels4,defaults3);
						Dialog.addMessage("\n\n3- CRISTAE MEASUREMENTS :");
						Dialog.addCheckboxGroup(fieldSize_Y1,fieldSize_X3,labels5,defaults4);
						//Dialog.addHelp("https://github.com/MathieuVigneau/EMito-Metrix");
						Dialog.addMessage("\n\n\n(See Help Button for plugin instructions and installation)");
						Dialog.show();
						for (l=0; l<n_images; l++){
							defaults[l] = Dialog.getCheckbox();
						}
						for (l=0; l<n_images; l++){
							if (defaults[l] == true){
								compt_metrics = compt_metrics+1;
								string_arg = Array.concat(string_arg,"--"+labels[l]);
							}
						}
						
						if (compt_metrics == n_images){
							default_metrics = "True";
						}
						
						if (string_arg.length < 3){
							error_morpho_choice = 1;
						}
						
					}
					
					if (error_morpho_choice == 0){
						print("Setting Morphology Analysis parameters --------------------------- OK\n");
					}
				}
				
				
				// Mito Metrics Data computation : custom analysis
				//--------------------------------------------------------------------------------------------
				
				if (prediction_choice == "Yes"){
					
					print("Setting Data computation parameters --------------------------- PROCESSING");
					
					labels2 = newArray("PCA", "UMAP", "violin", "density", "histogram", "radar", "spatial_clustering");
					if (prediction_method == "default"){
						default_computation = "True"; 
						no_draw = "False";
						no_save = "False";
						
					} else if (prediction_method == "custom"){
						default_computation = "False"; 
						no_draw = "False";
						no_save = "False";
						string_arg2 = newArray(0);
						compt_graph = 0;
						n_images = 7;
						fieldSize_X = 7;
						fieldSize_Y = 1;
						defaults2 = newArray(n_images);
						for (l=0; l<n_images; l++) {
			    			defaults2[l] = true;
						}
						Dialog.create("Mito Metrics Data computation");
						Dialog.addMessage("Select at least 1 graph or data distribution to display");
						Dialog.addCheckboxGroup(fieldSize_Y,fieldSize_X,labels2,defaults2);
						Dialog.addCheckbox("Don't save output graphic",false);
						Dialog.addCheckbox("Don't display output graphic",false);
						//Dialog.addHelp("https://github.com/MathieuVigneau/EMito-Metrix");
						Dialog.addMessage("\n\n\n(See Help Button for plugin instructions and installation)");
						Dialog.show();
						for (l=0; l<n_images; l++){
							defaults2[l] = Dialog.getCheckbox();
						}
						save_graph = Dialog.getCheckbox();
						draw_graph = Dialog.getCheckbox();
						if ((save_graph == true) && (draw_graph == true)){
							no_save = "True";
						} else if ((save_graph == true) && (draw_graph == false)){
							no_save = "True";
						} else if ((save_graph == false) && (draw_graph == true)){
							no_draw = "True";
						}
						for (l=0; l<n_images; l++){
							if (defaults2[l] == true){
								compt_graph = compt_graph+1;
								string_arg2 = Array.concat(string_arg2,"--"+labels2[l]);
							}
						}
						
						if (compt_graph == n_images){
							default_computation = "True"; 
						}
						
						if (string_arg2.length == 0){
							error_prediction_choice = 1;
						}
						
					}
					
					if (error_prediction_choice == 0){
						print("Setting Data computation parameters --------------------------- OK\n");
					}
					
				}
				
				
				if ((error_prediction_choice == 0) && (error_morpho_choice == 0) && (error_cellpose_diameter == 0)){
									
			
			
					// Raw image selection (input) and output directory selection
					//---------------------------------------------------------------------------------------------------------------------------------
					
					if (cellpose_choise == "Yes"){
						File.makeDirectory(dir2+"/Image_output/");
						File.makeDirectory(dir2+"/Image_output/cellpose_mask");
						File.makeDirectory(dir2+"/Image_output/processed_images");
						File.makeDirectory(dir2+"/Image_output/control_quality_mask/");
						File.makeDirectory(dir2+"/Measurements/");
						File.makeDirectory(dir2+"/Prediction_analysis/");
						File.makeDirectory(dir2+"/Prediction_analysisspatial_clustering/");
						File.makeDirectory(dir2+"/ROI_mito/");
						File.makeDirectory(dir2+"/Log_files/");
						File.makeDirectory(dir2+"/Measurements_ALL/");
						File.makeDirectory(dir2+"/Measurements_TMP/");
					}
					
					
					
					// Configure image display during macro execution
					//---------------------------------------------------------------------------------------------------------------------------------
					
					Dialog.create("Macro Execution : Parameters");
					Dialog.addChoice("Live image displaying during macro execution ?", choice0, "No");
					Dialog.addMessage("Warning : displaying images will slow down macro execution");
					Dialog.show();
					displaying_mode = Dialog.getChoice();
					
					if (displaying_mode == "Yes"){
						setBatchMode(false);
					} else if (displaying_mode == "No"){
						setBatchMode(true);
					}
					
					
					
					// Log file configuration : user's parameters
					//-----------------------------------------------------------------------------------------------------------------------------------
					
					title_parameters = "Users_general_parameters"; 
					title_parameters = "["+title_parameters+"]"; 
					f=title_parameters; 
					run("New... ", "name="+title_parameters+" type=Table"); 
					print(f,"\\Headings:Cellpose Folder\tPlugin Folder\tExperiment Name\tSegmentation Analysis\tMorphometric Analysis\tData Comutation and Display\tInput Directory\tOutput Directory\tUnit of Length\tImage Normalization\tMito Size Mode\tMorphometric Selected\tGraph Selected\tPixel Width\tPixel Height");
					print(f,directory_VE+"\t"+dir_python_tmp+"\t"+condition_name+"\t"+cellpose_choise+"\t"+morpho_choice+"\t"+prediction_choice+"\t"+dir+"\t"+dir2+"\t"+unit_length+"\t"+norm_type+"\t"+mito_size+"\t"+morpho_measure+"\t"+prediction_method+"\t"+pixel_width2+"\t"+pixel_height2);
					match_name_log = 1;
					num_log = 0;
					while (match_name_log == 1){
						num_log = num_log+1;
						file_log_tmp = "Users_general_parameters_"+year+month+dayOfMonth+"_v"+num_log+".txt";
						match_name_log = File.exists(dir2+"/Log_files/"+file_log_tmp);
					}
					selectWindow("Users_general_parameters");
					save(dir2+"/Log_files/Users_general_parameters_"+year+month+dayOfMonth+"_v"+num_log+".txt");
					run("Close");
					
					
					
				
				//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
				
				
				
				
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				// Mitochondria detection & segmentation
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
				
					if (cellpose_choise == "Yes"){
						
						title_parameters2 = "Users_Mitochondria_size"; 
						title_parameters2 = "["+title_parameters2+"]"; 
						f2=title_parameters2; 
						run("New... ", "name="+title_parameters2+" type=Table"); 
						print(f2,"\\Headings:Condition Name\tImage Name\tMitochondria Size\tCellpose Trained Model\tCustom Trained Model");
						
						print("\nAUTOMATIC MITOCHONDRIA SEGMENTATION -------------------------------- STARTING");
						
						list_dataset = getFileList(dir);
						list_dataset = Array.sort(list_dataset);
						
						compt_folder = 0;
					
						for (i=0; i<list_dataset.length; i++){
							
							print("\n---------Condition "+list_dataset[i]+"-------------------------------- PROCESSING");
							
							folder_tmp = 0;
							folder_tmp = matches(list_dataset[i], ".*/");
							
							if (folder_tmp == 1){
								foldername_tmp = 0;
								foldername_tmp = matches(list_dataset[i], ".*[]!#$%&'()*,.:;<=>?@^`{|}~].*");
								
								if (foldername_tmp == 0){
									list_img = getFileList(dir+list_dataset[i]);
									list_img = Array.sort(list_img);
									
									if (list_img.length > 0){
									
										dataset=replace(list_dataset[i], "/", "");
										dataset=replace(dataset, " ", "_");
										dataset=replace(dataset, "-", "_");
										File.makeDirectory(dir2+"/Image_output/cellpose_mask/"+dataset);
										File.makeDirectory(dir2+"/Image_output/processed_images/"+dataset);
										File.makeDirectory(dir2+"/Measurements/"+dataset);
										File.makeDirectory(dir2+"/ROI_mito/"+dataset);
										File.makeDirectory(dir2+"/Image_output//control_quality_mask/"+dataset);
										
										if (mito_size == "Variable size"){
											
											print("----------------------------------Setting Segmentation parameters-------------------------- PROCESSING");
											
											Dialog.create("Automatic Mitochondria Segmentation - part1");
											Dialog.addMessage("Condition : "+dataset);
											Dialog.addMessage("\n2- MITOCHONDRIA SEGMENTATION");
											Dialog.addChoice("Mitochondria size :", choice2_bis);
											Dialog.show();
											mito_size2 = Dialog.getChoice();
																					
											Dialog.create("Automatic Mitochondria Segmentation - part2");
											Dialog.addMessage("Condition : "+dataset);
											Dialog.addMessage("1- Select CELLPOSE TRAINED MODEL to use for segmentation");
											Dialog.addChoice("Default model to use", cellpose_model);
											Dialog.addMessage("\n2- If CUSTOM MODEL, select the model used for segmentation");
											Dialog.addChoice("Custom model to use", custom_list);
											if (mito_size2 == "Depending on Condition"){
												Dialog.addMessage("\n3- Mitochondria diameter for segmentation (0 for automatic estimation)");
												Dialog.addNumber("Diameter for condition "+dataset+" :", 0);
											}
											//Dialog.addHelp("https://github.com/MathieuVigneau/EMito-Metrix");
											Dialog.addMessage("\n\n\n(See Help Button for plugin instructions and installation)");
											Dialog.show();
											object_detection_type = Dialog.getChoice();
											custom_model = Dialog.getChoice();
											if (mito_size2 == "Depending on Condition"){
												object_detection_size = Dialog.getNumber();
												if (isNaN(object_detection_size) == 1){
														error_cellpose_diameter = 1;
												}
											}
														
											if (object_detection_type == "Custom model"){
												if (custom_model == "Select Model"){
													Dialog.create("Cellpose : custom model");
													Dialog.addMessage("Select CUSTOM MODEL used for segmentation :");
													Dialog.addChoice("Custom model to use", custom_list);
													Dialog.show();
													custom_model = Dialog.getChoice();
												}
												object_detection_type2 = dir_python_tmp+custom_model;
											}
											
											if (mito_size2 == "Depending on Condition"){
												for (cha=0; cha<list_img.length; cha++){
													print(f2,dataset+"\t"+list_img[cha]+"\t"+object_detection_size+"\t"+object_detection_type+"\t"+custom_model);
												}
											}
											
											
											if (mito_size2 == "Depending on Image"){
												objectsize_tmp = 0;
												cond = 0;
												object_detection_size = newArray(list_img.length);
												
												for (cha=0; cha<list_img.length; cha++){
													Dialog.create("Automatic Mitochondria Segmentation - part3");
													Dialog.addMessage("Mitochondria diameter for segmentation (0 for automatic estimation)");
													Dialog.addNumber("Diameter for condition "+list_dataset[i]+" and image "+list_img[cha], 0);
													Dialog.show();
													object_detection_size[cha] = Dialog.getNumber();
													print(f2,dataset+"\t"+list_img[cha]+"\t"+object_detection_size[cha]+"\t"+object_detection_type+"\t"+custom_model);
												}
											
												while ((objectsize_tmp == 0) && (cond<list_img.length)){
													if (isNaN(object_detection_size[cond]) == 1){
														objectsize_tmp = 1;
														error_cellpose_diameter = 1;
													}
													cond = cond+1;
												}
											}
											
										} else if (mito_size == "Same size"){
											error_cellpose_diameter = 0;
											mito_size2 = NaN;
											for (cha=0; cha<list_img.length; cha++){
												print(f2,dataset+"\t"+list_img[cha]+"\t"+object_detection_size+"\t"+object_detection_type+"\t"+custom_model);
											}
											
										}
										
										
										if (error_cellpose_diameter == 0){
											
											print("----------------------------------Setting Segmentation parameters-------------------------- OK\n");
										
											// Image file type used for rawdata
											//----------------------------------------------------
											
											compt = 0;
											compt_img = 0;
											crop_value = 0;
											
											for (j=0; j<list_img.length; j++) {
												
												compt = compt+1;
												print("--------------------------------------Image "+compt+"/"+list_img.length+": "+list_img[j]+"-------------------------------- STARTING");
												
												imagename_tmp = 0;
												imagename_tmp = matches(list_img[j], ".*[]!#$%&'()/*,:;<=>?@^`{|}~].*");
												
												if (imagename_tmp == 0){
													extension_tmp = matches(list_img[j], ".*.tif|TIF");
													extension_tmp2 = matches(list_img[j], ".*.jpg|JPG");
													extension_tmp3 = matches(list_img[j], ".*.tiff|TIFF");
													extension_tmp4 = matches(list_img[j], ".*.png|PNG");
													extension_tmp5 = matches(list_img[j], ".*.jpeg|JPEG");
													extension_tmp6 = matches(list_img[j], ".*.bmp|BMP");
													
													
													if ((extension_tmp2 == 1) || (extension_tmp4 == 1) || (extension_tmp5 == 1)){
														print("File format WARNING: File format selected for "+list_img[j]+" has poor resolution compared to conventional format (TIFF).This can lead to lower quality results ");
													}
													
													
													if ((extension_tmp == 1) || (extension_tmp2 == 1) || (extension_tmp3 == 1) || (extension_tmp4 == 1) || (extension_tmp5 == 1) || (extension_tmp6 == 1)){
														
														if ((displaying_mode == "No") && (compt_img==0)){
														//if ((displaying_mode == "No") && (compt_img==0) && (compt_folder==0)){
															setBatchMode(false);
														}
														path = dir+list_dataset[i]+list_img[j];
														run("Bio-Formats Importer", "open=["+path+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
														index_tmp=indexOf(list_img[j],".");
														name_img=substring(list_img[j], 0, index_tmp);
														name_img=replace(name_img, " ", "");
														name_img=replace(name_img, "+", "");
														name_img=replace(name_img, "-", "_");
														rename(name_img);
														getDimensions(width, height, channels, slices, frames);
														if (channels > 1){
															selectWindow(name_img);
															run("RGB Color");
															selectWindow(name_img);
															close();
															selectWindow(name_img+" (RGB)");
															rename(name_img);
														}
														selectWindow(name_img);
														getDimensions(width, height, channels, slices, frames);
														Stack.setXUnit("pixel");
														run("Properties...", "channels="+channels+" slices="+slices+" frames="+frames+" pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000");
									
									
														// dimension reduction of native images
														//-------------------------------------------------------------------------------
														
														if (compt_img==0){
															crop_value=getBoolean("Do you need to crop your images ?");
															if (crop_value==1) {
																selectWindow(name_img);
																waitForUser("Select area to crop and click OK.\nIf you don't need to crop, simply click OK ");
																selectWindow(name_img);
																getSelectionBounds(x, y, width_crop, height_crop);
																makeRectangle(x, y, width_crop, height_crop);
																run("Crop");
																run("Select None");
															}
														} else {
															if (crop_value==1) {
																selectWindow(name_img);
																makeRectangle(x, y, width_crop, height_crop);
																run("Crop");
																run("Select None");
															}
														}
														
														
														print("--------------------------------------------------------------------------------------Cropping------------------------ OK");
														
														
														// Native image normalization
														//-------------------------------------------------------------------------------
														
														run("Measure");
														selectWindow("Results");
														min_value = getResult("Min",0);
														max_value = getResult("Max",0);
														max_value_scaling = (max_value-min_value);
														mean_value = getResult("Mean",0);
														sd_value = getResult("StdDev",0);
														run("Close");
														selectWindow(name_img);
														run("32-bit");
														if (norm_type == "Standard score"){
															run("Subtract...", "value="+mean_value);
															run("Divide...", "value="+sd_value);
														} else if (norm_type == "Min-Max Scaling"){
															run("Subtract...", "value="+min_value);
															run("Divide...", "value="+max_value_scaling);
														}
														saveAs("Tiff", dir2+"/Image_output/processed_images/"+dataset+"/"+name_img+"_preproc");
														rename(name_img);
														
														print("------------------------------------------------------------------------------------Preprocessing------------------------ OK");
														
														
														// Cellpose segmentation
														//---------------------------------------------------------------------------------------
														
														selectWindow(name_img);
														
														if ((mito_size == "Same size") || ((mito_size == "Variable size") && (mito_size2 == "Depending on Condition"))){
															if ((object_detection_type == "cyto2") || (object_detection_type == "cyto") || (object_detection_type == "cyto3")){
																run("Cellpose Advanced", "diameter="+object_detection_size+" cellproba_threshold=0.0 flow_threshold=0.4 anisotropy=1.0 diam_threshold=12.0 model="+object_detection_type+" nuclei_channel=0 cyto_channel=1 dimensionmode=2D stitch_threshold=-1.0 omni=false cluster=false additional_flags=");
															} else if (object_detection_type == "nuclei"){
																run("Cellpose Advanced", "diameter="+object_detection_size+" cellproba_threshold=0.0 flow_threshold=0.4 anisotropy=1.0 diam_threshold=12.0 model="+object_detection_type+" nuclei_channel=1 cyto_channel=0 dimensionmode=2D stitch_threshold=-1.0 omni=false cluster=false additional_flags=");
															} else if (object_detection_type == "Custom model"){
																run("Cellpose Advanced (custom model)", "diameter="+object_detection_size+" cellproba_threshold=0.0 flow_threshold=0.4 anisotropy=1.0 diam_threshold=12.0 model_path="+object_detection_type2+" model="+object_detection_type2+" nuclei_channel=2 cyto_channel=1 dimensionmode=2D stitch_threshold=-1.0 omni=false cluster=false additional_flags=");
															}
															
														} else if ((mito_size == "Variable size") && (mito_size2 == "Depending on Image")){
															if ((object_detection_type == "cyto2") || (object_detection_type == "cyto") || (object_detection_type == "cyto3")){
																run("Cellpose Advanced", "diameter="+object_detection_size[j]+" cellproba_threshold=0.0 flow_threshold=0.4 anisotropy=1.0 diam_threshold=12.0 model="+object_detection_type+" nuclei_channel=0 cyto_channel=1 dimensionmode=2D stitch_threshold=-1.0 omni=false cluster=false additional_flags=");
															} else if (object_detection_type == "nuclei"){
																run("Cellpose Advanced", "diameter="+object_detection_size[j]+" cellproba_threshold=0.0 flow_threshold=0.4 anisotropy=1.0 diam_threshold=12.0 model="+object_detection_type+" nuclei_channel=1 cyto_channel=0 dimensionmode=2D stitch_threshold=-1.0 omni=false cluster=false additional_flags=");
															}  else if (object_detection_type == "Custom model"){
																run("Cellpose Advanced (custom model)", "diameter="+object_detection_size[j]+" cellproba_threshold=0.0 flow_threshold=0.4 anisotropy=1.0 diam_threshold=12.0 model_path="+object_detection_type2+" model="+object_detection_type2+" nuclei_channel=2 cyto_channel=1 dimensionmode=2D stitch_threshold=-1.0 omni=false cluster=false additional_flags=");
															}
														}
														
														selectWindow(name_img);
														close();
														selectWindow(name_img+"-cellpose");
														saveAs("Tiff", dir2+"/Image_output/cellpose_mask/"+dataset+"/"+name_img+"_cp_masks");
														close();
														
														print("------------------------------------------------------------------------------------Segmentation------------------------ OK");
														
														if ((displaying_mode == "No") && (compt_img==0)){
														//if ((displaying_mode == "No") && (compt_img==0) && (compt_folder==0)){
															setBatchMode(true);
														}
														
														compt_img = compt_img+1;
														
													} else {
														print("Input WARNING: Invalid file format for "+list_img[j]+". Please convert input images using conventional format (TIF)"); 
														print("--------------------------------------------------------------------------------------------------------------------ABORTED\n");
													}
												
												} else if (imagename_tmp == 1){
													print("Input WARNING: Name violation for "+list_img[j]+". Image name containing non valid characters");
													print("-----------------------------------------------------------------------------------------------------------------------ABORTED\n");
												}
												
												print("---------------------------------------------------------------------------------------------------------------------------- ENDING\n");
												
											}
											
											compt_folder = compt_folder+1;
										
										} else if (error_cellpose_diameter == 1){
											print("Setting Mitochondria Segmentation parameters --------------------------- ERROR");
											print("---------- Invalid value for Mitochondria Diameter. Please set an interger number value");
											print("---------Condition "+list_dataset[i]+"---------------------------------- ABORTED\n");
										}
										
									} else if (list_img.length == 0){
										print("Input WARNING: No imput images for "+list_dataset[i]);
										print("---------Condition "+list_dataset[i]+"------------------------------------- ABORTED\n");
									}
								
								} else if (foldername_tmp == 1){
									print("Input WARNING: Name violation for "+list_dataset[i]+". Folder name containing non valid characters.");
									print("---------Condition "+list_dataset[i]+"---------------------------------- ABORTED\n");
								}
								
							} else if (folder_tmp == 0){
								print("Input WARNING: "+list_dataset[i]+" is not a valid folder.");
								print("---------Condition "+list_dataset[i]+"---------------------------------- ABORTED\n");
							}
							
							print("---------Condition "+list_dataset[i]+"---------------------------------- ENDING\n");
							
						}
						
						selectWindow("Users_Mitochondria_size");
						save(dir2+"/Log_files/Users_Mitochondria_size.txt");
						run("Close");
						
						print("AUTOMATIC MITOCHONDRIA SEGMENTATION -------------------------------- ENDING\n");
						
					}
				
				
				
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
				
				
				
				
				
				
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				// Morphological analysis and ultrastructure analysis : ROI selection
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
					
					if (morpho_choice == "Yes"){
						
						print("\nROI FILTERING AND SAVING -------------------------------- STARTING");
						
						list_dataset = getFileList(dir2+"/Image_output/cellpose_mask/");
						list_dataset = Array.sort(list_dataset);
						
						for (i=0; i<list_dataset.length; i++){
						
							list_dataset_cellpose = getFileList(dir2+"/Image_output/cellpose_mask/"+list_dataset[i]);
							list_dataset_cellpose = Array.sort(list_dataset_cellpose);
							dataset=replace(list_dataset[i], "/", "");
							
							print("---------Condition "+dataset+"---------------------------------- STARTING");
							compt = 0;
							
							for (j=0; j<list_dataset_cellpose.length; j++){
								
								compt = compt+1;
								path_mito = dir2+"/Image_output/cellpose_mask/"+list_dataset[i]+list_dataset_cellpose[j];
								run("Bio-Formats Importer", "open=["+path_mito+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
								index_tmp=indexOf(list_dataset_cellpose[j],"_cp_masks");
								name_img=substring(list_dataset_cellpose[j], 0, index_tmp);
								name_img_mito=name_img+"_cellpose";
								rename(name_img_mito);
								
								print("--------------------------------------Image "+compt+"/"+list_dataset_cellpose.length+": "+name_img+"-------------------------------- STARTING");
			
								path_rawimg = dir2+"/Image_output/processed_images/"+list_dataset[i]+name_img+"_preproc.tif";
								run("Bio-Formats Importer", "open=["+path_rawimg+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
								rename(name_img);
								
								selectWindow(name_img_mito);
								run("Measure");
								selectWindow("Results");
								num_roi = getResult("Max",0);
								run("Close");
								
								
								// ROI manager settings
								//--------------------------------------------------------------------------------------
														
								if (num_roi != 0){
									
									for (a=1;a<num_roi+1;a++){ 
										selectWindow(name_img_mito);
										run("Duplicate...", "title="+name_img_mito+"-1");
										selectWindow(name_img_mito+"-1");
										setAutoThreshold("Default dark");
										setThreshold(a, a);
										setOption("BlackBackground", true);
										run("Convert to Mask");
										run("Analyze Particles...", "size=10-Infinity show=Nothing exclude add");
										selectWindow(name_img_mito+"-1");
										close();
									}
									num_roi2 = roiManager("count");
									
									if (num_roi2 != 0){
										selectWindow(name_img);
										roiManager("Show All");
										roiManager("Show All without labels");
										RoiManager.setGroup(0);
										RoiManager.setPosition(0);
										roiManager("Set Color", "red");
										roiManager("Set Line Width", 1);
										run("Flatten");
										selectWindow(name_img);
										close();
										selectWindow(name_img+"-1");
										saveAs("Tiff", dir2+"Image_output/control_quality_mask/"+list_dataset[i]+name_img+"_CQ.tif");
										close();
										
										roiManager("Show None");
										roiManager("Save", dir2+"/ROI_mito/"+list_dataset[i]+"RoiSet_"+name_img+".zip");
										selectWindow(name_img_mito);
										close();
										roiManager("Deselect");
										roiManager("Delete");
										roiManager("reset");
									
									} else if (num_roi2 == 0){
										selectWindow(name_img_mito);
										close();
										selectWindow(name_img);
										close();
										File.delete(dir2+"/Image_output/cellpose_mask/"+list_dataset[i]+list_dataset_cellpose[j]);
										File.delete(dir2+"/Image_output/processed_images/"+list_dataset[i]+name_img+"_preproc.tif");
									}
									
									print("--------------------------------------------------------------------------------------------------------------ROIset recovery------------------------ OK\n");
											
											
								} else if (num_roi == 0){
									
									selectWindow(name_img_mito);
									close();
									selectWindow(name_img);
									close();
									File.delete(dir2+"/Image_output/cellpose_mask/"+list_dataset[i]+list_dataset_cellpose[j]);
									File.delete(dir2+"/Image_output/processed_images/"+list_dataset[i]+name_img+"_preproc.tif");
									
									print("No valid ROI for Image "+name_img+". Output files deleted for image"+name_img); 
									print("--------------------------------------------------------------------------------------------------------------ROIset recovery------------------------ ABORTED\n");
										
								}
								
								
							}
							
							print("---------Condition "+dataset+"---------------------------------- ENDING\n");
												
						}
						
						print("ROI FILTERING AND SAVING -------------------------------- ENDING\n");
						
					}
				
					
					
					
					//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					// Morphological analysis and ultrastructure analysis : Fiji analysis
					//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
					if (morpho_choice == "Yes"){
						
						//if (displaying_mode == "No"){
						//	setBatchMode(false);
						//}
									
						print("\nMITOCHONDRIA MORPHOLOGY ANALYSIS -------------------------------- STARTING");
					
						list_dataset = getFileList(dir2+"/Measurements/");
						list_dataset = Array.sort(list_dataset);
						
						for (i=0; i<list_dataset.length; i++){
							
							dataset=replace(list_dataset[i], "/", "");
							
							print("---------Condition "+dataset+"---------------------------------- STARTING");
							
							title1b = "Mitochondries_measurements_ALL"; 
							title2b = "["+title1b+"]"; 
							f2=title2b; 
							run("New... ", "name="+title2b+" type=Table"); 
							print(f2,"\\Headings:Experiment_Name\tCondition_Name\tImage_Name\tMito_TotalNumber\tMito_Density\tMito_TotalArea_Percent\tMito_Area\tMito_Perimeter\tAreaPerimeter_MeanRatio_M\tMito_MeanInt\tMito_MedianInt\tIntensity_SD\tIntensity_SDpercent\tMito_MeanInt_CORR\tMito_MedianInt_CORR\tIntensity_SD_CORR\tIntensity_SDpercent_CORR\tMito_Circularity\tMito_Roundness\tMito_Solidity\tMito_AR\tMito_Feret_Diameter\tSkewness\tKurtosis\tCristaeOrientation_Major\tCristaeOrientation_Minor\tCristaeOrientation_Angle\tCristaeOrientation_Area");

								
							list_img = getFileList(dir2+"/Image_output/processed_images/"+list_dataset[i]);
							list_img = Array.sort(list_img);
							
							
							
							
							// ultrastructure analysis
							//--------------------------------------------------------------------------------------
							
							compt = 0;
							for (j=0; j<list_img.length; j++){
							
								compt = compt+1;
								title1 = "Mitochondries_measurements"; 
								title2 = "["+title1+"]"; 
								f=title2; 
								run("New... ", "name="+title2+" type=Table"); 
								print(f,"\\Headings:Experiment_Name\tCondition_Name\tImage_Name\tMito_ID\tMito_Area\tMito_Perimeter\tAreaPerimeter_Ratio\tMito_MeanInt\tMito_MeanInt_CORR\tMito_MedianInt\tMito_MedianInt_CORR\tMito_TotalInt\tMito_TotalInt_CORR\tIntensity_SD\tIntensity_SD_CORR\tIntensity_SD_percent\tIntensity_SD_percent_CORR\tMito_CentroidX\tMito_CentroidY\tMito_Circularity\tMito_Roundness\tMito_Solidity\tMito_AR\tMito_Feret_Diameter\tMito_FeretX\tMito_FeretY\tSkewness\tKurtosis\tCristaeOrientation_Major\tCristaeOrientation_Minor\tCristaeOrientation_Angle\tCristaeOrientation_Area");
					
								path_rawimg = dir2+"/Image_output/processed_images/"+list_dataset[i]+list_img[j];
								run("Bio-Formats Importer", "open=["+path_rawimg+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
								index_tmp=indexOf(list_img[j],"_preproc");
								name_img_raw=substring(list_img[j], 0, index_tmp);
								rename(name_img_raw);
								getDimensions(width, height, channels, slices, frames);
								Stack.setXUnit(unit_of_length);
								run("Properties...", "channels="+channels+" slices="+slices+" frames="+frames+" pixel_width="+pixel_width2+" pixel_height="+pixel_height2+" voxel_depth=1.0000");
								image_size = (width*pixel_width2)*(height*pixel_height2);
								
								print("--------------------------------------Image "+compt+"/"+list_img.length+": "+name_img_raw+"---------------------------------------- STARTING");
								
								path_roi = dir2+"/ROI_mito/"+list_dataset[i]+"RoiSet_"+name_img_raw+".zip";
								roiManager("Open", path_roi);
								num_roi = roiManager("count");
								
								if (num_roi != 0){
									
									roiManager("deselect");
									Mito_Area_T = 0;
									Mito_Perimeter_T = 0;
									AreaPerimeter_Ratio_T = 0;
									Mito_MeanInt_T = 0;
									Mito_MedianInt_T = 0;
									Intensity_SD_T = 0;
									Intensity_SD_percent_T = 0;
									Mito_MeanInt_CORR_T = 0;
									Mito_MedianInt_CORR_T = 0;
									Intensity_SD_CORR_T = 0;
									Intensity_SD_percent_CORR_T = 0;
									Mito_Circularity_T = 0;
									Mito_Roundness_T = 0;
									Mito_Solidity_T = 0;
									Mito_AR_T = 0;
									Mito_Feret_Diameter_T = 0;
									Skewness_T = 0;
									Kurtosis_T = 0;
									mito_Major_T = 0;
									mito_Minor_T = 0;
									mito_Angle_T = 0;
									mito_FTT_Area_T = 0;
									
									selectWindow(name_img_raw);
									run("Duplicate...", "title="+name_img_raw+"-1");
									selectWindow(name_img_raw+"-1");
									run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=*None* fast_(less_accurate)");
									
									
									// Intensity and Cristae measurement after frequential correction (FFT)
									//-------------------------------------------------------------
									
									for (a=0;a<num_roi;a++){ 
										
										selectWindow(name_img_raw);
										roiManager("Select", a);
										roiManager("Measure");
										selectWindow(name_img_raw);
										run("FFT");
										selectWindow("FFT of "+name_img_raw);
										rename("FFT_"+name_img_raw);
										run("Duplicate...", "title=FFT_"+name_img_raw+"-2");
										selectWindow("FFT_"+name_img_raw+"-2");
										setAutoThreshold("MaxEntropy no-reset");
										run("Convert to Mask");
										run("Invert");
										run("Create Selection");
										selectWindow("FFT_"+name_img_raw);
										run("Restore Selection");
										run("Clear Outside");
										run("Select None");
										run("Inverse FFT");
										selectWindow("FFT_"+name_img_raw);
										close();
										selectWindow("FFT_"+name_img_raw+"-2");
										close();
										selectWindow("Inverse FFT of FFT_"+name_img_raw);
										rename("Inverse_FFT_"+name_img_raw);
										roiManager("Select", a);
										roiManager("Measure");
										selectWindow("Inverse_FFT_"+name_img_raw);
										close();
										
										
										// Cristae orientation measurement
										//---------------------------------------------------------------
										
										selectWindow(name_img_raw+"-1");
										roiManager("Select", a);
										run("FFT");
										selectWindow("FFT of "+name_img_raw+"-1");
										rename("FFT_"+name_img_raw+"-1");
										setAutoThreshold("MaxEntropy no-reset");
										run("Convert to Mask");
										run("Invert");
										run("Create Selection");
										run("Measure");
										selectWindow("FFT_"+name_img_raw+"-1");
										close();
										roiManager("Deselect");
										selectWindow(name_img_raw);
										run("Select None");
										selectWindow(name_img_raw+"-1");
										run("Select None");
									}
									
									
									// Morphological and texture measurements
									//----------------------------------------------------------------------
									
									for (a=0;a<num_roi;a++){ 
										
										num = a*3;
										selectWindow("Results");
										mito_Area = getResult("Area",num);
										mito_Perimeter = getResult("Perim.",num);
										mito_Mean = getResult("Mean",num);
										mito_Median = getResult("Median",num);
										Area_Perimeter_Ratio = mito_Area/mito_Perimeter;
										mito_Int = getResult("RawIntDen",num);
										sd_int = getResult("StdDev",num);
										mean_var = (sd_int/mito_Mean)*100;
										mito_CX = getResult("X",num);
										mito_CY = getResult("Y",num);
										mito_Circ = getResult("Circ.",num);
										mito_Round = getResult("Round",num);
										mito_Solidity = getResult("Solidity",num);
										mito_AR = getResult("AR",num);
										mito_Feret = getResult("Feret",num);
										mito_FeretX = getResult("FeretX",num);
										mito_FeretY = getResult("FeretY",num);
										mito_Skewness = getResult("Skew",num);
										mito_Kurtosis = getResult("Kurt",num);
										mito_Mean_CORR = getResult("Mean",num+1);
										mito_Median_CORR = getResult("Median",num+1);
										mito_Int_CORR = getResult("RawIntDen",num+1);
										sd_int_CORR = getResult("StdDev",num+1);
										mean_var_CORR = (sd_int_CORR/mito_Mean_CORR)*100;
										if (isNaN(mito_Mean_CORR) == 1){
											mito_Mean_CORR = "";
										}
										if (isNaN(mito_Median_CORR) == 1){
											mito_Median_CORR = "";
										}
										if (isNaN(mito_Int_CORR) == 1){
											mito_Int_CORR = "";
										}
										if (isNaN(sd_int_CORR) == 1){
											sd_int_CORR = "";
										}
										if (isNaN(mean_var_CORR) == 1){
											mean_var_CORR = "";
										}
										
										mito_Major = getResult("Major",num+2);
										if (isNaN(mito_Major) == 1){
											mito_Major = "";
										}
										mito_Minor = getResult("Minor",num+2);
										if (isNaN(mito_Minor) == 1){
											mito_Minor = "";
										}
										mito_Angle = getResult("Angle",num+2);
										if (isNaN(mito_Angle) == 1){
											mito_Angle = "";
										}
										mito_FFT_Area = getResult("Area",num+2);
										if (isNaN(mito_FFT_Area) == 1){
											mito_FFT_Area = "";
										}
										mito_id = a+1;
										
										
											
										if ((mito_Area > 10) && (isNaN(mito_Mean_CORR) == 0) && (isNaN(mito_Median_CORR) == 0) && (isNaN(mito_Int_CORR) == 0) && (isNaN(sd_int_CORR) == 0) && (isNaN(mean_var_CORR) == 0) && (isNaN(mito_Major) == 0) && (isNaN(mito_Minor) == 0) && (isNaN(mito_Angle) == 0) && (isNaN(mito_FFT_Area) == 0)){
											
											print(f,condition_name+"\t"+dataset+"\t"+name_img_raw+"\t"+mito_id+"\t"+mito_Area+"\t"+mito_Perimeter+"\t"+Area_Perimeter_Ratio+"\t"+mito_Mean+"\t"+mito_Mean_CORR+"\t"+mito_Median+"\t"+mito_Median_CORR+"\t"+mito_Int+"\t"+mito_Int_CORR+"\t"+sd_int+"\t"+sd_int_CORR+"\t"+mean_var+"\t"+mean_var_CORR+"\t"+mito_CX+"\t"+mito_CY+"\t"+mito_Circ+"\t"+mito_Round+"\t"+mito_Solidity+"\t"+mito_AR+"\t"+mito_Feret+"\t"+mito_FeretX+"\t"+mito_FeretY+"\t"+mito_Skewness+"\t"+mito_Kurtosis+"\t"+mito_Major+"\t"+mito_Minor+"\t"+mito_Angle+"\t"+mito_FFT_Area);
											
											Mito_Area_T = Mito_Area_T + mito_Area;
											Mito_Perimeter_T = Mito_Perimeter_T + mito_Perimeter;
											AreaPerimeter_Ratio_T = AreaPerimeter_Ratio_T + Area_Perimeter_Ratio;
											Mito_MeanInt_T = Mito_MeanInt_T + mito_Mean;
											Mito_MedianInt_T = Mito_MedianInt_T + mito_Median;
											Intensity_SD_T = Intensity_SD_T + sd_int;
											Intensity_SD_percent_T = Intensity_SD_percent_T + mean_var;
											Mito_MeanInt_CORR_T = Mito_MeanInt_CORR_T + mito_Mean_CORR;
											Mito_MedianInt_CORR_T = Mito_MedianInt_CORR_T + mito_Median_CORR;
											Intensity_SD_CORR_T = Intensity_SD_CORR_T + sd_int_CORR;
											Intensity_SD_percent_CORR_T = Intensity_SD_percent_CORR_T + mean_var_CORR;
											Mito_Circularity_T = Mito_Circularity_T + mito_Circ;
											Mito_Roundness_T = Mito_Roundness_T + mito_Round;
											Mito_Solidity_T = Mito_Solidity_T + mito_Solidity;
											Mito_AR_T = Mito_AR_T + mito_AR;
											Mito_Feret_Diameter_T = Mito_Feret_Diameter_T + mito_Feret;
											Skewness_T = Skewness_T + mito_Skewness;
											Kurtosis_T = Kurtosis_T + mito_Kurtosis;
											mito_Major_T = mito_Major_T + mito_Major;
											mito_Minor_T = mito_Minor_T + mito_Minor;
											mito_Angle_T = mito_Angle_T + mito_Angle;
											mito_FTT_Area_T = mito_FTT_Area_T + mito_FFT_Area;
										}	
										
										
										
									}
									
									selectWindow("Results");
									run("Close");
									selectWindow(name_img_raw+"-1");
									close();
									selectWindow("Mitochondries_measurements");
									save(dir2+"/Measurements/"+list_dataset[i]+name_img_raw+"_MITO_measurements.txt"); 
									run("Close");
									
									
									Mito_Area_M = Mito_Area_T/num_roi;
									Mito_Perimeter_M = Mito_Perimeter_T/num_roi;
									AreaPerimeter_Ratio_M = AreaPerimeter_Ratio_T/num_roi;
									Mito_MeanInt_M = Mito_MeanInt_T/num_roi;
									Mito_MedianInt_M = Mito_MedianInt_T/num_roi;
									Intensity_SD_M = Intensity_SD_T/num_roi;
									Intensity_SD_percent_M = Intensity_SD_percent_T/num_roi;
									Mito_MeanInt_CORR_M = Mito_MeanInt_CORR_T/num_roi;
									Mito_MedianInt_CORR_M = Mito_MedianInt_CORR_T/num_roi;
									Intensity_SD_CORR_M = Intensity_SD_CORR_T/num_roi;
									Intensity_SD_percent_CORR_M = Intensity_SD_percent_CORR_T/num_roi;
									Mito_Circularity_M = Mito_Circularity_T/num_roi;
									Mito_Roundness_M = Mito_Roundness_T/num_roi;
									Mito_Solidity_M = Mito_Solidity_T/num_roi;
									Mito_AR_M = Mito_AR_T/num_roi;
									Mito_Feret_Diameter_M = Mito_Feret_Diameter_T/num_roi;
									Skewness_M = Skewness_T/num_roi;
									Kurtosis_M = Kurtosis_T/num_roi;
									mito_Major_M = mito_Major_T/num_roi;
									mito_Minor_M = mito_Minor_T/num_roi;
									mito_Angle_M = mito_Angle_T/num_roi;
									mito_FTT_Area_M = mito_FTT_Area_T/num_roi;
									Mito_density = num_roi/image_size;
									Mito_Area_Percent = (Mito_Area_T/image_size)*100;
									
									
									print(f2,condition_name+"\t"+dataset+"\t"+name_img_raw+"\t"+num_roi+"\t"+Mito_density+"\t"+Mito_Area_Percent+"\t"+Mito_Area_M+"\t"+Mito_Perimeter_M+"\t"+AreaPerimeter_Ratio_M+"\t"+Mito_MeanInt_M+"\t"+Mito_MedianInt_M+"\t"+Intensity_SD_M+"\t"+Intensity_SD_percent_M+"\t"+Mito_MeanInt_CORR_M+"\t"+Mito_MedianInt_CORR_M+"\t"+Intensity_SD_CORR_M+"\t"+Intensity_SD_percent_CORR_M+"\t"+Mito_Circularity_M+"\t"+Mito_Roundness_M+"\t"+Mito_Solidity_M+"\t"+Mito_AR_M+"\t"+Mito_Feret_Diameter_M+"\t"+Skewness_M+"\t"+Kurtosis_M+"\t"+mito_Major_M+"\t"+mito_Minor_M+"\t"+mito_Angle_M+"\t"+mito_FTT_Area_M);
									
									
									
									print("----------------------------------------------------------------------------------------------------Morphological analysis-------------------------OK");
									
								} else if (num_roi == 0){
									print("No valid ROI for Image "+name_img+". Morphological analysis aborted"); 
									print("----------------------------------------------------------------------------------------------------Morphological analysis------------------------ ABORTED");
								}
								
								roiManager("Deselect");
								roiManager("Delete");
								roiManager("reset");
								selectWindow(name_img_raw);
								close();
								
								
								print("----------------------------------------------------------------------------------------------------Saving morphological measurements-------------------------OK");
								
							}
							
							selectWindow("Mitochondries_measurements_ALL");
							save(dir2+"/Measurements_ALL/"+dataset+"_MITO_measurements_ALL_IMAGES.txt"); 
							run("Close");
							
							print("---------Condition "+dataset+"---------------------------------- ENDING\n");
							
						}
						
						print("MITOCHONDRIA MORPHOLOGY ANALYSIS -------------------------------- ENDING\n");
						
						if (displaying_mode == "No"){
							setBatchMode(false);
						}
						
						if (displaying_mode == "No"){
							setBatchMode(true);
						}
						
					}
					
					
					
					//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					// Data computation analysis : Python
					//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
					if (prediction_choice == "Yes"){
						
						print("MITOMETRIX DATA DISPLAY & COMPUTATION -------------------------------- STARTING");
						
						
						// Data or condition selection for data display and computation
						//-----------------------------------------------------------------------
						
						list_dataset = getFileList(dir2+"/Measurements/");
						list_dataset = Array.sort(list_dataset);
						labels_cond = newArray(0);
						
						for (i=0;i<list_dataset.length;i++){
							dataset=replace(list_dataset[i], "/", "");
							labels_cond = Array.concat(labels_cond,dataset);
						}
						
						n_cond = list_dataset.length;
						fieldSize_X_cond = list_dataset.length;
						fieldSize_Y_cond = 1;
						defaults_cond = newArray(n_cond);
						for (l=0; l<n_cond; l++) {
				    		defaults_cond[l] = true;
						}
						Dialog.create("Mito Metrics Data computation");
						Dialog.addMessage("Select at least one condition to use for data visualization");
						Dialog.addCheckboxGroup(fieldSize_Y_cond,fieldSize_X_cond,labels_cond,defaults_cond);
						//Dialog.addHelp("https://github.com/MathieuVigneau/EMito-Metrix");
						Dialog.addMessage("\n\n\n(See Help Button for plugin instructions and installation)");
						Dialog.show();
						for (l=0; l<n_cond; l++){
							defaults_cond[l] = Dialog.getCheckbox();
						}
						
						for (l=0; l<n_cond; l++){
							if (defaults_cond[l] == true){
								File.makeDirectory(dir2+"/Measurements_TMP/"+labels_cond[l]);
								list_txt = getFileList(dir2+"/Measurements/"+labels_cond[l]);
								for (l2=0;l2<list_txt.length;l2++){
									File.copy(dir2+"/Measurements/"+labels_cond[l]+"/"+list_txt[l2], dir2+"/Measurements_TMP/"+labels_cond[l]+"/"+list_txt[l2])
								}
							}
						}
							
						
						if (displaying_mode == "No"){
							setBatchMode(false);
						}
						
						dir_prediction = dir2+"Prediction_analysis";
						dir_input = dir2+"Measurements_TMP";
						
						if (default_metrics == "True"){
							if (default_computation == "True"){
								exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--default-cols", "--all-figs");
							} else if ((default_computation == "False") && (no_draw == "False") && (no_save == "False")){
								if (string_arg2.length == 1){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], "--default-cols");
								} else if (string_arg2.length == 2){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], "--default-cols");
								} else if (string_arg2.length == 3){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], "--default-cols");
								} else if (string_arg2.length == 4){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], "--default-cols");
								} else if (string_arg2.length == 5){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], "--default-cols");
								} else if (string_arg2.length == 6){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], "--default-cols");
								}
								
							} else if ((default_computation == "False") && (no_draw == "True")){
								if (no_save == "True"){
									if (string_arg2.length == 1){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], "--default-cols", "--no-draw", "--no-save");
									} else if (string_arg2.length == 2){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], "--default-cols", "--no-draw", "--no-save");
									} else if (string_arg2.length == 3){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], "--default-cols", "--no-draw", "--no-save");
									} else if (string_arg2.length == 4){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], "--default-cols", "--no-draw", "--no-save");
									} else if (string_arg2.length == 5){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], "--default-cols", "--no-draw", "--no-save");
									} else if (string_arg2.length == 6){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], "--default-cols", "--no-draw", "--no-save");
									}
								} else if (no_save == "False"){
									if (string_arg2.length == 1){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], "--default-cols", "--no-draw");
									} else if (string_arg2.length == 2){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], "--default-cols", "--no-draw");
									} else if (string_arg2.length == 3){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], "--default-cols", "--no-draw");
									} else if (string_arg2.length == 4){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], "--default-cols", "--no-draw");
									} else if (string_arg2.length == 5){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], "--default-cols", "--no-draw");
									} else if (string_arg2.length == 6){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], "--default-cols", "--no-draw");
									}
								}
							} else if ((default_computation == "False") && (no_save == "True") && (no_draw == "False")){
								if (string_arg2.length == 1){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], "--default-cols", "--no-save");
								} else if (string_arg2.length == 2){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], "--default-cols", "--no-save");
								} else if (string_arg2.length == 3){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], "--default-cols", "--no-save");
								} else if (string_arg2.length == 4){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], "--default-cols", "--no-save");
								} else if (string_arg2.length == 5){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], "--default-cols", "--no-save");
								} else if (string_arg2.length == 6){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], "--default-cols", "--no-save");
								}
							}
						} else if (default_metrics == "False"){
							if (default_computation == "True"){
								if (string_arg.length == 3){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2]);
								} else if (string_arg.length == 4){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3]);
								} else if (string_arg.length == 5){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4]);
								} else if (string_arg.length == 6){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5]);
								} else if (string_arg.length == 7){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6]);
								} else if (string_arg.length == 8){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7]);
								} else if (string_arg.length == 9){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figsr", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8]);
								} else if (string_arg.length == 10){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9]);
								} else if (string_arg.length == 11){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10]);
								} else if (string_arg.length == 12){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11]);
								} else if (string_arg.length == 13){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12]);
								} else if (string_arg.length == 14){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13]);
								} else if (string_arg.length == 15){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14]);
								} else if (string_arg.length == 16){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15]);
								} else if (string_arg.length == 17){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16]);
								} else if (string_arg.length == 18){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17]);
								} else if (string_arg.length == 19){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18]);
								} else if (string_arg.length == 20){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19]);
								} else if (string_arg.length == 21){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20]);
								} else if (string_arg.length == 22){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21]);
								} else if (string_arg.length == 23){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22]);
								} else if (string_arg.length == 24){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23]);
								} else if (string_arg.length == 25){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24]);
								} else if (string_arg.length == 26){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25]);
								} else if (string_arg.length == 27){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26]);
								} else if (string_arg.length == 28){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27]);
								} else if (string_arg.length == 29){
									exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, "--all-figs", string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28]);
								}
							} else if ((default_computation == "False") && (no_draw == "False") && (no_save == "False")){
								if (string_arg2.length == 1){
									if (string_arg.length == 3){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2]);
									} else if (string_arg.length == 4){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3]);
									} else if (string_arg.length == 5){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4]);
									} else if (string_arg.length == 6){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5]);
									} else if (string_arg.length == 7){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6]);
									} else if (string_arg.length == 8){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7]);
									} else if (string_arg.length == 9){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8]);
									} else if (string_arg.length == 10){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9]);
									} else if (string_arg.length == 11){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10]);
									} else if (string_arg.length == 12){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11]);
									} else if (string_arg.length == 13){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12]);
									} else if (string_arg.length == 14){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13]);
									} else if (string_arg.length == 15){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14]);
									} else if (string_arg.length == 16){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15]);
									} else if (string_arg.length == 17){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16]);
									} else if (string_arg.length == 18){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17]);
									} else if (string_arg.length == 19){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18]);
									} else if (string_arg.length == 20){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19]);
									} else if (string_arg.length == 21){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20]);
									} else if (string_arg.length == 22){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21]);
									} else if (string_arg.length == 23){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22]);
									} else if (string_arg.length == 24){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23]);
									} else if (string_arg.length == 25){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24]);
									} else if (string_arg.length == 26){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25]);
									} else if (string_arg.length == 27){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26]);
									} else if (string_arg.length == 28){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27]);
									} else if (string_arg.length == 29){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28]);
									}
								} else if (string_arg2.length == 2){
									if (string_arg.length == 3){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2]);
									} else if (string_arg.length == 4){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3]);
									} else if (string_arg.length == 5){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4]);
									} else if (string_arg.length == 6){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5]);
									} else if (string_arg.length == 7){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6]);
									} else if (string_arg.length == 8){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7]);
									} else if (string_arg.length == 9){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8]);
									} else if (string_arg.length == 10){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9]);
									} else if (string_arg.length == 11){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10]);
									} else if (string_arg.length == 12){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11]);
									} else if (string_arg.length == 13){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12]);
									} else if (string_arg.length == 14){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13]);
									} else if (string_arg.length == 15){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14]);
									} else if (string_arg.length == 16){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15]);
									} else if (string_arg.length == 17){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16]);
									} else if (string_arg.length == 18){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17]);
									} else if (string_arg.length == 19){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18]);
									} else if (string_arg.length == 20){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19]);
									} else if (string_arg.length == 21){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20]);
									} else if (string_arg.length == 22){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21]);
									} else if (string_arg.length == 23){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22]);
									} else if (string_arg.length == 24){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23]);
									} else if (string_arg.length == 25){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24]);
									} else if (string_arg.length == 26){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25]);
									} else if (string_arg.length == 27){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26]);
									} else if (string_arg.length == 28){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27]);
									} else if (string_arg.length == 29){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28]);
									}
								} else if (string_arg2.length == 3){
									if (string_arg.length == 3){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2]);
									} else if (string_arg.length == 4){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3]);
									} else if (string_arg.length == 5){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4]);
									} else if (string_arg.length == 6){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5]);
									} else if (string_arg.length == 7){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6]);
									} else if (string_arg.length == 8){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7]);
									} else if (string_arg.length == 9){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8]);
									} else if (string_arg.length == 10){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9]);
									} else if (string_arg.length == 11){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10]);
									} else if (string_arg.length == 12){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11]);
									} else if (string_arg.length == 13){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12]);
									} else if (string_arg.length == 14){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13]);
									} else if (string_arg.length == 15){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14]);
									} else if (string_arg.length == 16){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15]);
									} else if (string_arg.length == 17){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16]);
									} else if (string_arg.length == 18){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17]);
									} else if (string_arg.length == 19){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18]);
									} else if (string_arg.length == 20){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19]);
									} else if (string_arg.length == 21){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20]);
									} else if (string_arg.length == 22){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21]);
									} else if (string_arg.length == 23){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22]);
									} else if (string_arg.length == 24){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23]);
									} else if (string_arg.length == 25){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24]);
									} else if (string_arg.length == 26){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25]);
									} else if (string_arg.length == 27){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26]);
									} else if (string_arg.length == 28){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27]);
									} else if (string_arg.length == 29){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28]);
									}
								} else if (string_arg2.length == 4){
									if (string_arg.length == 3){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2]);
									} else if (string_arg.length == 4){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3]);
									} else if (string_arg.length == 5){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4]);
									} else if (string_arg.length == 6){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5]);
									} else if (string_arg.length == 7){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6]);
									} else if (string_arg.length == 8){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7]);
									} else if (string_arg.length == 9){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8]);
									} else if (string_arg.length == 10){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9]);
									} else if (string_arg.length == 11){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10]);
									} else if (string_arg.length == 12){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11]);
									} else if (string_arg.length == 13){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12]);
									} else if (string_arg.length == 14){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13]);
									} else if (string_arg.length == 15){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14]);
									} else if (string_arg.length == 16){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15]);
									} else if (string_arg.length == 17){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16]);
									} else if (string_arg.length == 18){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17]);
									} else if (string_arg.length == 19){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18]);
									} else if (string_arg.length == 20){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19]);
									} else if (string_arg.length == 21){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20]);
									} else if (string_arg.length == 22){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21]);
									} else if (string_arg.length == 23){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22]);
									} else if (string_arg.length == 24){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23]);
									} else if (string_arg.length == 25){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24]);
									} else if (string_arg.length == 26){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25]);
									} else if (string_arg.length == 27){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26]);
									} else if (string_arg.length == 28){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27]);
									} else if (string_arg.length == 29){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28]);
									}
								} else if (string_arg2.length == 5){
									if (string_arg.length == 3){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2]);
									} else if (string_arg.length == 4){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3]);
									} else if (string_arg.length == 5){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4]);
									} else if (string_arg.length == 6){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5]);
									} else if (string_arg.length == 7){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6]);
									} else if (string_arg.length == 8){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7]);
									} else if (string_arg.length == 9){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8]);
									} else if (string_arg.length == 10){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9]);
									} else if (string_arg.length == 11){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10]);
									} else if (string_arg.length == 12){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11]);
									} else if (string_arg.length == 13){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12]);
									} else if (string_arg.length == 14){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13]);
									} else if (string_arg.length == 15){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14]);
									} else if (string_arg.length == 16){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15]);
									} else if (string_arg.length == 17){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16]);
									} else if (string_arg.length == 18){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17]);
									} else if (string_arg.length == 19){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18]);
									} else if (string_arg.length == 20){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19]);
									} else if (string_arg.length == 21){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20]);
									} else if (string_arg.length == 22){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21]);
									} else if (string_arg.length == 23){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22]);
									} else if (string_arg.length == 24){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23]);
									} else if (string_arg.length == 25){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24]);
									} else if (string_arg.length == 26){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25]);
									} else if (string_arg.length == 27){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26]);
									} else if (string_arg.length == 28){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27]);
									} else if (string_arg.length == 29){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28]);
									}
								} else if (string_arg2.length == 6){
									if (string_arg.length == 3){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2]);
									} else if (string_arg.length == 4){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3]);
									} else if (string_arg.length == 5){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4]);
									} else if (string_arg.length == 6){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5]);
									} else if (string_arg.length == 7){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6]);
									} else if (string_arg.length == 8){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7]);
									} else if (string_arg.length == 9){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8]);
									} else if (string_arg.length == 10){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9]);
									} else if (string_arg.length == 11){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10]);
									} else if (string_arg.length == 12){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11]);
									} else if (string_arg.length == 13){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12]);
									} else if (string_arg.length == 14){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13]);
									} else if (string_arg.length == 15){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14]);
									} else if (string_arg.length == 16){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15]);
									} else if (string_arg.length == 17){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16]);
									} else if (string_arg.length == 18){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17]);
									} else if (string_arg.length == 19){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18]);
									} else if (string_arg.length == 20){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19]);
									} else if (string_arg.length == 21){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20]);
									} else if (string_arg.length == 22){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21]);
									} else if (string_arg.length == 23){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22]);
									} else if (string_arg.length == 24){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23]);
									} else if (string_arg.length == 25){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24]);
									} else if (string_arg.length == 26){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25]);
									} else if (string_arg.length == 27){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26]);
									} else if (string_arg.length == 28){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27]);
									} else if (string_arg.length == 29){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28]);
									}
								}
							} else if ((default_computation == "False") && (no_draw == "True")){
								if (no_save == "True"){
									if (string_arg2.length == 1){
										if (string_arg.length == 3){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], "--no-draw", "--no-save");
										} else if (string_arg.length == 4){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-draw", "--no-save");
										} else if (string_arg.length == 5){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-draw", "--no-save");
										} else if (string_arg.length == 6){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-draw", "--no-save");
										} else if (string_arg.length == 7){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-draw", "--no-save");
										} else if (string_arg.length == 8){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-draw", "--no-save");
										} else if (string_arg.length == 9){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-draw", "--no-save");
										} else if (string_arg.length == 10){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-draw", "--no-save");
										} else if (string_arg.length == 11){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-draw", "--no-save");
										} else if (string_arg.length == 12){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-draw", "--no-save");
										} else if (string_arg.length == 13){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-draw", "--no-save");
										} else if (string_arg.length == 14){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-draw", "--no-save");
										} else if (string_arg.length == 15){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-draw", "--no-save");
										} else if (string_arg.length == 16){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-draw", "--no-save");
										} else if (string_arg.length == 17){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-draw", "--no-save");
										} else if (string_arg.length == 18){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-draw", "--no-save");
										} else if (string_arg.length == 19){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-draw", "--no-save");
										} else if (string_arg.length == 20){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-draw", "--no-save");
										} else if (string_arg.length == 21){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-draw", "--no-save");
										} else if (string_arg.length == 22){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-draw", "--no-save");
										} else if (string_arg.length == 23){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-draw", "--no-save");
										} else if (string_arg.length == 24){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-draw", "--no-save");
										} else if (string_arg.length == 25){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-draw", "--no-save");
										} else if (string_arg.length == 26){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-draw", "--no-save");
										} else if (string_arg.length == 27){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-draw", "--no-save");
										} else if (string_arg.length == 28){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-draw", "--no-save");
										} else if (string_arg.length == 29){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-draw", "--no-save");
										}
									} else if (string_arg2.length == 2){
										if (string_arg.length == 3){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], "--no-draw", "--no-save");
										} else if (string_arg.length == 4){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-draw", "--no-save");
										} else if (string_arg.length == 5){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-draw", "--no-save");
										} else if (string_arg.length == 6){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-draw", "--no-save");
										} else if (string_arg.length == 7){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-draw", "--no-save");
										} else if (string_arg.length == 8){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-draw", "--no-save");
										} else if (string_arg.length == 9){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-draw", "--no-save");
										} else if (string_arg.length == 10){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-draw", "--no-save");
										} else if (string_arg.length == 11){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-draw", "--no-save");
										} else if (string_arg.length == 12){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-draw", "--no-save");
										} else if (string_arg.length == 13){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-draw", "--no-save");
										} else if (string_arg.length == 14){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-draw", "--no-save");
										} else if (string_arg.length == 15){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-draw", "--no-save");
										} else if (string_arg.length == 16){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-draw", "--no-save");
										} else if (string_arg.length == 17){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-draw", "--no-save");
										} else if (string_arg.length == 18){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-draw", "--no-save");
										} else if (string_arg.length == 19){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-draw", "--no-save");
										} else if (string_arg.length == 20){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-draw", "--no-save");
										} else if (string_arg.length == 21){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-draw", "--no-save");
										} else if (string_arg.length == 22){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-draw", "--no-save");
										} else if (string_arg.length == 23){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-draw", "--no-save");
										} else if (string_arg.length == 24){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-draw", "--no-save");
										} else if (string_arg.length == 25){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-draw", "--no-save");
										} else if (string_arg.length == 26){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-draw", "--no-save");
										} else if (string_arg.length == 27){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-draw", "--no-save");
										} else if (string_arg.length == 28){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-draw", "--no-save");
										} else if (string_arg.length == 29){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-draw", "--no-save");
										}
									} else if (string_arg2.length == 3){
										if (string_arg.length == 3){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], "--no-draw", "--no-save");
										} else if (string_arg.length == 4){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-draw", "--no-save");
										} else if (string_arg.length == 5){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-draw", "--no-save");
										} else if (string_arg.length == 6){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-draw", "--no-save");
										} else if (string_arg.length == 7){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-draw", "--no-save");
										} else if (string_arg.length == 8){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-draw", "--no-save");
										} else if (string_arg.length == 9){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-draw", "--no-save");
										} else if (string_arg.length == 10){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-draw", "--no-save");
										} else if (string_arg.length == 11){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-draw", "--no-save");
										} else if (string_arg.length == 12){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-draw", "--no-save");
										} else if (string_arg.length == 13){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-draw", "--no-save");
										} else if (string_arg.length == 14){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-draw", "--no-save");
										} else if (string_arg.length == 15){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-draw", "--no-save");
										} else if (string_arg.length == 16){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-draw", "--no-save");
										} else if (string_arg.length == 17){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-draw", "--no-save");
										} else if (string_arg.length == 18){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-draw", "--no-save");
										} else if (string_arg.length == 19){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-draw", "--no-save");
										} else if (string_arg.length == 20){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-draw", "--no-save");
										} else if (string_arg.length == 21){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-draw", "--no-save");
										} else if (string_arg.length == 22){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-draw", "--no-save");
										} else if (string_arg.length == 23){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-draw", "--no-save");
										} else if (string_arg.length == 24){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-draw", "--no-save");
										} else if (string_arg.length == 25){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-draw", "--no-save");
										} else if (string_arg.length == 26){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-draw", "--no-save");
										} else if (string_arg.length == 27){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-draw", "--no-save");
										} else if (string_arg.length == 28){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-draw", "--no-save");
										} else if (string_arg.length == 29){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-draw", "--no-save");
										}
									} else if (string_arg2.length == 4){
										if (string_arg.length == 3){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], "--no-draw", "--no-save");
										} else if (string_arg.length == 4){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-draw", "--no-save");
										} else if (string_arg.length == 5){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-draw", "--no-save");
										} else if (string_arg.length == 6){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-draw", "--no-save");
										} else if (string_arg.length == 7){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-draw", "--no-save");
										} else if (string_arg.length == 8){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-draw", "--no-save");
										} else if (string_arg.length == 9){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-draw", "--no-save");
										} else if (string_arg.length == 10){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-draw", "--no-save");
										} else if (string_arg.length == 11){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-draw", "--no-save");
										} else if (string_arg.length == 12){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-draw", "--no-save");
										} else if (string_arg.length == 13){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-draw", "--no-save");
										} else if (string_arg.length == 14){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-draw", "--no-save");
										} else if (string_arg.length == 15){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-draw", "--no-save");
										} else if (string_arg.length == 16){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-draw", "--no-save");
										} else if (string_arg.length == 17){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-draw", "--no-save");
										} else if (string_arg.length == 18){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-draw", "--no-save");
										} else if (string_arg.length == 19){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-draw", "--no-save");
										} else if (string_arg.length == 20){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-draw", "--no-save");
										} else if (string_arg.length == 21){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-draw", "--no-save");
										} else if (string_arg.length == 22){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-draw", "--no-save");
										} else if (string_arg.length == 23){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-draw", "--no-save");
										} else if (string_arg.length == 24){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-draw", "--no-save");
										} else if (string_arg.length == 25){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-draw", "--no-save");
										} else if (string_arg.length == 26){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-draw", "--no-save");
										} else if (string_arg.length == 27){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-draw", "--no-save");
										} else if (string_arg.length == 28){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-draw", "--no-save");
										} else if (string_arg.length == 29){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-draw", "--no-save");
										}
									} else if (string_arg2.length == 5){
										if (string_arg.length == 3){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], "--no-draw", "--no-save");
										} else if (string_arg.length == 4){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-draw", "--no-save");
										} else if (string_arg.length == 5){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-draw", "--no-save");
										} else if (string_arg.length == 6){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-draw", "--no-save");
										} else if (string_arg.length == 7){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-draw", "--no-save");
										} else if (string_arg.length == 8){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-draw", "--no-save");
										} else if (string_arg.length == 9){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-draw", "--no-save");
										} else if (string_arg.length == 10){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-draw", "--no-save");
										} else if (string_arg.length == 11){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-draw", "--no-save");
										} else if (string_arg.length == 12){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-draw", "--no-save");
										} else if (string_arg.length == 13){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-draw", "--no-save");
										} else if (string_arg.length == 14){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-draw", "--no-save");
										} else if (string_arg.length == 15){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-draw", "--no-save");
										} else if (string_arg.length == 16){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-draw", "--no-save");
										} else if (string_arg.length == 17){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-draw", "--no-save");
										} else if (string_arg.length == 18){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-draw", "--no-save");
										} else if (string_arg.length == 19){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-draw", "--no-save");
										} else if (string_arg.length == 20){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-draw", "--no-save");
										} else if (string_arg.length == 21){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-draw", "--no-save");
										} else if (string_arg.length == 22){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-draw", "--no-save");
										} else if (string_arg.length == 23){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-draw", "--no-save");
										} else if (string_arg.length == 24){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-draw", "--no-save");
										} else if (string_arg.length == 25){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-draw", "--no-save");
										} else if (string_arg.length == 26){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-draw", "--no-save");
										} else if (string_arg.length == 27){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-draw", "--no-save");
										} else if (string_arg.length == 28){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-draw", "--no-save");
										} else if (string_arg.length == 29){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-draw", "--no-save");
										}
									} else if (string_arg2.length == 6){
										if (string_arg.length == 3){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], "--no-draw", "--no-save");
										} else if (string_arg.length == 4){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-draw", "--no-save");
										} else if (string_arg.length == 5){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-draw", "--no-save");
										} else if (string_arg.length == 6){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-draw", "--no-save");
										} else if (string_arg.length == 7){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-draw", "--no-save");
										} else if (string_arg.length == 8){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-draw", "--no-save");
										} else if (string_arg.length == 9){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-draw", "--no-save");
										} else if (string_arg.length == 10){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-draw", "--no-save");
										} else if (string_arg.length == 11){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-draw", "--no-save");
										} else if (string_arg.length == 12){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-draw", "--no-save");
										} else if (string_arg.length == 13){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-draw", "--no-save");
										} else if (string_arg.length == 14){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-draw", "--no-save");
										} else if (string_arg.length == 15){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-draw", "--no-save");
										} else if (string_arg.length == 16){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-draw", "--no-save");
										} else if (string_arg.length == 17){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-draw", "--no-save");
										} else if (string_arg.length == 18){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-draw", "--no-save");
										} else if (string_arg.length == 19){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-draw", "--no-save");
										} else if (string_arg.length == 20){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-draw", "--no-save");
										} else if (string_arg.length == 21){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-draw", "--no-save");
										} else if (string_arg.length == 22){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-draw", "--no-save");
										} else if (string_arg.length == 23){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-draw", "--no-save");
										} else if (string_arg.length == 24){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-draw", "--no-save");
										} else if (string_arg.length == 25){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-draw", "--no-save");
										} else if (string_arg.length == 26){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-draw", "--no-save");
										} else if (string_arg.length == 27){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-draw", "--no-save");
										} else if (string_arg.length == 28){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-draw", "--no-save");
										} else if (string_arg.length == 29){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-draw", "--no-save");
										}
									}
								} else if (no_save == "False"){
									if (string_arg2.length == 1){
										if (string_arg.length == 3){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], "--no-draw");
										} else if (string_arg.length == 4){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-draw");
										} else if (string_arg.length == 5){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-draw");
										} else if (string_arg.length == 6){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-draw");
										} else if (string_arg.length == 7){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-draw");
										} else if (string_arg.length == 8){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-draw");
										} else if (string_arg.length == 9){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-draw");
										} else if (string_arg.length == 10){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-draw");
										} else if (string_arg.length == 11){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-draw");
										} else if (string_arg.length == 12){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-draw");
										} else if (string_arg.length == 13){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-draw");
										} else if (string_arg.length == 14){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-draw");
										} else if (string_arg.length == 15){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-draw");
										} else if (string_arg.length == 16){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-draw");
										} else if (string_arg.length == 17){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-draw");
										} else if (string_arg.length == 18){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-draw");
										} else if (string_arg.length == 19){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-draw");
										} else if (string_arg.length == 20){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-draw");
										} else if (string_arg.length == 21){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-draw");
										} else if (string_arg.length == 22){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-draw");
										} else if (string_arg.length == 23){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-draw");
										} else if (string_arg.length == 24){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-draw");
										} else if (string_arg.length == 25){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-draw");
										} else if (string_arg.length == 26){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-draw");
										} else if (string_arg.length == 27){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-draw");
										} else if (string_arg.length == 28){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-draw");
										} else if (string_arg.length == 29){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-draw");
										}
									} else if (string_arg2.length == 2){
										if (string_arg.length == 3){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], "--no-draw");
										} else if (string_arg.length == 4){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-draw");
										} else if (string_arg.length == 5){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-draw");
										} else if (string_arg.length == 6){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-draw");
										} else if (string_arg.length == 7){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-draw");
										} else if (string_arg.length == 8){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-draw");
										} else if (string_arg.length == 9){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-draw");
										} else if (string_arg.length == 10){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-draw");
										} else if (string_arg.length == 11){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-draw");
										} else if (string_arg.length == 12){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-draw");
										} else if (string_arg.length == 13){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-draw");
										} else if (string_arg.length == 14){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-draw");
										} else if (string_arg.length == 15){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-draw");
										} else if (string_arg.length == 16){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-draw");
										} else if (string_arg.length == 17){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-draw");
										} else if (string_arg.length == 18){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-draw");
										} else if (string_arg.length == 19){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-draw");
										} else if (string_arg.length == 20){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-draw");
										} else if (string_arg.length == 21){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-draw");
										} else if (string_arg.length == 22){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-draw");
										} else if (string_arg.length == 23){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-draw");
										} else if (string_arg.length == 24){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-draw");
										} else if (string_arg.length == 25){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-draw");
										} else if (string_arg.length == 26){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-draw");
										} else if (string_arg.length == 27){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-draw");
										} else if (string_arg.length == 28){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-draw");
										} else if (string_arg.length == 29){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-draw");
										}
									} else if (string_arg2.length == 3){
										if (string_arg.length == 3){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], "--no-draw");
										} else if (string_arg.length == 4){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-draw");
										} else if (string_arg.length == 5){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-draw");
										} else if (string_arg.length == 6){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-draw");
										} else if (string_arg.length == 7){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-draw");
										} else if (string_arg.length == 8){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-draw");
										} else if (string_arg.length == 9){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-draw");
										} else if (string_arg.length == 10){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-draw");
										} else if (string_arg.length == 11){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-draw");
										} else if (string_arg.length == 12){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-draw");
										} else if (string_arg.length == 13){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-draw");
										} else if (string_arg.length == 14){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-draw");
										} else if (string_arg.length == 15){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-draw");
										} else if (string_arg.length == 16){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-draw");
										} else if (string_arg.length == 17){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-draw");
										} else if (string_arg.length == 18){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-draw");
										} else if (string_arg.length == 19){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-draw");
										} else if (string_arg.length == 20){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-draw");
										} else if (string_arg.length == 21){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-draw");
										} else if (string_arg.length == 22){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-draw");
										} else if (string_arg.length == 23){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-draw");
										} else if (string_arg.length == 24){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-draw");
										} else if (string_arg.length == 25){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-draw");
										} else if (string_arg.length == 26){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-draw");
										} else if (string_arg.length == 27){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-draw");
										} else if (string_arg.length == 28){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-draw");
										} else if (string_arg.length == 29){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-draw");
										}
									} else if (string_arg2.length == 4){
										if (string_arg.length == 3){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], "--no-draw");
										} else if (string_arg.length == 4){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-draw");
										} else if (string_arg.length == 5){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-draw");
										} else if (string_arg.length == 6){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-draw");
										} else if (string_arg.length == 7){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-draw");
										} else if (string_arg.length == 8){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-draw");
										} else if (string_arg.length == 9){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-draw");
										} else if (string_arg.length == 10){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-draw");
										} else if (string_arg.length == 11){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-draw");
										} else if (string_arg.length == 12){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-draw");
										} else if (string_arg.length == 13){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-draw");
										} else if (string_arg.length == 14){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-draw");
										} else if (string_arg.length == 15){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-draw");
										} else if (string_arg.length == 16){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-draw");
										} else if (string_arg.length == 17){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-draw");
										} else if (string_arg.length == 18){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-draw");
										} else if (string_arg.length == 19){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-draw");
										} else if (string_arg.length == 20){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-draw");
										} else if (string_arg.length == 21){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-draw");
										} else if (string_arg.length == 22){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-draw");
										} else if (string_arg.length == 23){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-draw");
										} else if (string_arg.length == 24){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-draw");
										} else if (string_arg.length == 25){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-draw");
										} else if (string_arg.length == 26){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-draw");
										} else if (string_arg.length == 27){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-draw");
										} else if (string_arg.length == 28){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-draw");
										} else if (string_arg.length == 29){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-draw");
										}
									} else if (string_arg2.length == 5){
										if (string_arg.length == 3){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], "--no-draw");
										} else if (string_arg.length == 4){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-draw");
										} else if (string_arg.length == 5){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-draw");
										} else if (string_arg.length == 6){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-draw");
										} else if (string_arg.length == 7){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-draw");
										} else if (string_arg.length == 8){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-draw");
										} else if (string_arg.length == 9){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-draw");
										} else if (string_arg.length == 10){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-draw");
										} else if (string_arg.length == 11){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-draw");
										} else if (string_arg.length == 12){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-draw");
										} else if (string_arg.length == 13){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-draw");
										} else if (string_arg.length == 14){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-draw");
										} else if (string_arg.length == 15){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-draw");
										} else if (string_arg.length == 16){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-draw");
										} else if (string_arg.length == 17){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-draw");
										} else if (string_arg.length == 18){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-draw");
										} else if (string_arg.length == 19){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-draw");
										} else if (string_arg.length == 20){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-draw");
										} else if (string_arg.length == 21){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-draw");
										} else if (string_arg.length == 22){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-draw");
										} else if (string_arg.length == 23){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-draw");
										} else if (string_arg.length == 24){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-draw");
										} else if (string_arg.length == 25){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-draw");
										} else if (string_arg.length == 26){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-draw");
										} else if (string_arg.length == 27){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-draw");
										} else if (string_arg.length == 28){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-draw");
										} else if (string_arg.length == 29){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-draw");
										}
									} else if (string_arg2.length == 6){
										if (string_arg.length == 3){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], "--no-draw");
										} else if (string_arg.length == 4){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-draw");
										} else if (string_arg.length == 5){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-draw");
										} else if (string_arg.length == 6){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-draw");
										} else if (string_arg.length == 7){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-draw");
										} else if (string_arg.length == 8){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-draw");
										} else if (string_arg.length == 9){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-draw");
										} else if (string_arg.length == 10){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-draw");
										} else if (string_arg.length == 11){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-draw");
										} else if (string_arg.length == 12){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-draw");
										} else if (string_arg.length == 13){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-draw");
										} else if (string_arg.length == 14){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-draw");
										} else if (string_arg.length == 15){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-draw");
										} else if (string_arg.length == 16){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-draw");
										} else if (string_arg.length == 17){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-draw");
										} else if (string_arg.length == 18){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-draw");
										} else if (string_arg.length == 19){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-draw");
										} else if (string_arg.length == 20){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-draw");
										} else if (string_arg.length == 21){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-draw");
										} else if (string_arg.length == 22){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-draw");
										} else if (string_arg.length == 23){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-draw");
										} else if (string_arg.length == 24){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-draw");
										} else if (string_arg.length == 25){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-draw");
										} else if (string_arg.length == 26){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-draw");
										} else if (string_arg.length == 27){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-draw");
										} else if (string_arg.length == 28){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-draw");
										} else if (string_arg.length == 29){
											exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-draw");
										}
									}
								}
							} else if ((default_computation == "False") && (no_save == "True") && (no_draw == "False")){
								if (string_arg2.length == 1){
									if (string_arg.length == 3){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], "--no-save");
									} else if (string_arg.length == 4){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-save");
									} else if (string_arg.length == 5){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-save");
									} else if (string_arg.length == 6){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-save");
									} else if (string_arg.length == 7){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-save");
									} else if (string_arg.length == 8){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-save");
									} else if (string_arg.length == 9){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-save");
									} else if (string_arg.length == 10){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-save");
									} else if (string_arg.length == 11){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-save");
									} else if (string_arg.length == 12){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-save");
									} else if (string_arg.length == 13){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-save");
									} else if (string_arg.length == 14){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-save");
									} else if (string_arg.length == 15){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-save");
									} else if (string_arg.length == 16){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-save");
									} else if (string_arg.length == 17){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-save");
									} else if (string_arg.length == 18){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-save");
									} else if (string_arg.length == 19){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-save");
									} else if (string_arg.length == 20){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-save");
									} else if (string_arg.length == 21){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-save");
									} else if (string_arg.length == 22){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-save");
									} else if (string_arg.length == 23){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-save");
									} else if (string_arg.length == 24){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-save");
									} else if (string_arg.length == 25){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-save");
									} else if (string_arg.length == 26){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-save");
									} else if (string_arg.length == 27){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-save");
									} else if (string_arg.length == 28){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-save");
									} else if (string_arg.length == 29){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-save");
									}
								} else if (string_arg2.length == 2){
									if (string_arg.length == 3){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], "--no-save");
									} else if (string_arg.length == 4){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-save");
									} else if (string_arg.length == 5){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-save");
									} else if (string_arg.length == 6){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-save");
									} else if (string_arg.length == 7){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-save");
									} else if (string_arg.length == 8){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-save");
									} else if (string_arg.length == 9){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-save");
									} else if (string_arg.length == 10){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-save");
									} else if (string_arg.length == 11){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-save");
									} else if (string_arg.length == 12){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-save");
									} else if (string_arg.length == 13){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-save");
									} else if (string_arg.length == 14){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-save");
									} else if (string_arg.length == 15){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-save");
									} else if (string_arg.length == 16){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-save");
									} else if (string_arg.length == 17){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-save");
									} else if (string_arg.length == 18){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-save");
									} else if (string_arg.length == 19){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-save");
									} else if (string_arg.length == 20){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-save");
									} else if (string_arg.length == 21){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-save");
									} else if (string_arg.length == 22){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-save");
									} else if (string_arg.length == 23){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-save");
									} else if (string_arg.length == 24){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-save");
									} else if (string_arg.length == 25){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-save");
									} else if (string_arg.length == 26){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-save");
									} else if (string_arg.length == 27){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-save");
									} else if (string_arg.length == 28){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-save");
									} else if (string_arg.length == 29){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-save");
									}
								} else if (string_arg2.length == 3){
									if (string_arg.length == 3){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], "--no-save");
									} else if (string_arg.length == 4){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-save");
									} else if (string_arg.length == 5){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-save");
									} else if (string_arg.length == 6){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-save");
									} else if (string_arg.length == 7){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-save");
									} else if (string_arg.length == 8){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-save");
									} else if (string_arg.length == 9){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-save");
									} else if (string_arg.length == 10){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-save");
									} else if (string_arg.length == 11){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-save");
									} else if (string_arg.length == 12){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-save");
									} else if (string_arg.length == 13){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-save");
									} else if (string_arg.length == 14){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-save");
									} else if (string_arg.length == 15){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-save");
									} else if (string_arg.length == 16){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-save");
									} else if (string_arg.length == 17){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-save");
									} else if (string_arg.length == 18){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-save");
									} else if (string_arg.length == 19){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-save");
									} else if (string_arg.length == 20){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-save");
									} else if (string_arg.length == 21){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-save");
									} else if (string_arg.length == 22){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-save");
									} else if (string_arg.length == 23){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-save");
									} else if (string_arg.length == 24){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-save");
									} else if (string_arg.length == 25){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-save");
									} else if (string_arg.length == 26){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-save");
									} else if (string_arg.length == 27){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-save");
									} else if (string_arg.length == 28){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-save");
									} else if (string_arg.length == 29){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-save");
									}
								} else if (string_arg2.length == 4){
									if (string_arg.length == 3){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], "--no-save");
									} else if (string_arg.length == 4){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-save");
									} else if (string_arg.length == 5){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-save");
									} else if (string_arg.length == 6){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-save");
									} else if (string_arg.length == 7){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-save");
									} else if (string_arg.length == 8){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-save");
									} else if (string_arg.length == 9){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-save");
									} else if (string_arg.length == 10){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-save");
									} else if (string_arg.length == 11){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-save");
									} else if (string_arg.length == 12){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-save");
									} else if (string_arg.length == 13){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-save");
									} else if (string_arg.length == 14){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-save");
									} else if (string_arg.length == 15){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-save");
									} else if (string_arg.length == 16){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-save");
									} else if (string_arg.length == 17){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-save");
									} else if (string_arg.length == 18){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-save");
									} else if (string_arg.length == 19){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-save");
									} else if (string_arg.length == 20){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-save");
									} else if (string_arg.length == 21){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-save");
									} else if (string_arg.length == 22){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-save");
									} else if (string_arg.length == 23){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-save");
									} else if (string_arg.length == 24){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-save");
									} else if (string_arg.length == 25){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-save");
									} else if (string_arg.length == 26){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-save");
									} else if (string_arg.length == 27){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-save");
									} else if (string_arg.length == 28){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-save");
									} else if (string_arg.length == 29){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-save");
									}
								} else if (string_arg2.length == 5){
									if (string_arg.length == 3){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], "--no-save");
									} else if (string_arg.length == 4){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-save");
									} else if (string_arg.length == 5){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-save");
									} else if (string_arg.length == 6){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-save");
									} else if (string_arg.length == 7){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-save");
									} else if (string_arg.length == 8){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-save");
									} else if (string_arg.length == 9){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-save");
									} else if (string_arg.length == 10){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-save");
									} else if (string_arg.length == 11){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-save");
									} else if (string_arg.length == 12){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-save");
									} else if (string_arg.length == 13){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-save");
									} else if (string_arg.length == 14){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-save");
									} else if (string_arg.length == 15){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-save");
									} else if (string_arg.length == 16){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-save");
									} else if (string_arg.length == 17){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-save");
									} else if (string_arg.length == 18){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-save");
									} else if (string_arg.length == 19){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-save");
									} else if (string_arg.length == 20){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-save");
									} else if (string_arg.length == 21){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-save");
									} else if (string_arg.length == 22){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-save");
									} else if (string_arg.length == 23){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-save");
									} else if (string_arg.length == 24){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-save");
									} else if (string_arg.length == 25){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-save");
									} else if (string_arg.length == 26){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-save");
									} else if (string_arg.length == 27){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-save");
									} else if (string_arg.length == 28){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-save");
									} else if (string_arg.length == 29){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-save");
									}
								} else if (string_arg2.length == 6){
									if (string_arg.length == 3){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], "--no-save");
									} else if (string_arg.length == 4){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], "--no-save");
									} else if (string_arg.length == 5){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], "--no-save");
									} else if (string_arg.length == 6){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], "--no-save");
									} else if (string_arg.length == 7){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], "--no-save");
									} else if (string_arg.length == 8){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], "--no-save");
									} else if (string_arg.length == 9){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], "--no-save");
									} else if (string_arg.length == 10){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], "--no-save");
									} else if (string_arg.length == 11){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], "--no-save");
									} else if (string_arg.length == 12){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], "--no-save");
									} else if (string_arg.length == 13){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], "--no-save");
									} else if (string_arg.length == 14){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], "--no-save");
									} else if (string_arg.length == 15){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], "--no-save");
									} else if (string_arg.length == 16){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], "--no-save");
									} else if (string_arg.length == 17){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], "--no-save");
									} else if (string_arg.length == 18){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], "--no-save");
									} else if (string_arg.length == 19){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], "--no-save");
									} else if (string_arg.length == 20){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], "--no-save");
									} else if (string_arg.length == 21){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], "--no-save");
									} else if (string_arg.length == 22){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], "--no-save");
									} else if (string_arg.length == 23){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], "--no-save");
									} else if (string_arg.length == 24){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], "--no-save");
									} else if (string_arg.length == 25){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], "--no-save");
									} else if (string_arg.length == 26){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], "--no-save");
									} else if (string_arg.length == 27){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], "--no-save");
									} else if (string_arg.length == 28){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], "--no-save");
									} else if (string_arg.length == 29){
										exec("python", dir_python, "-i", dir_input, "-o", dir_prediction, string_arg2[0], string_arg2[1], string_arg2[2], string_arg2[3], string_arg2[4], string_arg2[5], string_arg[0], string_arg[1], string_arg[2], string_arg[3], string_arg[4], string_arg[5], string_arg[6], string_arg[7], string_arg[8], string_arg[9], string_arg[10], string_arg[11], string_arg[12], string_arg[13], string_arg[14], string_arg[15], string_arg[16], string_arg[17], string_arg[18], string_arg[19], string_arg[20], string_arg[21], string_arg[22], string_arg[23], string_arg[24], string_arg[25], string_arg[26], string_arg[27], string_arg[28], "--no-save");
									}
								}
							}
						}
						
						
						for (l=0; l<n_cond; l++){
							if (defaults_cond[l] == true){
								list_txt = getFileList(dir2+"/Measurements_TMP/"+labels_cond[l]);
								for (l2=0;l2<list_txt.length;l2++){
									File.delete(dir2+"/Measurements_TMP/"+labels_cond[l]+"/"+list_txt[l2])
								}
								File.delete(dir2+"/Measurements_TMP/"+labels_cond[l]) 
							}
						}
						
						print("MITOMETRIX DATA DISPLAY & COMPUTATION -------------------------------- ENDING\n");
						
					}
					
				
				} else if ((error_prediction_choice == 1) || (error_morpho_choice == 1) || (error_cellpose_diameter == 1)){
					if (error_prediction_choice == 1){
						print("Setting Data computation parameters --------------------------- ERROR");
						print("---------- Select at least 3 or more Morphology & texture metrics for morphometrix analysis. Please see the readme.txt for instructions");
						waitForUser("Program ERROR", "Select at least 3 or more Morphology & texture metrics for morphometrix analysis \nPlease see the readme.txt for instructions");
					}
					if (error_morpho_choice == 1){
						print("Setting Morphology Analysis parameters --------------------------- ERROR");
						print("---------- Select at least 1 or more graph or data distribution to display. Please see the readme.txt for instructions");
						waitForUser("Program ERROR", "Select at least 1 or more graph or data distribution to display \nPlease see the readme.txt for instructions");
					}
					if (error_cellpose_diameter == 1){
						print("Setting Mitochondria Segmentation parameters --------------------------- ERROR");
						print("---------- Invalid value for Mitochondria Diameter. Please set an interger number value");
						waitForUser("Program ERROR", "Invalid value for Mitochondria Diameter\nPlease set an interger number value");
					}
					print("---------------------------ANALYSIS ABORTED---------------------------------\n");
				}
				
			} else if ((error_input_tree == 1) || (error_output_tree == 1)){
				print("Checking input and output folders --------------------------- ERROR");
				if (error_input_tree == 1){
					print("---------- Invalide INPUT directories. Missing folders containing input images. Please see the readme.txt for input instructions");
					waitForUser("Program ERROR", "Invalide INPUT directories. Missing folders containing input images\nPlease see the readme.txt for input instructions");
				}
				if (error_output_tree == 1){
					print("---------- OUTPUT tree issue. Invalide folders or files in the output directory. Please see the readme.txt for output instructions");
					waitForUser("Program ERROR", "OUTPUT tree issue. Invalide folders or files in the output directory.\nPlease see the readme.txt for output instructions");
				}
				print("-----------------------ANALYSIS ABORTED----------------------------\n");
			}
			
			
		} else if ((error_python_file == 1) || (error_cellpose == 1)){
			print("Checking python and cellpose folders ---------------------------ERROR");
			if (error_python_file == 1){
				print("---------- Invalide Python folder or missing files.Please see the readme.txt for python folder and file instructions");
				waitForUser("Program ERROR", "Invalide Python folder or missing files.\nPlease see the readme.txt for python folder and  file instructions");
			}
			if (error_cellpose == 1){
				print("---------- Invalide Cellpose environment or Cellpose folder.Please see the readme.txt for instructions");
				waitForUser("Program ERROR", "Invalide Cellpose environment or Cellpose folder.\nPlease see the readme.txt for instructions");
			}
			print("------------------------ANALYSIS ABORTED-----------------------------\n");
		}
	
	} else if (error_configuration == 1){
		print("Checking software and environment configuration---------------------------ERROR");
		print("---------- Cannot run the program. One or more prerequisites are not respected. Please see the readme.txt for installation instructions");
		print("-----------------------------ANALYSIS ABORTED----------------------------------\n");
		waitForUser("Program ERROR", "Cannot run the program.\nOne or more prerequisites are not respected. Please see the readme.txt for installation instructions");
	}
	
	
} else if (error_plugin == 1){
	print("Checking FIJI plugin configuration---------------------------ERROR");
	if (plugin_tofind1 == 0){
		print("--------------- Cellpose wrapper not installed. Please see the readme.txt file and follow the installation instructions");
	}
	if (plugin_tofind2 == 0){
		print("--------------- BioFormat plugin not installed. Please see the readme.txt file and follow the installation instructions");
	}
	if (plugin_tofind3 == 0){
		print("--------------- EMito-Metrix plugin not installed. Please see the readme.txt file and follow the installation instructions");
	}
	print("----------------------ANALYSIS ABORTED----------------------------\n");
}

print("-------------------END OF MITOMETRIX ANALYSIS------------------------");

//match_name_log2 = 1;
//num_log2 = 0;
//while (match_name_log2 == 1){
//	num_log2 = num_log2+1;
//	file_log2_tmp = "Log_file_"+year+month+dayOfMonth+"_v"+num_log+".txt";
//	match_name_log2 = File.exists(dir2+"/Log_files/"+file_log2_tmp);
//}
//selectWindow("Log");
//save(dir2+"/Log_files/Log_file_"+year+month+dayOfMonth+"_v"+num_log+".txt");
//run("Close");


//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// END OF ANALYSIS..............
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

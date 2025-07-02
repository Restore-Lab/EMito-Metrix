// EMito_Metrix_Fiji
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//
//
// See the GitHub repository for the intallation instructions and detailed documentation of the plugin :
//		
//		https://github.com/Restore-Lab/EMito-Metrix
//
//
// Copyrights : CERT facilities - RESTORE UMR 1301-INSERM 5070-CNRS / Mathieu VIGNEAU (mathieu.vigneau@cnrs.fr), 
//			    Metabolink Team - RESTORE UMR 1301-INSERM 5070-CNRS / Jean-Philippe PRADERE (jean-philippe.pradere@inserm.fr)
//				Got-it Team - RESTORE UMR 1301-INSERM 5070-CNRS / Emmanuel DOUMARD (emmanuel.doumard@inserm.fr)
// 
//
// Publishing date : 28/06/2025
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
// 																Starting the morphological & quantitative analysis
//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


// Initialization
//------------------------------------------------------------------

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
month = month+1;
error_macro = 0;
error_plugin = 0;
error_configuration = 0;
error_cellpose = 0;
error_python_file = 0;
error_cellpose_diameter = 0;
error_morpho_choice = 0;
error_prediction_choice = 0;
error_ml_choice = 0;
error_input_tree = 0;
error_input_name = 0;
error_input_filename = 0;
error_output_tree = 0;
error_input_format = 0;
plugin_tofind1 = 0;
plugin_tofind2 = 0;
plugin_tofind3 = 0;
plugin_tofind4 = 0;


print("------------------STARTING EMITOMETRIX ANALYSIS----------------------\n\n");


dir_fiji = getDirectory("plugins");
list_plugins = getFileList(dir_fiji);


for (i=0;i<list_plugins.length;i++){
	plugin_tofind1_tmp = matches(list_plugins[i], ".*BIOP.*");
	plugin_tofind2_tmp = matches(list_plugins[i], ".*bio-formats.*");
	plugin_tofind3_tmp = matches(list_plugins[i], ".*EMito_Metrix.*");
	plugin_tofind4_tmp = matches(list_plugins[i], ".*conda-envs.*");
	if (plugin_tofind1_tmp == 1){
		plugin_tofind1 = 1;
	} else if (plugin_tofind2_tmp == 1){
		plugin_tofind2 = 1;
	} else if (plugin_tofind3_tmp == 1){
		plugin_tofind3 = 1;
	} else if (plugin_tofind4_tmp == 1){
		plugin_tofind4 = 1;
	}
}


if ((plugin_tofind1 == 0) || (plugin_tofind2 == 0) || (plugin_tofind3 == 0) || (plugin_tofind4 == 0)){
	error_plugin = 1;
}

if (error_plugin == 0){

print("Checking FIJI plugin configuration----------------------------- OK\n");
	
	//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	// Analysis settings
	//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	// Settings selection : DATA selection
	//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	print("Setting EMitoMetrix workflow - DATA selection --------------------------- IN PROGRESS");
	
	choice0 = newArray("Yes", "No");
	Dialog.create("Image analysis : DATA selection");
	Dialog.addMessage("1- Select INPUT folder containing raw images to process");
	Dialog.addDirectory("INPUT directory", "");
	Dialog.addMessage("\n2- Select OUPUT folder containing output files");
	Dialog.addDirectory("OUTPUT directory", "");
	Dialog.addHelp("https://www.emitometrix.org/tutorials.html");
	Dialog.addMessage("\n\n\n(See Help Button for plugin quick start tutorial)");
	Dialog.show();
	dir = Dialog.getString();
	folder_dir = matches(dir, ".*/");
	if (folder_dir == 0){
		dir = dir+"/";
	}
	dir2 = Dialog.getString();
	folder_dir2 = matches(dir2, ".*/");
	if (folder_dir2 == 0){
		dir2 = dir2+"/";
	}
	
	print("Setting EMitoMetrix workflow - DATA selection --------------------------- END\n");
			
	
	// Checking both input and output folders 
	//---------------------------------------------------------------------------------
			
	print("Checking input and output folders --------------------------- IN PROGRESS");
			
	list_dataset_in = getFileList(dir);
	list_dataset_out = getFileList(dir2);
	folder_in = 0;
	folder_out_I = 1;
	folder_out_M = 1;
	folder_out_V = 1;
	folder_out_V2 = 1;
	folder_out_P = 1;
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
		while (((folder_out_I == 1) || (folder_out_M == 1) || (folder_out_V == 1) || (folder_out_V2 == 1) || (folder_out_P == 1) || (folder_out_R == 1) || (folder_out_L == 1) || (folder_out_MA == 1) || (folder_out_MT == 1)) && (img<list_dataset_out.length)){
			folder_out2_I = matches(list_dataset_out[img], "Image_output/");
			folder_out2_M = matches(list_dataset_out[img], "Measurements/");
			folder_out2_V = matches(list_dataset_out[img], "Data_visualization/");
			folder_out2_V2 = matches(list_dataset_out[img], "Data_visualizationspatial_clustering/");
			folder_out2_P = matches(list_dataset_out[img], "Prediction_Analysis/");
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
			if (folder_out2_V == 0){
				folder_out_V = 0;
			} else if (folder_out2_V == 1){
				folder_out_V = 1;
			}
			if (folder_out2_V2 == 0){
				folder_out_V2 = 0;
			} else if (folder_out2_V2 == 1){
				folder_out_V2 = 1;
			}
			if (folder_out2_P == 0){
				folder_out_P = 0;
			} else if (folder_out2_P == 1){
				folder_out_P = 1;
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
	
	if ((folder_out_I == 0) && (folder_out_M == 0) && (folder_out_V == 0) && (folder_out_V2 == 0) && (folder_out_P == 0) && (folder_out_R == 0) && (folder_out_L == 0) && (folder_out_MA == 0) && (folder_out_MT == 0)){
		error_output_tree = 1;
	}
	
	
	if ((error_input_tree == 0) && (error_output_tree == 0)){
		
		// Setting general parameters
		//--------------------------------------------------------------------------------------------
		
		print("Checking input and output folders --------------------------- END\n");
		
		list_dataset = getFileList(dir);
		list_dataset = Array.sort(list_dataset);
		
		log_file_tmp = File.exists(dir2+"Log_files/Users_general_parameters.txt");
	
		if ((list_dataset_out.length == 0) || ((list_dataset_out.length > 0) && (log_file_tmp == 0))){
		
			print("Setting EMitoMetrix workflow - General parameters --------------------------- IN PROGRESS");
			
			environment_choice = newArray("Windows", "Linux", "MacOS");
			Dialog.create("Plugin configuration");
			Dialog.addMessage("\n Did you install Cellpose with GPU computing ?");
			Dialog.addChoice("GPU computing ?",choice0,"No");
			Dialog.addMessage("\n Choose your computer environment");
			Dialog.addChoice("Environment: ",environment_choice,"Windows");
			Dialog.addHelp("https://www.emitometrix.org/install.html");
			Dialog.addMessage("\n\n\n(See Help Button for plugin instructions and installation)");
			Dialog.show();
			gpu_choice = Dialog.getChoice();
			environment_plugin = Dialog.getChoice();
			dir_working = getDir("preferences");
			directory_VE = dir_fiji+"conda-envs/cellpose/";
			directory_VE2 = dir_fiji+"conda-envs/emitometrix/";
			dir_python_tmp = dir_fiji+"EMito_Metrix/";
			last_step = NaN;
			
			print("Setting EMitoMetrix workflow - General parameters --------------------------- END");
			
		} else if ((list_dataset_out.length > 0) && (log_file_tmp == 1)){
		
			path = dir2+"Log_files/Users_general_parameters.txt";
			filestring=File.openAsString(path);
			rows=split(filestring, "\n");
			columns_value = split(rows[1],"\t");
			gpu_choice = columns_value[3];
			environment_plugin = columns_value[4];
			directory_VE = columns_value[0];
			directory_VE2 = columns_value[1];
			dir_python_tmp = columns_value[2];
			last_step = columns_value[6];
		}
			
			
		// Checking both python and cellpose folder validity
		//--------------------------------------------------------------
		
		list_python_files = getFileList(dir_python_tmp);
		python_algo = 0;
		python_algo_ML = 0;
		requirement_txt = 0;
		mod_GM = 0;
		mod_GM_fish = 0;
		mod_SM_fly = 0;
		mod_SM_mouse = 0;
		mod_SM_zebra = 0;
		mod_SM_human = 0;
		mod_SM_celegans = 0;
		mod_SM_killi = 0;
		img = 0;
		
		print("Checking python and cellpose folders --------------------------- IN PROGRESS");
		
		while (((python_algo == 0) || (python_algo_ML == 0) || (requirement_txt == 0) || (mod_GM == 0) || (mod_GM_fish == 0) || (mod_SM_celegans == 0) || (mod_SM_killi == 0) || (mod_SM_fly == 0) || (mod_SM_mouse == 0) || (mod_SM_zebra == 0) || (mod_SM_human == 0)) && (img<list_python_files.length)){
			python_algo2 = matches(list_python_files[img], ".*dataComputation.py");
			python_algo_ML2 = matches(list_python_files[img], ".*mlComputation.py");
			requirement_txt2 = matches(list_python_files[img], ".*requirements.txt");
			mod_GM2 = matches(list_python_files[img], ".*GeneralistModel_GM_EM.*");
			mod_GM_fish2 = matches(list_python_files[img], ".*Generalist-Fish_Model_GM-FISH_EM.*");
			mod_SM_celegans2 = matches(list_python_files[img], ".*SpecialistModel_SM_C-ELEGANS_EM.*");
			mod_SM_killi2 = matches(list_python_files[img], ".*SpecialistModel_SM_KILLIFISH_EM.*");
			mod_SM_fly2 = matches(list_python_files[img], ".*SpecialistModel_SM_FLY_EM.*");
			mod_SM_mouse2 = matches(list_python_files[img], ".*SpecialistModel_SM_MOUSE_EM.*");
			mod_SM_zebra2 = matches(list_python_files[img], ".*SpecialistModel_SM_ZEBRAFISH_EM.*");
			mod_SM_human2 = matches(list_python_files[img], ".*SpecialistModel_SM_HUMAN_EM.*");
			if (python_algo2 == 1){
				python_algo = 1;
			}
			if (python_algo_ML2 == 1){
				python_algo_ML = 1;
			}
			if (requirement_txt2 == 1){
				requirement_txt = 1;
			}
			if (mod_GM2 == 1){
				mod_GM = 1;
			}
			if (mod_GM_fish2 == 1){
				mod_GM_fish = 1;
			}
			if (mod_SM_celegans2 == 1){
				mod_SM_celegans = 1;
			}
			if (mod_SM_killi2 == 1){
				mod_SM_killi = 1;
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
		
		
		if ((python_algo == 0) || (python_algo_ML == 0) || (requirement_txt == 0) || (mod_GM == 0) || (mod_GM_fish == 0) || (mod_SM_celegans == 0) || (mod_SM_killi == 0) || (mod_SM_fly == 0) || (mod_SM_mouse == 0) || (mod_SM_zebra == 0) || (mod_SM_human == 0)){
			error_python_file = 1;
		}
		
		
		if (environment_plugin == "Windows"){
		
			list_cellpose_files = getFileList(directory_VE+"/Scripts/");
			list_cellpose_files2 = getFileList(directory_VE+"/Lib/site-packages/");
			list_cellpose_files3 = getFileList(directory_VE2);
			cellpose_appli = 0;
			cellpose_package = 0;
			emitometrix_package = 0;
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
			
			img = 0;
			while ((emitometrix_package == 0) && (img<list_cellpose_files3.length)){
				emitometrix_package2 = matches(list_cellpose_files3[img], ".*python.exe");
				if (emitometrix_package2 == 1){
					emitometrix_package = 1;
				}
				img = img+1;
			}
			
			if ((cellpose_appli == 0) || (cellpose_package == 0) || (emitometrix_package == 0)){
				error_cellpose = 1;
			}
			
		} else if (environment_plugin == "MacOS"){
			list_cellpose_files = getFileList(directory_VE+"/bin/");
			list_cellpose_files3 = getFileList(directory_VE2+"/bin/");
			cellpose_appli = 0;
			emitometrix_package = 0;
			img = 0;
			while ((cellpose_appli == 0) && (img<list_cellpose_files.length)){
				cellpose_appli2 = matches(list_cellpose_files[img], ".*cellpose.*");
				if (cellpose_appli2 == 1){
					cellpose_appli = 1;
				}
				img = img+1;
			}
			
			img = 0;
			while ((emitometrix_package == 0) && (img<list_cellpose_files3.length)){
				emitometrix_package2 = matches(list_cellpose_files3[img], ".*python");
				if (emitometrix_package2 == 1){
					emitometrix_package = 1;
				}
				img = img+1;
			}
			
			if ((cellpose_appli == 0) || (emitometrix_package == 0)){
				error_cellpose = 1;
			}
			
		} else if (environment_plugin == "Linux"){
			list_cellpose_files = getFileList(directory_VE+"/bin/");
			list_cellpose_files3 = getFileList(directory_VE2+"/bin/");
			cellpose_appli = 0;
			emitometrix_package = 0;
			img = 0;
			while ((cellpose_appli == 0) && (img<list_cellpose_files.length)){
				cellpose_appli2 = matches(list_cellpose_files[img], ".*cellpose.*");
				if (cellpose_appli2 == 1){
					cellpose_appli = 1;
				}
				img = img+1;
			}
			
			img = 0;
			while ((emitometrix_package == 0) && (img<list_cellpose_files3.length)){
				emitometrix_package2 = matches(list_cellpose_files3[img], ".*python");
				if (emitometrix_package2 == 1){
					emitometrix_package = 1;
				}
				img = img+1;
			}
			
			if ((cellpose_appli == 0) || (emitometrix_package == 0)){
				error_cellpose = 1;
			}
		}
		
		
		if ((error_python_file == 0) && (error_cellpose == 0)){
		
			print("Checking python and cellpose folders --------------------------- END");
					
			run("Set Measurements...", "area mean standard min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction redirect=None decimal=3");
			intensity_type = "Darkest";
			setBackgroundColor(16777215);
			setForegroundColor(0);
			run("ROI Manager...");
			segmentation_choice = newArray("default","custom");
			workflow_step = newArray("Segmentation","Morphometrics computation","Data display","Data prediction");
			
			
			// Check the workflow conditions 
			//--------------------------------------------------------------------------------------------
			
			file_log_tmp = File.exists(dir2+"Log_files/Users_general_parameters.txt");

			if (list_dataset_out.length == 0){
				cellpose_choise = "Yes";
			} else if (list_dataset_out.length > 0){
				if (file_log_tmp == 0){
					cellpose_choise = "Yes";
				} else if (file_log_tmp == 1){
					list_dataset_tmp = getFileList(dir2+"Image_output/cellpose_mask/");
					if (list_dataset_tmp.length == 0){
						cellpose_choise = "Yes";
					} else if (list_dataset_tmp.length > 0){
						list_img_tmp =  getFileList(dir2+"Image_output/cellpose_mask/"+list_dataset_tmp[0]);
						if (list_img_tmp.length == 0){
							cellpose_choise = "Yes";
						} else if (list_img_tmp.length != 0){
							cellpose_choise = "No";
						}
					}
				}
			}
			
			if (cellpose_choise == "Yes"){
				last_step = "cellpose";
				morpho_choice = "No";
				prediction_choice = "No";
				ml_choice = "No";
			} else if (cellpose_choise == "No"){
				list_dataset_tmp = getFileList(dir2+"Measurements/");
				if (list_dataset_tmp.length == 0){
					morpho_choice = "Yes";
				} else if (list_dataset_tmp.length != 0){
					list_img_tmp =  getFileList(dir2+"Measurements/"+list_dataset_tmp[0]);
					if (list_img_tmp.length == 0){
						morpho_choice = "Yes";
					} else if (list_img_tmp.length != 0){
						if (last_step == "cellpose"){
							morpho_choice = "Yes";
						} else if (last_step != "cellpose"){
							morpho_choice = "No";
						}
					}
				}
				if (morpho_choice == "No"){
					Dialog.create("Image analysis : Workflow selection");
					Dialog.addMessage("Segmentation & Metrics calculation already satisfied");
					Dialog.addMessage("\n Select next step or restart segmentation");
					if (last_step == "mitometrics"){
						Dialog.addChoice("Workflow step", workflow_step, "Data display");
					} else if (last_step == "display"){
						Dialog.addChoice("Workflow step", workflow_step, "Data prediction");
					} else if ((last_step == "prediction") || isNaN(last_step) == 1){
						Dialog.addChoice("Workflow step", workflow_step);
					}
					Dialog.addHelp("https://www.emitometrix.org/tutorials.html");
					Dialog.addMessage("\n\n\n(See Help Button for plugin quick start tutorial)");
					Dialog.show();
					workflow_choise = Dialog.getChoice();
					
					if (workflow_choise == "Segmentation"){
						cellpose_choise = "Yes";
						last_step = "cellpose";
						prediction_choice = "No";
						ml_choice = "No";
					} else if (workflow_choise == "Data display"){
						last_step = "display";
						prediction_choice = "Yes";
						ml_choice = "No";
					} else if (workflow_choise == "Data prediction"){
						last_step = "prediction";
						prediction_choice = "No";
						ml_choice = "Yes";
					} else if (workflow_choise == "Morphometrics computation"){
						last_step = "mitometrics";
						prediction_choice = "No";
						ml_choice = "No";
						morpho_choice = "Yes";
					}
				} else if (morpho_choice == "Yes"){
					last_step = "mitometrics";
					prediction_choice = "No";
					ml_choice = "No";
				}
			}
			
		
			// Setting Segmentation parameters
			//--------------------------------------------------------------------------------------------
			
			if (cellpose_choise == "Yes"){
			
				print("Setting EMitoMetrix workflow - Segmentation --------------------------- IN PROGRESS");
				
				Dialog.create("Image analysis : General parameters");
				Dialog.addString("1- Enter the EXPERIMENTAL NAME :", ""); 
				Dialog.addMessage("\n2- Select SEGMENTATION settings to launch");
				Dialog.addChoice("Segmentation Settings", segmentation_choice);
				Dialog.addHelp("https://www.emitometrix.org/tutorials.html");
				Dialog.addMessage("\n\n\n(See Help Button for plugin quick start tutorial)");
				Dialog.show();
				condition_name = Dialog.getString();
				cellpose_choise2 = Dialog.getChoice();
				
				if (cellpose_choise2 == "custom"){
				
					choice = newArray("pixel","calibrated");
					choice2 = newArray("Depending on Condition","Depending on Image");
					choice3 = newArray("Standard score","Min-Max Scaling");
					cellpose_model = newArray("GeneralistModel_GM_EM","Generalist-Fish_Model_GM-FISH_EM","SpecialistModel_SM_C-ELEGANS_EM","SpecialistModel_SM_KILLIFISH_EM","SpecialistModel_SM_FLY_EM","SpecialistModel_SM_MOUSE_EM","SpecialistModel_SM_ZEBRAFISH_EM","SpecialistModel_SM_HUMAN_EM","nuclei","cyto","cyto2","Custom model");
					Dialog.create("Image analysis : Parameters - Segmentation");
					Dialog.addMessage("1- GENERAL PARAMETERS");
					Dialog.addChoice("Unit of length for output", choice);
					Dialog.addChoice("Normalization method", choice3);
					Dialog.addChoice("Image cropping", choice0);
					Dialog.addChoice("Image cropping METHOD", choice2);
					Dialog.addMessage("\n2- MITOCHONDRIA SEGMENTATION");
					Dialog.addChoice("Enhancing segmentation for High-resolutive images :", choice0);
					Dialog.addChoice("Mitochondria diameter setting :", choice2);
					Dialog.addHelp("https://www.emitometrix.org/tutorials.html");
					Dialog.addMessage("\n\n\n(See Help Button for plugin quick start tutorial)");
					Dialog.show();
					unit_length = Dialog.getChoice();
					norm_type = Dialog.getChoice();
					cropp_choice = Dialog.getChoice();
					cropp_type = Dialog.getChoice();
					filter_choice = Dialog.getChoice();
					mito_size = Dialog.getChoice();
					
					
					
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
					
					
					
					// Cellpose settings
					//--------------------------------------------------------------------------------------------
			
					if (mito_size == "Depending on Condition"){
					
						print("Setting Mitochondria Segmentation parameters --------------------------- PROCESSING");
						
						object_detection_size = newArray(list_dataset.length);
						object_detection_size_min = newArray(list_dataset.length);
						object_detection_size_max = newArray(list_dataset.length);
						Dialog.create("Automatic Mitochondria Segmentation");
						Dialog.addMessage("1- Select TRAINED MODEL used for segmentation :");
						Dialog.addChoice("Default model to use", cellpose_model);
						Dialog.addMessage("\n2- If CUSTOM MODEL, select your own model for segmentation");
						Dialog.addFile("Select Custom model to use", "");
						for (cond=0;cond<list_dataset.length;cond++){
							num_tmp = cond+3;
							Dialog.addMessage("\n"+num_tmp+"- Set Mitochondria Diameter for condition "+list_dataset[cond]);
							Dialog.addNumber("Mean Diameter (in pixel)", "0");
							Dialog.addMessage("\n Optional for heterogeneus mitochondria : Range of diameter");
							Dialog.addNumber("Set Minimum Diameter (in pixel)", "0");
							Dialog.addNumber("Set Maximum Diameter (in pixel)", "0");
						}
						Dialog.addHelp("https://www.emitometrix.org/tutorials.html");
						Dialog.addMessage("\n\n\n(See Help Button for plugin quick start tutorial)");
						Dialog.show();
						object_detection_type = Dialog.getChoice();
						custom_model = Dialog.getString();
						for (cond=0;cond<list_dataset.length;cond++){
							object_detection_size[cond] = Dialog.getNumber();
							object_detection_size_min[cond] = Dialog.getNumber();
							object_detection_size_max[cond] = Dialog.getNumber();
							if (isNaN(object_detection_size[cond]) == 1){
								error_cellpose_diameter = 1;
							}
							if ((object_detection_size_max[cond] == 0) || (isNaN(object_detection_size_max[cond]) == 1) || (object_detection_size_max[cond] <= object_detection_size[cond])){
								object_detection_size_max[cond] = NaN;
							}
							if ((object_detection_size_min[cond] == 0) || (isNaN(object_detection_size_min[cond]) == 1) || (object_detection_size_min[cond] >= object_detection_size[cond])){
								object_detection_size_min[cond] = NaN;
							}
						}
						
						if (object_detection_type == "Custom model"){
							if (custom_model == ""){
								Dialog.create("Cellpose : custom model");
								Dialog.addMessage("Select your OWN MODEL used for segmentation :");
								Dialog.addFile("Select Custom model to use", "");
								Dialog.show();
								custom_model = Dialog.getString();
							}
							object_detection_type2 = custom_model;
						}

						if ((object_detection_type == "GeneralistModel_GM_EM") || (object_detection_type == "SpecialistModel_SM_FLY_EM") || (object_detection_type == "SpecialistModel_SM_MOUSE_EM") || (object_detection_type == "SpecialistModel_SM_ZEBRAFISH_EM") || (object_detection_type == "SpecialistModel_SM_HUMAN_EM")){
							object_detection_type2 = dir_python_tmp+object_detection_type;
						}
						
						print("Setting Mitochondria Segmentation parameters --------------------------- END");
						
					}
					
				} else if (cellpose_choise2 == "default"){
				
					unit_length = "pixel";
					norm_type = "Standard score";
					cropp_choice = "No";
					cropp_type = "Depending on Condition";
					filter_choice = "No";
					mito_size = "Depending on Condition";
					unit_of_length = unit_length;
					pixel_width2 = 1.0000;
					pixel_height2 = 1.0000;
					object_detection_type = "GeneralistModel_GM_EM";
					object_detection_type2 = dir_python_tmp+object_detection_type;
					custom_model = "";
					object_detection_size = newArray(list_dataset.length);
					object_detection_size_max = newArray(list_dataset.length);
					object_detection_size_min = newArray(list_dataset.length);
					Dialog.create("Mitochondria diameter");
					Dialog.addNumber("Set a mean value for Mitochondria diameter (in pixel)", "0");
					Dialog.show();
					mito_diameter = Dialog.getNumber();
					for (cond=0;cond<list_dataset.length;cond++){
						object_detection_size[cond] = mito_diameter;
						object_detection_size_max[cond] = NaN;
						object_detection_size_min[cond] = NaN;
					}
				
				}
				
				print("Setting EMitoMetrix workflow - Segmentation --------------------------- END");
			
			} else if (cellpose_choise == "No"){
				condition_name = columns_value[5];
				unit_of_length = columns_value[13];
				pixel_width2 = columns_value[19];
				pixel_height2 = columns_value[20];
				norm_type = NaN;
				mito_size = NaN;
				cropp_choice = NaN;
				cropp_type = NaN;
			}
			
			
			
			// Setting morphometrics to use for display and/or prediction analysis
			//--------------------------------------------------------------------------------------------
			
			if ((prediction_choice == "Yes") || (ml_choice == "Yes")){
			
				print("Setting EMitoMetrix workflow - Mitometrics settings --------------------------- IN PROGRESS");
			
				Dialog.create("Image analysis : Parameters - Mitometrics");
				Dialog.addMessage("1- Select MitoMetrics to use for display and prediction");
				Dialog.addChoice("Mitometrics selection", segmentation_choice);
				Dialog.addHelp("https://www.emitometrix.org/tutorials.html");
				Dialog.addMessage("\n\n\n(See Help Button for plugin quick start tutorial)");
				Dialog.show();
				morpho_measure = Dialog.getChoice();
				
				labels = newArray("Condition_Name", "Mito_CentroidX", "Mito_CentroidY", "Mito_Area", "Mito_Perimeter", "AreaPerimeter_Ratio",  "Mito_Circularity", "Mito_Roundness", "Mito_Solidity", "Mito_AR", "Mito_Feret_Diameter", "Mito_FeretX", "Mito_FeretY", "Mito_MeanInt", "Mito_MedianInt", "Mito_TotalInt", "Intensity_SD", "Intensity_SD_percent", "Mito_MeanInt_CORR", "Mito_MedianInt_CORR", "Mito_TotalInt_CORR", "Intensity_SD_CORR", "Intensity_SD_percent_CORR", "Skewness", "Kurtosis", "CristaeOrientation_Major", "CristaeOrientation_Minor","CristaeOrientation_Angle","CristaeOrientation_Area");
				labels1 = newArray("Condition_Name", "Mito_CentroidX", "Mito_CentroidY");
				labels2 = newArray("Mito_Area", "Mito_Perimeter", "AreaPerimeter_Ratio",  "Mito_Circularity", "Mito_Roundness", "Mito_Solidity", "Mito_AR", "Mito_Feret_Diameter", "Mito_FeretX", "Mito_FeretY");
				labels3 = newArray("Mito_MeanInt", "Mito_MedianInt", "Mito_TotalInt", "Intensity_SD", "Intensity_SD_percent");
				labels4 = newArray("Mito_MeanInt_CORR", "Mito_MedianInt_CORR", "Mito_TotalInt_CORR", "Intensity_SD_CORR", "Intensity_SD_percent_CORR");
				labels5 = newArray("Skewness", "Kurtosis", "CristaeOrientation_Major", "CristaeOrientation_Minor","CristaeOrientation_Angle","CristaeOrientation_Area");
				
				if (morpho_measure == "default"){
					default_metrics = "True"; 
					column_arg = "";
					
				} else if (morpho_measure == "custom"){
					default_metrics = "False"; 
					string_arg = newArray(0);
					column_arg = "";
					n_images = 29;
					compt_metrics = 0;
					fieldSize_X1 = 3;
					fieldSize_X2 = 5;
					fieldSize_X3 = 6;
					fieldSize_Y1 = 1;
					fieldSize_Y2 = 2;
					defaults = newArray(n_images);
					defaults1 = newArray(3);
					defaults2 = newArray(10);
					defaults3 = newArray(5);
					defaults4 = newArray(6);
					for (l=0; l<3; l++) {
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
					Dialog.create("Mitochondrial measurements");
					Dialog.addMessage("Select AT LEAST 3 morphometrics to use for display and prediction");
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
					Dialog.addHelp("https://www.emitometrix.org/tutorials.html");
					Dialog.addMessage("\n\n\n(See Help Button for plugin quick start tutorial)");
					Dialog.show();
					for (l=0; l<n_images; l++){
						defaults[l] = Dialog.getCheckbox();
					}
					for (l=0; l<n_images; l++){
						if (defaults[l] == true){
							compt_metrics = compt_metrics+1;
							if (compt_metrics == 1){
								column_arg = labels[l];
							} else if (compt_metrics != 1){
								column_arg = column_arg+","+labels[l];
							}
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
					print("Setting morphometrics to use for display and prediction --------------------------- END\n");
				}
			
			} else if ((prediction_choice == "No") && (ml_choice == "No")){
				morpho_measure = NaN;
				column_arg = "";
			}
			
			
			
			// Setting data visualisation
			//--------------------------------------------------------------------------------------------
			
			if (prediction_choice == "Yes"){
			
				print("Setting Data visualization parameters --------------------------- IN PROGRESS");
				
				Dialog.create("Image analysis : Parameters - Data Visualization");
				Dialog.addMessage("1- Select Graph and distribution to display");
				Dialog.addChoice("Data DISPLAY settings", segmentation_choice);
				Dialog.addHelp("https://www.emitometrix.org/tutorials.html");
				Dialog.addMessage("\n\n\n(See Help Button for plugin quick start tutorial)");
				Dialog.show();
				prediction_method = Dialog.getChoice();
				
				if (prediction_method == "default"){
					waitForUser("WARNING: Spatial clustering will increase calculation time");
				}
				
				labels2 = newArray("PCA", "UMAP", "violin", "density", "histogram", "radar", "spatial_clustering");
				if (prediction_method == "default"){
					default_computation = "True"; 
					no_draw = "False";
					no_save = "False";
					figure_arg = "";
					
				} else if (prediction_method == "custom"){
					default_computation = "False"; 
					no_draw = "False";
					no_save = "False";
					string_arg_V = newArray(0);
					figure_arg = "";
					compt_graph = 0;
					n_images = 7;
					fieldSize_X = 7;
					fieldSize_Y = 1;
					defaults2 = newArray(n_images);
					for (l=0; l<n_images; l++) {
						defaults2[l] = true;
					}
					Dialog.create("Data visualization");
					Dialog.addMessage("Select at least 1 graph or data distribution to display");
					Dialog.addCheckboxGroup(fieldSize_Y,fieldSize_X,labels2,defaults2);
					Dialog.addCheckbox("Don't save output graphic",false);
					Dialog.addCheckbox("Don't display output graphic",false);
					Dialog.addHelp("https://www.emitometrix.org/tutorials.html");
					Dialog.addMessage("\n\n\n(See Help Button for plugin quick start tutorial)");
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
							if (compt_graph == 1){
								figure_arg = labels2[l];
							} else if (compt_graph != 1){
								figure_arg = figure_arg+","+labels2[l];
							}
							string_arg_V = Array.concat(string_arg_V,"--"+labels2[l]);
						}
					}
					
					if (compt_graph == n_images){
						default_computation = "True"; 
					}
					
					if (string_arg_V.length == 0){
						error_prediction_choice = 1;
					}
					
				}
				
				if (error_prediction_choice == 0){
					print("Setting Data visualization parameters --------------------------- END\n");
				}
			
			} else if (prediction_choice == "No"){
				prediction_method = NaN;
				figure_arg = "";
			}
			
			
			
			// Setting Prediction analysis
			//--------------------------------------------------------------------------------------------
			
			if (ml_choice == "Yes"){
			
				print("Setting Data computation and prediction parameters --------------------------- IN PROGRESS");
				
				Dialog.create("Image analysis : Parameters - Data Prediction");
				Dialog.addMessage("1- Select Prediction model to use");
				Dialog.addChoice("Data PREDICTION settings", segmentation_choice);
				Dialog.addHelp("https://www.emitometrix.org/tutorials.html");
				Dialog.addMessage("\n\n\n(See Help Button for plugin quick start tutorial)");
				Dialog.show();
				prediction_type = Dialog.getChoice();
				
				labelsP = newArray("LR", "RF", "XGB", "MLP");
				if (prediction_type == "default"){
					default_prediction = "True"; 
					no_draw_P = "False";
					no_save_P = "False";
					explain = "False";
					model_arg = "";
					
				} else if (prediction_type == "custom"){
					default_prediction = "False"; 
					no_draw_P = "False";
					no_save_P = "False";
					explain = "False";
					string_arg_P = newArray(0);
					model_arg = "";
					compt_graph = 0;
					n_images = 4;
					fieldSize_X = 4;
					fieldSize_Y = 1;
					defaults_P = newArray(n_images);
					for (l=0; l<n_images; l++) {
						defaults_P[l] = true;
					}
					Dialog.create("Data computation and prediction");
					Dialog.addMessage("Select at least 1 model to use for prediction");
					Dialog.addCheckboxGroup(fieldSize_Y,fieldSize_X,labelsP,defaults_P);
					Dialog.addCheckbox("Print out the explanation for each model",false);
					Dialog.addCheckbox("Don't save output graphic",false);
					Dialog.addCheckbox("Don't display output graphic",false);
					Dialog.addHelp("https://www.emitometrix.org/tutorials.html");
					Dialog.addMessage("\n\n\n(See Help Button for plugin quick start tutorial)");
					Dialog.show();
					for (l=0; l<n_images; l++){
						defaults_P[l] = Dialog.getCheckbox();
					}
					explain_tmp = Dialog.getCheckbox();
					save_graphP = Dialog.getCheckbox();
					draw_graphP = Dialog.getCheckbox();
					if ((save_graphP == true) && (draw_graphP == true)){
						no_save_P = "True";
					} else if ((save_graphP == true) && (draw_graphP == false)){
						no_save_P = "True";
					} else if ((save_graphP == false) && (draw_graphP == true)){
						no_draw_P = "True";
					}
					
					if (explain_tmp == true){
						explain = "True";
					}
					
					if ((explain_tmp == true) && (defaults_P[3] == true)){
						waitForUser("!!! WARNING: Computing the explanation for MLP model will substantially increase calculation time !!!");
					}
					
					for (l=0; l<n_images; l++){
						if (defaults_P[l] == true){
							compt_graph = compt_graph+1;
							if (compt_graph == 1){
								model_arg = labelsP[l];
							} else if (compt_graph != 1){
								model_arg = model_arg+","+labelsP[l];
							}
							string_arg_P = Array.concat(string_arg_P,"--"+labelsP[l]);
						}
					}
					
					if (compt_graph == n_images){
						default_prediction = "True"; 
					}
					
					if (string_arg_P.length == 0){
						error_ml_choice = 1;
					}
					
				}
				
				
				if (error_ml_choice == 0){
					print("Setting Data computation parameters --------------------------- END\n");
				}
			
			} else if (ml_choice == "No"){
				prediction_type = NaN;
				model_arg = "";
			}
			
			
			if ((error_prediction_choice == 0) && (error_morpho_choice == 0) && (error_ml_choice == 0) && (error_cellpose_diameter == 0)){
			
			
				// Output folder creation
				//---------------------------------------------------------------------------------------------------------------------------------
				
				if (list_dataset_out.length == 0){
					File.makeDirectory(dir2+"/Image_output/");
					File.makeDirectory(dir2+"/Image_output/cellpose_mask");
					File.makeDirectory(dir2+"/Image_output/processed_images");
					File.makeDirectory(dir2+"/Image_output/control_quality_mask/");
					File.makeDirectory(dir2+"/Measurements/");
					File.makeDirectory(dir2+"/Data_visualization/");
					File.makeDirectory(dir2+"/Data_visualizationspatial_clustering/");
					File.makeDirectory(dir2+"/Prediction_Analysis/");
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
				
				if (displaying_mode == "No"){
					setBatchMode(true);
				}
				
				
				
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				// Mitochondria detection & segmentation
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
				
				if (cellpose_choise == "Yes"){
					
					title_parameters2 = "Users_Mitochondria_size"; 
					title_parameters2 = "["+title_parameters2+"]"; 
					f2=title_parameters2; 
					run("New... ", "name="+title_parameters2+" type=Table"); 
					print(f2,"\\Headings:Condition Name\tImage Name\tMean Diameter\tMinimum Diameter\tMaximum Diameter\tCellpose Trained Model\tCustom Trained Model");
					
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
								
								if (list_img.length > 0) {
								
									dataset=replace(list_dataset[i], "/", "");
									dataset=replace(dataset, " ", "_");
									dataset=replace(dataset, "-", "_");
									File.makeDirectory(dir2+"/Image_output/cellpose_mask/"+dataset);
									File.makeDirectory(dir2+"/Image_output/processed_images/"+dataset);
									File.makeDirectory(dir2+"/Measurements/"+dataset);
									File.makeDirectory(dir2+"/ROI_mito/"+dataset);
									File.makeDirectory(dir2+"/Image_output//control_quality_mask/"+dataset);
									
									if (mito_size == "Depending on Image") {
										
										print("Setting Mitochondria Segmentation parameters --------------------------- PROCESSING");
										
										title_parameters_size = "Image_Mitochondria_Diameter"; 
										title_parameters_size = "["+title_parameters_size+"]"; 
										f3=title_parameters_size; 
										run("New... ", "name="+title_parameters_size+" type=Table"); 
										print(f3,"\\Headings:Image Name\tMean Diameter\tMinimum Diameter (optional)\tMaximum Diameter (optional)");
										
										
										Dialog.create("Automatic Mitochondria Segmentation");
										Dialog.addMessage("Condition : "+dataset);
										Dialog.addMessage("1- Select TRAINED MODEL used for segmentation :");
										Dialog.addChoice("Default model to use", cellpose_model);
										Dialog.addMessage("\n2- If CUSTOM MODEL, select your own model for segmentation");
										Dialog.addFile("Select Custom model to use", "");
										Dialog.addHelp("https://www.emitometrix.org/tutorials.html");
										Dialog.addMessage("\n\n\n(See Help Button for plugin quick start tutorial)");
										Dialog.show();
										object_detection_type = Dialog.getChoice();
										custom_model = Dialog.getString();
									
										if (object_detection_type == "Custom model"){
											if (custom_model == ""){
												Dialog.create("Cellpose : custom model");
												Dialog.addMessage("Select your OWN MODEL used for segmentation :");
												Dialog.show();
												custom_model = Dialog.getString();
											}
											object_detection_type2 = custom_model;
										}
										
										if ((object_detection_type == "GeneralistModel_GM_EM") || (object_detection_type == "Generalist-Fish_Model_GM-FISH_EM") || (object_detection_type == "SpecialistModel_SM_C-ELEGANS_EM") || (object_detection_type == "SpecialistModel_SM_KILLIFISH_EM") || (object_detection_type == "SpecialistModel_SM_FLY_EM") || (object_detection_type == "SpecialistModel_SM_MOUSE_EM") || (object_detection_type == "SpecialistModel_SM_ZEBRAFISH_EM") || (object_detection_type == "SpecialistModel_SM_HUMAN_EM")){
											object_detection_type2 = dir_python_tmp+object_detection_type;
										}
										
										for (cha=0; cha<list_img.length; cha++){
											print(f3,list_img[cha]+"\t0\t0\t0");
										}
										
										selectWindow("Image_Mitochondria_Diameter");
										save(dir2+"Log_files/Image_Mitochondria_Diameter.txt");
										run("Close");
										waitForUser("Please complete Mean, Minimum (optional) and Maximum (optional) diameter from this file:\n\n"+dir2+"Log_files/Image_Mitochondria_Diameter.txt\n\nThen click OK when finished");
										
										
										log_file_tmp = File.exists(dir2+"Log_files/Image_Mitochondria_Diameter.txt");
										if (log_file_tmp == 1){
											path = dir2+"Log_files/Image_Mitochondria_Diameter.txt";
											filestring=File.openAsString(path);
											rows=split(filestring, "\n");
											object_detection_name = newArray(rows.length-1);
											object_detection_size_tmp = newArray(rows.length-1);
											object_detection_size_max_tmp = newArray(rows.length-1);
											object_detection_size_min_tmp = newArray(rows.length-1);
											for (r=1;r<rows.length;r++){
												columns_values = split(rows[r],"\t");
												object_detection_name[r-1] = columns_values[0];
												object_detection_size_tmp [r-1] = columns_values[1];
												object_detection_size_min_tmp [r-1] = columns_values[2];
												object_detection_size_max_tmp [r-1] = columns_values[3];
											}
										}
										
										object_detection_size = newArray(list_img.length);
										object_detection_size_min = newArray(list_img.length);
										object_detection_size_max = newArray(list_img.length);
											
										for (cha=0; cha<list_img.length; cha++){
											img_check = 0;
											img_compt = 0;
											while ((img_check == 0) && (img_compt < object_detection_name.length)){
												if (list_img[cha] == object_detection_name[img_compt]){
													imagename_tmp = 0;
													imagename_tmp = matches(list_img[cha], "#.*");
													if (imagename_tmp == 0){
														if (isNaN(object_detection_size_tmp[img_compt]) == 0){
															object_detection_size[cha] = object_detection_size_tmp[img_compt];
														} else if (isNaN(object_detection_size_tmp[img_compt]) == 1){
															object_detection_size[cha] = NaN;
														}
														if (isNaN(object_detection_size_min_tmp[img_compt]) == 0){
															object_detection_size_min[cha] = object_detection_size_min_tmp[img_compt];
														} else if (isNaN(object_detection_size_min_tmp[img_compt]) == 1){
															object_detection_size_min[cha] = NaN;
														}
														if (isNaN(object_detection_size_max_tmp[img_compt]) == 0){
															object_detection_size_max[cha] = object_detection_size_max_tmp[img_compt];
														} else if (isNaN(object_detection_size_max_tmp[img_compt]) == 1){
															object_detection_size_max[cha] = NaN;
														}
														print(f2,dataset+"\t"+list_img[cha]+"\t"+object_detection_size[cha]+"\t"+object_detection_size_min[cha]+"\t"+object_detection_size_max[cha]+"\t"+object_detection_type+"\t"+custom_model);
													} else if (imagename_tmp == 1){
														object_detection_size[cha] = NaN;
														object_detection_size_min[cha] = NaN;
														object_detection_size_max[cha] = NaN;
													}
													img_check = 1;
												} else if (list_img[cha] != object_detection_name[img_compt]){
													img_compt = img_compt + 1;
												}
											}
										}
										
			
										print("Setting Mitochondria Segmentation parameters --------------------------- END");
										
							
									} else if (mito_size == "Depending on Condition"){
										error_cellpose_diameter = 0;
										for (cha=0; cha<list_img.length; cha++){
											print(f2,dataset+"\t"+list_img[cha]+"\t"+object_detection_size[i]+"\t"+object_detection_size_min[i]+"\t"+object_detection_size_max[i]+"\t"+object_detection_type+"\t"+custom_model);
										}
										
									}
									
									
									if (error_cellpose_diameter == 0){
											
										print("----------------------------------Setting Segmentation parameters-------------------------- OK\n");
									
										// Image file type used for rawdata
										//----------------------------------------------------
										
										compt = 0;
										compt_img = 0;
										
										for (j=0; j<list_img.length; j++) {
											
											error_cellpose_diameter = 0;
											compt = compt+1;
											print("--------------------------------------Image "+compt+"/"+list_img.length+": "+list_img[j]+"-------------------------------- STARTING");
											
											if (mito_size == "Depending on Image"){
												if (isNaN(object_detection_size[j]) == 1){
													error_cellpose_diameter = 1;
												}
											}
											
											if (error_cellpose_diameter == 0){
											
												imagename_tmp = 0;
												imagename_tmp = matches(list_img[j], ".*[]!#$%&'()/*,:;<=>?@^`{|}~].*");
												
												if (imagename_tmp == 0){
													extension_tmp = matches(list_img[j], ".*.tif.*|.*.TIF.*");
													extension_tmp2 = matches(list_img[j], ".*.jpg.*|.*.JPG.*");
													extension_tmp3 = matches(list_img[j], ".*.tiff.*|.*.TIFF.*");
													extension_tmp4 = matches(list_img[j], ".*.png.*|.*.PNG.*");
													extension_tmp5 = matches(list_img[j], ".*.jpeg.*|.*.JPEG.*");
													extension_tmp6 = matches(list_img[j], ".*.bmp.*|.*.BMP.*");
													
													
													if ((extension_tmp2 == 1) || (extension_tmp4 == 1) || (extension_tmp5 == 1)){
														print("File format WARNING: File format selected for "+list_img[j]+" has poor resolution compared to conventional format (TIFF).This can lead to lower quality results ");
													}
													
													
													if ((extension_tmp == 1) || (extension_tmp2 == 1) || (extension_tmp3 == 1) || (extension_tmp4 == 1) || (extension_tmp5 == 1) || (extension_tmp6 == 1)){
														
														if ((displaying_mode == "No") && (compt_img==0)){
															setBatchMode(false);
														}
														path = dir+list_dataset[i]+list_img[j];
														run("Bio-Formats Importer", "open=["+path+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
														//index_tmp=indexOf(list_img[j],".");
														//name_img=substring(list_img[j], 0, index_tmp);
														name_img=File.getNameWithoutExtension(path);
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
														
														if (cropp_choice == "Yes"){
															if (((compt_img == 0) && (cropp_type == "Depending on Condition")) || (cropp_type == "Depending on Image")){
																selectWindow(name_img);
																waitForUser("Select area to crop and click OK.\nIf you don't need to crop, simply click OK ");
																selectWindow(name_img);
																getSelectionBounds(x, y, width_crop, height_crop);
																makeRectangle(x, y, width_crop, height_crop);
																run("Crop");
																run("Select None");
															} else if ((compt_img != 0) && (cropp_type == "Depending on Condition")){
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
														if (filter_choice == "Yes"){
															run("Gaussian Blur...", "sigma=4");
														}
														
														if (gpu_choice == "Yes"){
															flags = "--use_gpu";
														} else if (gpu_choice == "No"){
															flags ="";
														}
														
														if (mito_size == "Depending on Condition"){
															mean_diameter_tmp = object_detection_size[i];
														} else if (mito_size == "Depending on Image"){
															mean_diameter_tmp = object_detection_size[j];
														}
														
														if ((object_detection_type == "cyto2") || (object_detection_type == "cyto") || (object_detection_type == "cyto3") || (object_detection_type == "nuclei")){
															run("Cellpose ...", "env_path="+directory_VE+" env_type=conda model="+object_detection_type+" model_path= diameter="+mean_diameter_tmp+" ch1=0 ch2=-1 additional_flags="+flags);
														} else {
															run("Cellpose ...", "env_path="+directory_VE+" env_type=conda model= model_path="+object_detection_type2+" diameter="+mean_diameter_tmp+" ch1=0 ch2=-1 additional_flags="+flags);
														}
															
														
														
														// Segmentation sequentielle Cellpose
														//---------------------------------------------------------------------------------------------
														
														if (mito_size == "Depending on Condition"){
															max_diameter_tmp = object_detection_size_max[i];
															min_diameter_tmp = object_detection_size_min[i];
														} else if (mito_size == "Depending on Image"){
															max_diameter_tmp = object_detection_size_max[j];
															min_diameter_tmp = object_detection_size_min[j];
														}
														
														if ((max_diameter_tmp != 0) || (min_diameter_tmp != 0)){
															selectWindow(name_img+"-cellpose");
															rename(name_img+"-cellpose-MEAN");
															run("Measure");
															selectWindow("Results");
															num_roi_mean = getResult("Max",0);
															selectWindow("Results");
															run("Close");
															
															if (max_diameter_tmp != 0){
																selectWindow(name_img);
																if ((object_detection_type == "cyto2") || (object_detection_type == "cyto") || (object_detection_type == "cyto3") || (object_detection_type == "nuclei")){
																	run("Cellpose ...", "env_path="+directory_VE+" env_type=conda model="+object_detection_type+" model_path= diameter="+max_diameter_tmp+" ch1=0 ch2=-1 additional_flags="+flags);
																} else {
																	run("Cellpose ...", "env_path="+directory_VE+" env_type=conda model= model_path="+object_detection_type2+" diameter="+max_diameter_tmp+" ch1=0 ch2=-1 additional_flags="+flags);
																}
																selectWindow(name_img+"-cellpose");
																rename(name_img+"-cellpose-LARGE");
																run("Measure");
																selectWindow("Results");
																num_roi_large = getResult("Max",0);
																selectWindow("Results");
																run("Close");
																if (num_roi_large == 0){
																	selectWindow(name_img+"-cellpose-LARGE");
																	close();
																}
															} else if (max_diameter_tmp == 0){
																num_roi_large = 0;
															}
															
															if (min_diameter_tmp != 0){
																selectWindow(name_img);
																if ((object_detection_type == "cyto2") || (object_detection_type == "cyto") || (object_detection_type == "cyto3") || (object_detection_type == "nuclei")){
																	run("Cellpose ...", "env_path="+directory_VE+" env_type=conda model="+object_detection_type+" model_path= diameter="+min_diameter_tmp+" ch1=0 ch2=-1 additional_flags="+flags);
																} else {
																	run("Cellpose ...", "env_path="+directory_VE+" env_type=conda model= model_path="+object_detection_type2+" diameter="+min_diameter_tmp+" ch1=0 ch2=-1 additional_flags="+flags);
																}
																selectWindow(name_img+"-cellpose");
																rename(name_img+"-cellpose-SMALL");
																run("Measure");
																selectWindow("Results");
																num_roi_small = getResult("Max",0);
																selectWindow("Results");
																run("Close");
																if (num_roi_small == 0){
																	selectWindow(name_img+"-cellpose-SMALL");
																	close();
																}
															} else if (min_diameter_tmp == 0){
																num_roi_small = 0;
															}
																								
															
															if ((num_roi_small != 0) && (num_roi_large != 0) && (num_roi_mean == 0)){
																selectWindow(name_img+"-cellpose-SMALL");
																run("Label image to ROIs");
																selectWindow(name_img+"-cellpose-LARGE");
																run("Duplicate...", " ");
																selectWindow(name_img+"-cellpose-LARGE-1");
																setAutoThreshold("Default dark");
																setThreshold(0, 0);
																setOption("BlackBackground", true);
																run("Convert to Mask");
																run("Invert");
																selectWindow(name_img+"-cellpose-SMALL");
																run("Duplicate...", " ");
																selectWindow(name_img+"-cellpose-SMALL-1");
																setAutoThreshold("Default dark");
																setThreshold(0, 0);
																setOption("BlackBackground", true);
																run("Convert to Mask");
																run("Invert");
																imageCalculator("Subtract", name_img+"-cellpose-SMALL-1",name_img+"-cellpose-LARGE-1");
																selectWindow(name_img+"-cellpose-LARGE-1");
																close();
																
																selectWindow(name_img+"-cellpose-SMALL-1");
																roiManager("Show None");
																roiManager("Deselect");
																roiManager("Measure");
																selectWindow("Results");
																roi_OUT = newArray(0);
																for (roi=0;roi<num_roi_small;roi++){
																	area_fraction = getResult("%Area",roi);
																	if (area_fraction < 90){
																		roi_OUT = Array.concat(roi_OUT,roi);
																	}
																}
																selectWindow("Results");
																run("Close");
																
																if (roi_OUT.length != 0){
																	roiManager("Deselect");
																	roiManager("select", roi_OUT);
																	roiManager("Delete");
																}
																num_roi_small = roiManager("count");
																
																if (num_roi_small != 0){
																	for (roi=0;roi<num_roi_small;roi++){
																		value_tmp = num_roi_large+roi+1;
																		selectWindow(name_img+"-cellpose-LARGE");
																		roiManager("select", roi);
																		run("Add...", "value="+value_tmp);
																		roiManager("Deselect");
																		selectWindow(name_img+"-cellpose-LARGE");
																		run("Select None");
																	}
																	roiManager("Deselect");
																	roiManager("Delete");
																	
																	selectWindow(name_img+"-cellpose-SMALL");
																	close();
																	selectWindow(name_img+"-cellpose-LARGE");
																	rename(name_img+"-cellpose");
																	
																} else if (num_roi_small == 0){
																	selectWindow(name_img+"-cellpose-LARGE");
																	close();
																	selectWindow(name_img+"-cellpose-SMALL");
																	rename(name_img+"-cellpose");
																}
																selectWindow(name_img+"-cellpose-MEAN");
																close();
																selectWindow(name_img+"-cellpose-SMALL-1");
																close();
															
															} else if ((num_roi_small == 0) && (num_roi_large == 0) && ((num_roi_mean != 0) || (num_roi_mean == 0))){
																selectWindow(name_img+"-cellpose-MEAN");
																rename(name_img+"-cellpose");
															
															} else if ((num_roi_small != 0) && (num_roi_large == 0) && (num_roi_mean == 0)){
																selectWindow(name_img+"-cellpose-MEAN");
																close();
																selectWindow(name_img+"-cellpose-SMALL");
																rename(name_img+"-cellpose");
																
															} else if ((num_roi_small == 0) && (num_roi_large != 0) && (num_roi_mean == 0)){
																selectWindow(name_img+"-cellpose-MEAN");
																close();
																selectWindow(name_img+"-cellpose-LARGE");
																rename(name_img+"-cellpose");
																															
															} else if ((num_roi_small == 0) && (num_roi_large != 0) && (num_roi_mean != 0)){
																selectWindow(name_img+"-cellpose-MEAN");
																run("Label image to ROIs");
																selectWindow(name_img+"-cellpose-LARGE");
																run("Duplicate...", " ");
																selectWindow(name_img+"-cellpose-LARGE-1");
																setAutoThreshold("Default dark");
																setThreshold(0, 0);
																setOption("BlackBackground", true);
																run("Convert to Mask");
																run("Invert");
																selectWindow(name_img+"-cellpose-MEAN");
																run("Duplicate...", " ");
																selectWindow(name_img+"-cellpose-MEAN-1");
																setAutoThreshold("Default dark");
																setThreshold(0, 0);
																setOption("BlackBackground", true);
																run("Convert to Mask");
																run("Invert");
																imageCalculator("Subtract", name_img+"-cellpose-MEAN-1",name_img+"-cellpose-LARGE-1");
																selectWindow(name_img+"-cellpose-LARGE-1");
																close();
																
																selectWindow(name_img+"-cellpose-MEAN-1");
																roiManager("Show None");
																roiManager("Deselect");
																roiManager("Measure");
																selectWindow("Results");
																roi_OUT = newArray(0);
																for (roi=0;roi<num_roi_mean;roi++){
																	area_fraction = getResult("%Area",roi);
																	if (area_fraction < 90){
																		roi_OUT = Array.concat(roi_OUT,roi);
																	}
																}
																selectWindow("Results");
																run("Close");
																
																if (roi_OUT.length != 0){
																	roiManager("Deselect");
																	roiManager("select", roi_OUT);
																	roiManager("Delete");
																}
																num_roi_mean = roiManager("count");
																
																if (num_roi_mean != 0){
																	for (roi=0;roi<num_roi_mean;roi++){
																		value_tmp = num_roi_large+roi+1;
																		selectWindow(name_img+"-cellpose-LARGE");
																		roiManager("select", roi);
																		run("Add...", "value="+value_tmp);
																		roiManager("Deselect");
																		selectWindow(name_img+"-cellpose-LARGE");
																		run("Select None");
																	}
																	roiManager("Deselect");
																	roiManager("Delete");
																	
																	selectWindow(name_img+"-cellpose-MEAN");
																	close();
																	selectWindow(name_img+"-cellpose-LARGE");
																	rename(name_img+"-cellpose");
																	
																} else if (num_roi_mean == 0){
																	selectWindow(name_img+"-cellpose-LARGE");
																	close();
																	selectWindow(name_img+"-cellpose-MEAN");
																	rename(name_img+"-cellpose");
																}
																selectWindow(name_img+"-cellpose-MEAN-1");
																close();
																
															} else if ((num_roi_small != 0) && ((num_roi_large == 0) || (num_roi_large != 0)) && (num_roi_mean != 0)) {
																selectWindow(name_img+"-cellpose-SMALL");
																run("Label image to ROIs");
																selectWindow(name_img+"-cellpose-MEAN");
																run("Duplicate...", " ");
																selectWindow(name_img+"-cellpose-MEAN-1");
																setAutoThreshold("Default dark");
																setThreshold(0, 0);
																setOption("BlackBackground", true);
																run("Convert to Mask");
																run("Invert");
																selectWindow(name_img+"-cellpose-SMALL");
																run("Duplicate...", " ");
																selectWindow(name_img+"-cellpose-SMALL-1");
																setAutoThreshold("Default dark");
																setThreshold(0, 0);
																setOption("BlackBackground", true);
																run("Convert to Mask");
																run("Invert");
																imageCalculator("Subtract", name_img+"-cellpose-SMALL-1",name_img+"-cellpose-MEAN-1");
																selectWindow(name_img+"-cellpose-MEAN-1");
																close();
																
																selectWindow(name_img+"-cellpose-SMALL-1");
																roiManager("Show None");
																roiManager("Deselect");
																roiManager("Measure");
																selectWindow("Results");
																roi_OUT = newArray(0);
																for (roi=0;roi<num_roi_small;roi++){
																	area_fraction = getResult("%Area",roi);
																	if (area_fraction < 90){
																		roi_OUT = Array.concat(roi_OUT,roi);
																	}
																}
																selectWindow("Results");
																run("Close");
																
																if (roi_OUT.length != 0){
																	roiManager("Deselect");
																	roiManager("select", roi_OUT);
																	roiManager("Delete");
																}
																num_roi_small = roiManager("count");
																
																if (num_roi_small != 0){
																	for (roi=0;roi<num_roi_small;roi++){
																		value_tmp = num_roi_mean+roi+1;
																		selectWindow(name_img+"-cellpose-MEAN");
																		roiManager("select", roi);
																		run("Add...", "value="+value_tmp);
																		roiManager("Deselect");
																		selectWindow(name_img+"-cellpose-MEAN");
																		run("Select None");
																	}
																	roiManager("Deselect");
																	roiManager("Delete");
																	
																	selectWindow(name_img+"-cellpose-SMALL");
																	close();
																	selectWindow(name_img+"-cellpose-MEAN");
																	rename(name_img+"-cellpose");
																	
																} else if (num_roi_small == 0){
																	selectWindow(name_img+"-cellpose-MEAN");
																	close();
																	selectWindow(name_img+"-cellpose-SMALL");
																	rename(name_img+"-cellpose");
																}
																selectWindow(name_img+"-cellpose-SMALL-1");
																close();
																
																if (num_roi_large != 0){
																	selectWindow(name_img+"-cellpose");
																	run("Label image to ROIs");
																	num_roi_mean = roiManager("count");
																	selectWindow(name_img+"-cellpose-LARGE");
																	run("Duplicate...", " ");
																	selectWindow(name_img+"-cellpose-LARGE-1");
																	setAutoThreshold("Default dark");
																	setThreshold(0, 0);
																	setOption("BlackBackground", true);
																	run("Convert to Mask");
																	run("Invert");
																	selectWindow(name_img+"-cellpose");
																	run("Duplicate...", " ");
																	selectWindow(name_img+"-cellpose-1");
																	setAutoThreshold("Default dark");
																	setThreshold(0, 0);
																	setOption("BlackBackground", true);
																	run("Convert to Mask");
																	run("Invert");
																	imageCalculator("Subtract", name_img+"-cellpose-1",name_img+"-cellpose-LARGE-1");
																	selectWindow(name_img+"-cellpose-LARGE-1");
																	close();
																	
																	selectWindow(name_img+"-cellpose-1");
																	roiManager("Show None");
																	roiManager("Deselect");
																	roiManager("Measure");
																	selectWindow("Results");
																	roi_OUT = newArray(0);
																	for (roi=0;roi<num_roi_mean;roi++){
																		area_fraction = getResult("%Area",roi);
																		if (area_fraction < 90){
																			roi_OUT = Array.concat(roi_OUT,roi);
																		}
																	}
																	selectWindow("Results");
																	run("Close");
																	
																	if (roi_OUT.length != 0){
																		roiManager("Deselect");
																		roiManager("select", roi_OUT);
																		roiManager("Delete");
																	}
																	num_roi_mean = roiManager("count");
																	
																	if (num_roi_mean != 0){
																		for (roi=0;roi<num_roi_mean;roi++){
																			value_tmp = num_roi_large+roi+1;
																			selectWindow(name_img+"-cellpose-LARGE");
																			roiManager("select", roi);
																			run("Add...", "value="+value_tmp);
																			roiManager("Deselect");
																			selectWindow(name_img+"-cellpose-LARGE");
																			run("Select None");
																		}
																		roiManager("Deselect");
																		roiManager("Delete");
																		
																		selectWindow(name_img+"-cellpose");
																		close();
																		selectWindow(name_img+"-cellpose-LARGE");
																		rename(name_img+"-cellpose");
																		
																	} else if (num_roi_mean == 0){
																		selectWindow(name_img+"-cellpose-LARGE");
																		close();
																	}
																	selectWindow(name_img+"-cellpose-1");
																	close();
																	
																} 
															} 

														}
														
														
														selectWindow(name_img);
														close();
														selectWindow(name_img+"-cellpose");
														saveAs("Tiff", dir2+"/Image_output/cellpose_mask/"+dataset+"/"+name_img+"_cp_masks");
														close();
														
														print("------------------------------------------------------------------------------------Segmentation------------------------ OK");
														
														if ((displaying_mode == "No") && (compt_img==0)){
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
											
											} else if (error_cellpose_diameter == 1){
												print("Segmentation parameters WARNING : Invalid value for Mitochondria Diameter for "+list_img[j]+".");
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
								error_macro = 1;
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
				// Quality control of Segmented Mitochondria
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
					
				if (cellpose_choise == "Yes"){
				
					print("\nROI SAVING AND QUALITY-CONTROL -------------------------------- STARTING");
					
					list_dataset = getFileList(dir2+"/Image_output/cellpose_mask/");
					list_dataset = Array.sort(list_dataset);
					
					for (i=0; i<list_dataset.length; i++){
					
						if (displaying_mode == "No"){
							setBatchMode(true);
						}
						
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
							run("Label image to ROIs");
							num_roi = roiManager("count");
							
							
							// ROI manager settings
							//--------------------------------------------------------------------------------------
													
							if (num_roi != 0){
								selectWindow(name_img);
								roiManager("Show All");
								roiManager("Show All without labels");
								RoiManager.setGroup(0);
								RoiManager.setPosition(0);
								roiManager("Set Color", "red");
								roiManager("Set Line Width", 3);
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
						
						
						list_img = getFileList(dir2+"/Image_output/control_quality_mask/"+list_dataset[i]);
						list_img = Array.sort(list_img);
						
						if (displaying_mode == "No"){
							setBatchMode(false);
						}
						
						for (j=0; j<list_img.length; j++){
							path_img = dir2+"/Image_output/control_quality_mask/"+list_dataset[i]+list_img[j];
							run("Bio-Formats Importer", "open=["+path_img+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
							index_tmp=indexOf(list_img[j],"_CQ");
							name_img=substring(list_img[j], 0, index_tmp);
							rename(name_img);
							
							CQ_value=getBoolean("Condition "+dataset+" and Image "+name_img+":\n IS MITOCHONDRIAL SEGMENTATION VALID ?");
							if (CQ_value==0) {
								File.rename(dir2+"/Image_output/cellpose_mask/"+list_dataset[i]+name_img+"_cp_masks.tif", dir2+"/Image_output/cellpose_mask/"+list_dataset[i]+name_img+"_cp_masks_INVALID.tif"); 
							}
							selectWindow(name_img);
							close();
							
						}
												
						print("---------Condition "+dataset+"---------------------------------- END\n");		
						
					}
					
					print("ROI SAVING AND QUALITY-CONTROL -------------------------------- END\n");
					
					waitForUser("Automatic mitochondria segmentation DONE !\nPlease restart EMitoMetrix plugin to perform next steps");

				}
				
					
				
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				// Morphological analysis and ultrastructure analysis : Fiji analysis
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
				if (morpho_choice == "Yes"){
								
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

							
						//list_img = getFileList(dir2+"/Image_output/processed_images/"+list_dataset[i]);
						//list_img = Array.sort(list_img);
						
						list_img = getFileList(dir2+"/Image_output/cellpose_mask/"+list_dataset[i]);
						list_img = Array.sort(list_img);
						
						
						
						
						// ultrastructure analysis
						//--------------------------------------------------------------------------------------
						
						compt = 0;
						for (j=0; j<list_img.length; j++){
						
							compt = compt+1;
							index_tmp=indexOf(list_img[j],"_cp_masks");
							name_img_raw=substring(list_img[j], 0, index_tmp);
							
							name_file_tmp = matches(list_img[j], ".*INVALID.*");
							
							if (name_file_tmp == 1){
								print("No valid ROI for Image "+name_img_raw+". Morphological analysis aborted");
								print("--------------------------------------Image "+compt+"/"+list_img.length+": "+name_img_raw+"---------------------------------------- ABORTED");
							} else if (name_file_tmp == 0){
							
								title1 = "Mitochondries_measurements"; 
								title2 = "["+title1+"]"; 
								f=title2; 
								run("New... ", "name="+title2+" type=Table"); 
								print(f,"\\Headings:Experiment_Name\tCondition_Name\tImage_Name\tMito_ID\tMito_Area\tMito_Perimeter\tAreaPerimeter_Ratio\tMito_MeanInt\tMito_MeanInt_CORR\tMito_MedianInt\tMito_MedianInt_CORR\tMito_TotalInt\tMito_TotalInt_CORR\tIntensity_SD\tIntensity_SD_CORR\tIntensity_SD_percent\tIntensity_SD_percent_CORR\tMito_CentroidX\tMito_CentroidY\tMito_Circularity\tMito_Roundness\tMito_Solidity\tMito_AR\tMito_Feret_Diameter\tMito_FeretX\tMito_FeretY\tSkewness\tKurtosis\tCristaeOrientation_Major\tCristaeOrientation_Minor\tCristaeOrientation_Angle\tCristaeOrientation_Area");
					
								path_rawimg = dir2+"/Image_output/processed_images/"+list_dataset[i]+name_img_raw+"_preproc.tif";
								run("Bio-Formats Importer", "open=["+path_rawimg+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
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
										mean_var = (abs(sd_int)/abs(mito_Mean))*100;
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
										mean_var_CORR = (abs(sd_int_CORR)/abs(mito_Mean_CORR))*100;
										
										if ((isNaN(mito_Area) == 1) || (mito_Area == "Infinity") || (mito_Area == "-Infinity")){
											mito_Area = "";
										}
										if ((isNaN(sd_int) == 1) || (sd_int == "Infinity") || (sd_int == "-Infinity")){
											sd_int = "";
										}
										if ((isNaN(mito_Perimeter) == 1) || (mito_Perimeter == "Infinity") || (mito_Perimeter == "-Infinity")){
											mito_Perimeter = "";
										}
										if ((isNaN(mito_Mean) == 1) || (mito_Mean == "Infinity") || (mito_Mean == "-Infinity")){
											mito_Mean = "";
										}
										if ((isNaN(mito_Median) == 1) || (mito_Median == "Infinity") || (mito_Median == "-Infinity")){
											mito_Median = "";
										}
										if ((isNaN(Area_Perimeter_Ratio) == 1) || (Area_Perimeter_Ratio == "Infinity") || (Area_Perimeter_Ratio == "-Infinity")){
											Area_Perimeter_Ratio = "";
										}
										if ((isNaN(mito_Int) == 1) || (mito_Int == "Infinity") || (mito_Int == "-Infinity")){
											mito_Int = "";
										}
										if ((isNaN(mean_var) == 1) || (mean_var == "Infinity") || (mean_var == "-Infinity")){
											mean_var = "";
										}
										if ((isNaN(mito_CX) == 1) || (mito_CX == "Infinity") || (mito_CX == "-Infinity")){
											mito_CX = "";
										}
										if ((isNaN(mito_CY) == 1) || (mito_CY == "Infinity") || (mito_CY == "-Infinity")){
											mito_CY = "";
										}
										if ((isNaN(mito_Circ) == 1) || (mito_Circ == "Infinity") || (mito_Circ == "-Infinity")){
											mito_Circ = "";
										}
										if ((isNaN(mito_Round) == 1) || (mito_Round == "Infinity") || (mito_Round == "-Infinity")){
											mito_Round = "";
										}
										if ((isNaN(mito_Solidity) == 1) || (mito_Solidity == "Infinity") || (mito_Solidity == "-Infinity")){
											mito_Solidity = "";
										}
										if ((isNaN(mito_AR) == 1) || (mito_AR == "Infinity") || (mito_AR == "-Infinity")){
											mito_AR = "";
										}
										if ((isNaN(mito_Feret) == 1) || (mito_Feret == "Infinity") || (mito_Feret == "-Infinity")){
											mito_Feret = "";
										}
										if ((isNaN(mito_FeretX) == 1) || (mito_FeretX == "Infinity") || (mito_FeretX == "-Infinity")){
											mito_FeretX = "";
										}
										if ((isNaN(mito_FeretY) == 1) || (mito_FeretY == "Infinity") || (mito_FeretY == "-Infinity")){
											mito_FeretY = "";
										}
										if ((isNaN(mito_FeretY) == 1) || (mito_FeretY == "Infinity") || (mito_FeretY == "-Infinity")){
											mito_FeretY = "";
										}
										if ((isNaN(mito_Mean_CORR) == 1) || (mito_Mean_CORR == "Infinity") || (mito_Mean_CORR == "-Infinity")){
											mito_Mean_CORR = "";
										}
										if ((isNaN(mito_Median_CORR) == 1) || (mito_Median_CORR == "Infinity") || (mito_Median_CORR == "-Infinity")){
											mito_Median_CORR = "";
										}
										if ((isNaN(mito_Int_CORR) == 1) || (mito_Int_CORR == "Infinity") || (mito_Int_CORR == "-Infinity")){
											mito_Int_CORR = "";
										}
										if ((isNaN(sd_int_CORR) == 1) || (sd_int_CORR == "Infinity") || (sd_int_CORR == "-Infinity")){
											sd_int_CORR = "";
										}
										if ((isNaN(mean_var_CORR) == 1) || (mean_var_CORR == "Infinity") || (mean_var_CORR == "-Infinity")){
											mean_var_CORR = "";
										}
										if ((isNaN(mito_Kurtosis) == 1) || (mito_Kurtosis == "Infinity") || (mito_Kurtosis == "-Infinity")){
											mito_Kurtosis = "";
										}
										if ((isNaN(mito_Skewness) == 1) || (mito_Skewness == "Infinity") || (mito_Skewness == "-Infinity")){
											mito_Skewness = "";
										}
										
										mito_Major = getResult("Major",num+2);
										if ((isNaN(mito_Major) == 1) || (mito_Major == "Infinity") || (mito_Major == "-Infinity")){
											mito_Major = "";
										}
										mito_Minor = getResult("Minor",num+2);
										if ((isNaN(mito_Minor) == 1) || (mito_Minor == "Infinity") || (mito_Minor == "-Infinity")){
											mito_Minor = "";
										}
										mito_Angle = getResult("Angle",num+2);
										if ((isNaN(mito_Angle) == 1) || (mito_Angle == "Infinity") || (mito_Angle == "-Infinity")){
											mito_Angle = "";
										}
										mito_FFT_Area = getResult("Area",num+2);
										if ((isNaN(mito_FFT_Area) == 1) || (mito_FFT_Area == "Infinity") || (mito_FFT_Area == "-Infinity")){
											mito_FFT_Area = "";
										}
										mito_id = a+1;
										
										
											
										if ((mito_Area > 10) && (isNaN(mito_Area) == 0) && (isNaN(mito_Perimeter) == 0) && (isNaN(mito_Mean) == 0) && (isNaN(mito_Median) == 0) && (isNaN(Area_Perimeter_Ratio) == 0) && (isNaN(mito_Int) == 0) && (isNaN(mean_var) == 0) && (isNaN(mito_CX) == 0) && (isNaN(mito_CY) == 0) && (isNaN(mito_Circ) == 0) && (isNaN(mito_Round) == 0) && (isNaN(mito_Solidity) == 0) && (isNaN(mito_AR) == 0) && (isNaN(mito_Feret) == 0) && (isNaN(mito_FeretX) == 0) && (isNaN(mito_FeretY) == 0) && (isNaN(mito_Kurtosis) == 0) && (isNaN(mito_Skewness) == 0) && (isNaN(mito_Mean_CORR) == 0) && (isNaN(mito_Median_CORR) == 0) && (isNaN(mito_Int_CORR) == 0) && (isNaN(sd_int_CORR) == 0) && (isNaN(mean_var_CORR) == 0) && (isNaN(mito_Major) == 0) && (isNaN(mito_Minor) == 0) && (isNaN(mito_Angle) == 0) && (isNaN(mito_FFT_Area) == 0)){
											
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
									print("No valid ROI for Image "+name_img_raw+". Morphological analysis aborted"); 
									print("----------------------------------------------------------------------------------------------------Morphological analysis------------------------ ABORTED");
								}
								
								roiManager("Deselect");
								roiManager("Delete");
								roiManager("reset");
								selectWindow(name_img_raw);
								close();
								
								
								print("----------------------------------------------------------------------------------------------------Saving morphological measurements-------------------------OK");
								
							}
						}
						
						selectWindow("Mitochondries_measurements_ALL");
						save(dir2+"/Measurements_ALL/"+dataset+"_MITO_measurements_ALL_IMAGES.txt"); 
						run("Close");
						
						print("---------Condition "+dataset+"---------------------------------- ENDING\n");
						
					}
					
					print("MITOCHONDRIA MORPHOLOGY ANALYSIS -------------------------------- ENDING\n");
					
					waitForUser("Mitochondria morphology analysis DONE !\nPlease restart EMitoMetrix plugin to perform next steps");
					
				}
					
				
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				// Data display analysis : Python
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
				if (prediction_choice == "Yes"){
					
					print("MITOMETRIX DATA DISPLAY & VISUALIZATION -------------------------------- STARTING");
					
					
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
					Dialog.create("Data visualization");
					Dialog.addMessage("Select at least one condition to use for data visualization");
					Dialog.addCheckboxGroup(fieldSize_Y_cond,fieldSize_X_cond,labels_cond,defaults_cond);
					Dialog.addHelp("https://www.emitometrix.org/tutorials.html");
					Dialog.addMessage("\n\n\n(See Help Button for plugin quick start tutorial)");
					Dialog.show();
					for (l=0; l<n_cond; l++){
						defaults_cond[l] = Dialog.getCheckbox();
					}
					
					for (l=0; l<n_cond; l++){
						if (defaults_cond[l] == true){
							File.makeDirectory(dir2+"/Measurements_TMP/"+labels_cond[l]);
							list_txt = getFileList(dir2+"/Measurements/"+labels_cond[l]);
							for (l2=0;l2<list_txt.length;l2++){
								//name_file_tmp = matches(list_txt[l2], ".*INVALID.*");
								//if (name_file_tmp == 0){
									File.copy(dir2+"/Measurements/"+labels_cond[l]+"/"+list_txt[l2], dir2+"/Measurements_TMP/"+labels_cond[l]+"/"+list_txt[l2])
								//}
							}
						}
					}
						
					
					
					dir_prediction = dir2+"Data_visualization";
					dir_input = dir2+"Measurements_TMP";
					dir_python = dir_python_tmp+"dataComputation.py";
					if (environment_plugin == "Windows"){
						dir_python_exe = directory_VE2+"python";
					} else if ((environment_plugin == "Linux") || (environment_plugin == "MacOS")){
						dir_python_exe = directory_VE2+"/bin/python";
					}
					if (default_computation == "False"){
						string_arg2 = newArray(0);
						string_arg2 = string_arg_V;
					}
					
					if (default_metrics == "True"){
						if (default_computation == "True"){
							option_arg = "default-cols,all-figs";
						} else if ((default_computation == "False") && (no_draw == "False") && (no_save == "False")){
							option_arg = "default-cols";
						} else if ((default_computation == "False") && (no_draw == "True") && (no_save == "True")){
							option_arg = "default-cols,no-draw,no-save";
						} else if ((default_computation == "False") && (no_draw == "True") && (no_save == "False")){
							option_arg = "default-cols,no-draw";
						} else if ((default_computation == "False") && (no_save == "True") && (no_draw == "False")){
							option_arg = "default-cols,no-save";
						}
					
					} else if (default_metrics == "False"){
						if (default_computation == "True"){
							option_arg = "all-figs";
						} else if ((default_computation == "False") && (no_draw == "False") && (no_save == "False")){
							option_arg = "";
						} else if ((default_computation == "False") && (no_draw == "True") && (no_save == "True")){
							option_arg = "no-draw,no-save";
						} else if ((default_computation == "False") && (no_draw == "True") && (no_save == "False")){
							option_arg = "no-draw";
						} else if ((default_computation == "False") && (no_save == "True") && (no_draw == "False")){
							option_arg = "no-save";
						}
					}
					
					exec(dir_python_exe, "-W", "ignore", dir_python, "--input", dir_input, "--output", dir_prediction, "--options", option_arg, "--figure", figure_arg, "--column", column_arg);

					
					
					for (l=0; l<n_cond; l++){
						if (defaults_cond[l] == true){
							list_txt = getFileList(dir2+"/Measurements_TMP/"+labels_cond[l]);
							for (l2=0;l2<list_txt.length;l2++){
								File.delete(dir2+"/Measurements_TMP/"+labels_cond[l]+"/"+list_txt[l2])
							}
							File.delete(dir2+"/Measurements_TMP/"+labels_cond[l]) 
						}
					}
					
					
					list_file_visu = getFileList(dir2+"/Data_visualization/");
					
					if (list_file_visu.length>0){
						match_name_visu = 1;
						num_visu = 0;
						while (match_name_visu == 1){
							num_visu = num_visu+1;
							folder_visu_tmp = "Analysis_"+year+"_"+month+"_"+dayOfMonth+"_version"+num_visu+"/";
							match_name_visu = File.exists(dir2+"/Data_visualization/"+folder_visu_tmp);
						}
						File.makeDirectory(dir2+"/Data_visualization/"+folder_visu_tmp);
						for (file_vis=0; file_vis<list_file_visu.length; file_vis++){
							folder_match = matches(list_file_visu[file_vis], ".*Analysis_.*");
							if (folder_match == 0){
								File.rename(dir2+"/Data_visualization/"+list_file_visu[file_vis], dir2+"/Data_visualization/"+folder_visu_tmp+list_file_visu[file_vis]);
							}
						}
					}
				
				
					match_clustering = 0;
					if (default_computation == "False"){
						num_clus = 0;
						while ((match_clustering == 0) && (num_clus < string_arg2.length)){
							match_clustering = matches(string_arg2[num_clus], "spatial_clustering");
							num_clus = num_clus+1;
						}
					}
					
					
					if ((default_computation == "True") || ((default_computation == "False") && (match_clustering == 1))){
						list_file_visu = getFileList(dir2+"/Data_visualizationspatial_clustering/");
						match_name_visu = 1;
						num_visu = 0;
						while (match_name_visu == 1){
							num_visu = num_visu+1;
							folder_visu_tmp = "Analysis_"+year+"_"+month+"_"+dayOfMonth+"_version"+num_visu+"/";
							match_name_visu = File.exists(dir2+"/Data_visualizationspatial_clustering/"+folder_visu_tmp);
						}
						File.makeDirectory(dir2+"/Data_visualizationspatial_clustering/"+folder_visu_tmp);
						for (file_vis=0; file_vis<list_file_visu.length; file_vis++){
							folder_match = matches(list_file_visu[file_vis], ".*Analysis_.*");
							if (folder_match == 0){
								File.rename(dir2+"/Data_visualizationspatial_clustering/"+list_file_visu[file_vis], dir2+"/Data_visualizationspatial_clustering/"+folder_visu_tmp+list_file_visu[file_vis]);
							}
						}
					}
					
					
					
					print("MITOMETRIX DATA DISPLAY & VISUALIZATION -------------------------------- ENDING\n");
					
					waitForUser("Mitochondria Data display and Visualization DONE !\nPlease restart EMitoMetrix plugin to perform next steps");
					
				}
				
				
				
				
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				// Data computation & prediction analysis : Python
				//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
				if (ml_choice == "Yes"){
						
					print("MITOMETRIX DATA COMPUTATION & PREDICTION -------------------------------- STARTING");
					
					
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
					Dialog.create("Data computation and Prediction");
					Dialog.addMessage("Select at least two conditions to use for prediction");
					Dialog.addCheckboxGroup(fieldSize_Y_cond,fieldSize_X_cond,labels_cond,defaults_cond);
					Dialog.addHelp("https://www.emitometrix.org/tutorials.html");
					Dialog.addMessage("\n\n\n(See Help Button for plugin quick start tutorial)");
					Dialog.show();
					for (l=0; l<n_cond; l++){
						defaults_cond[l] = Dialog.getCheckbox();
					}
					
					for (l=0; l<n_cond; l++){
						if (defaults_cond[l] == true){
							File.makeDirectory(dir2+"/Measurements_TMP/"+labels_cond[l]);
							list_txt = getFileList(dir2+"/Measurements/"+labels_cond[l]);
							for (l2=0;l2<list_txt.length;l2++){
								//name_file_tmp = matches(list_txt[l2], ".*INVALID.*");
								//if (name_file_tmp == 0){
								File.copy(dir2+"/Measurements/"+labels_cond[l]+"/"+list_txt[l2], dir2+"/Measurements_TMP/"+labels_cond[l]+"/"+list_txt[l2])
								//}
							}
						}
					}
						
					
					
					dir_prediction = dir2+"Prediction_Analysis";
					dir_input = dir2+"Measurements_TMP";
					dir_python = dir_python_tmp+"mlComputation.py";
					if (default_prediction == "False"){
						string_arg2 = newArray(0);
						string_arg2 = string_arg_P;
					}
					if (environment_plugin == "Windows"){
						dir_python_exe = directory_VE2+"python";
					} else if ((environment_plugin == "Linux") || (environment_plugin == "MacOS")){
						dir_python_exe = directory_VE2+"/bin/python";
					}
					
					
					if (default_metrics == "True"){
						if (explain == "False"){
							if (default_prediction == "True"){
								option_arg = "default-cols,all-models";
							} else if ((default_prediction == "False") && (no_draw_P == "False") && (no_save_P == "False")){
								option_arg = "default-cols";
							} else if ((default_prediction == "False") && (no_draw_P == "True") && (no_save_P == "True")){
								option_arg = "default-cols,no-draw,no-save";
							} else if ((default_prediction == "False") && (no_draw_P == "True") && (no_save_P == "False")){
								option_arg = "default-cols,no-draw";
							} else if ((default_prediction == "False") && (no_save_P == "True") && (no_draw_P == "False")){
								option_arg = "default-cols,no-save";
							}
						} else if (explain == "True"){
							if (default_prediction == "True"){
								option_arg = "default-cols,all-models,explain";
							} else if ((default_prediction == "False") && (no_draw_P == "False") && (no_save_P == "False")){
								option_arg = "default-cols,explain";
							} else if ((default_prediction == "False") && (no_draw_P == "True") && (no_save_P == "True")){
								option_arg = "default-cols,no-draw,no-save,explain";
							} else if ((default_prediction == "False") && (no_draw_P == "True") && (no_save_P == "False")){
								option_arg = "default-cols,no-draw,explain";
							} else if ((default_prediction == "False") && (no_save_P == "True") && (no_draw_P == "False")){
								option_arg = "default-cols,no-save,explain";
							}
						}
					
					} else if (default_metrics == "False"){
						if (explain == "False"){
							if (default_prediction == "True"){
								option_arg = "all-models";
							} else if ((default_prediction == "False") && (no_draw_P == "False") && (no_save_P == "False")){
								option_arg = "";
							} else if ((default_prediction == "False") && (no_draw_P == "True") && (no_save_P == "True")){
								option_arg = "no-draw,no-save";
							} else if ((default_prediction == "False") && (no_draw_P == "True") && (no_save_P == "False")){
								option_arg = "no-draw";
							} else if ((default_prediction == "False") && (no_save_P == "True") && (no_draw_P == "False")){
								option_arg = "no-save";
							}
						} else if (explain == "True"){
							if (default_prediction == "True"){
								option_arg = "all-models,explain";
							} else if ((default_prediction == "False") && (no_draw_P == "False") && (no_save_P == "False")){
								option_arg = "explain";
							} else if ((default_prediction == "False") && (no_draw_P == "True") && (no_save_P == "True")){
								option_arg = "no-draw,no-save,explain";
							} else if ((default_prediction == "False") && (no_draw_P == "True") && (no_save_P == "False")){
								option_arg = "no-draw,explain";
							} else if ((default_prediction == "False") && (no_save_P == "True") && (no_draw_P == "False")){
								option_arg = "no-save,explain";
							}
						}
					}
					
					exec(dir_python_exe, "-W", "ignore", dir_python, "--input", dir_input, "--output", dir_prediction, "--options", option_arg, "--model", model_arg, "--column", column_arg);
					
					
					
					for (l=0; l<n_cond; l++){
						if (defaults_cond[l] == true){
							list_txt = getFileList(dir2+"/Measurements_TMP/"+labels_cond[l]);
							for (l2=0;l2<list_txt.length;l2++){
								File.delete(dir2+"/Measurements_TMP/"+labels_cond[l]+"/"+list_txt[l2])
							}
							File.delete(dir2+"/Measurements_TMP/"+labels_cond[l]) 
						}
					}
					
					
					
					list_file_pred = getFileList(dir2+"/Prediction_Analysis/");
					
					if (list_file_pred.length>0){
						match_name_pred = 1;
						num_pred = 0;
						while (match_name_pred == 1){
							num_pred = num_pred+1;
							folder_pred_tmp = "Analysis_"+year+"_"+month+"_"+dayOfMonth+"_version"+num_pred+"/";
							match_name_pred = File.exists(dir2+"/Prediction_Analysis/"+folder_pred_tmp);
						}
						File.makeDirectory(dir2+"/Prediction_Analysis/"+folder_pred_tmp);
						for (file_pred=0; file_pred<list_file_pred.length; file_pred++){
							folder_match = matches(list_file_pred[file_pred], ".*Analysis_.*");
							if (folder_match == 0){
								File.rename(dir2+"/Prediction_Analysis/"+list_file_pred[file_pred], dir2+"/Prediction_Analysis/"+folder_pred_tmp+list_file_pred[file_pred]);
							}
						}
					}
					
					print("MITOMETRIX DATA COMPUTATION & PREDICTION -------------------------------- ENDING\n");
					
					waitForUser("Mitochondria Data Computation DONE !\nYour full Mitochondria analysis is done");
					
				}
				
				
				// Log file configuration : user's parameters
				//-----------------------------------------------------------------------------------------------------------------------------------
				
				title_parameters = "Users_general_parameters"; 
				title_parameters = "["+title_parameters+"]"; 
				f0=title_parameters; 
				run("New... ", "name="+title_parameters+" type=Table"); 
				print(f0,"\\Headings:Cellpose Folder\tEMitoMetrix Folder\tPlugin Folder\tGPU choice\tEnvironment\tExperiment Name\tLast Step\tSegmentation Analysis\tMorphometric Analysis\tData Comutation and Display\tData Prediction\tInput Directory\tOutput Directory\tUnit of Length\tImage Normalization\tMito Size Mode\tMorphometric Selected\tGraph Selected\tPrediction Model selected\tPixel Width\tPixel Height");
				print(f0,directory_VE+"\t"+directory_VE2+"\t"+dir_python_tmp+"\t"+gpu_choice+"\t"+environment_plugin+"\t"+condition_name+"\t"+last_step+"\t"+cellpose_choise+"\t"+morpho_choice+"\t"+prediction_choice+"\t"+ml_choice+"\t"+dir+"\t"+dir2+"\t"+unit_of_length+"\t"+norm_type+"\t"+mito_size+"\t"+morpho_measure+"\t"+prediction_method+"\t"+prediction_type+"\t"+pixel_width2+"\t"+pixel_height2);
				selectWindow("Users_general_parameters");
				save(dir2+"/Log_files/Users_general_parameters.txt");
				run("Close");
					
		
			
			} else if ((error_prediction_choice == 1) || (error_morpho_choice == 1) || (error_ml_choice == 1) || (error_cellpose_diameter == 1)){
				if (error_prediction_choice == 1){
					print("Setting Data visualization parameters --------------------------- ERROR");
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
				if (error_ml_choice == 1){
					print("Setting Data computation parameters --------------------------- ERROR\n");
					print("---------- No ML model selected for data prediction. Please select at least 1 model to use for prediction");
					waitForUser("Program ERROR", "No ML model selected for data prediction\nPlease select at least 1 model to use for prediction");
				}
				print("---------------------------ANALYSIS ABORTED---------------------------------\n");
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
	if (plugin_tofind4 == 0){
		print("--------------- Cellpose & Emitometrix conda environment not installed. Please see the readme.txt file and follow the installation instructions");
	}
	print("----------------------ANALYSIS ABORTED----------------------------\n");
}

print("-------------------END OF MITOMETRIX ANALYSIS------------------------");

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// END OF ANALYSIS..............
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
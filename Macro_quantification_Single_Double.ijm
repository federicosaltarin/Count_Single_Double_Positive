//Set the middel slice for later
mid_slice = round(nSlices/2);

directory = getDirectory("Choose a Directory");
fileList = getFileList(directory);

first_image = directory + fileList[1];

// Create sub-directories for summaries and final masks
out_dir = directory + "/Analysis/"; // 
File.makeDirectory(out_dir); 

mask_dir = out_dir + "/Masks/"; // 
File.makeDirectory(mask_dir); 

results_dir = out_dir + "/Results/"; // 
File.makeDirectory(results_dir); 

ROIs_dir = out_dir + "/ROIs/"; // 
File.makeDirectory(ROIs_dir); 

// Setup the threshold level to use later for analysis
open( first_image );
setSlice(mid_slice)
run("Threshold...");
waitForUser("Set the Treshold", "Set the Treshold and click OK");
getThreshold(lower, upper);
close();
//print (lower,upper);

//Define function to analyze the number of cell per channel (single positive) and save results: CSV + mask
function processImages( ) 
{
			waitForUser("Create selection","Make your ROI selection and then click OK to continue: ");
			roiManager("Add");
			roiManager("Save", ""+ROIs_dir+"ROI of" +Title+".roi");	
			run("Clear Outside");
			run("Gaussian Blur...", "sigma=3");	
			setAutoThreshold("Otsu dark");
			setOption("BlackBackground", false);
			setThreshold(lower, upper);
			title = getTitle();
			run("Convert to Mask");
			run("Erode");
			run("Set Measurements...", "area perimeter shape integrated display redirect=None decimal=4");
			run("Analyze Particles...", "size=10-Infinity circularity=0.20-1.00 show=Outlines display summarize");
			saveAs("Results", ""+results_dir+"Summary of " +title+".csv");
			selectWindow("Drawing of "+title+"");  
			saveAs("tiff", ""+mask_dir+"Mask of " +title+".tiff");
			run("Clear Results");
	
}

function analyzeDoublePositive ( ) { 
			//Create image for double positive with AND, logical combination of the 2 channels
			imageCalculator("AND create", "C1-"+Title+"", "C2-"+Title+"");
			//Analyze double positive cells and save results
			run("Set Measurements...", "area perimeter shape integrated display redirect=None decimal=4");
			run("Analyze Particles...", "size=10-Infinity circularity=0.20-1.00 show=Outlines display summarize");
			selectWindow("Drawing of Result of C1-"+Title+"");  
			saveAs("tiff", ""+mask_dir+"Mask of double positive_ " +Title+".tiff");
			saveAs("Results", ""+results_dir+"Summary of double positive_" +Title+".csv");
			selectWindow("Summary"); 
			saveAs("Results", ""+results_dir+"Results_" +Title+".csv");
}		


// Closes the "Results", "Summary", "Threshold", "Log" windows and all image windows
function cleanUp() {
    requires("1.30e");
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );
    }
      if (isOpen("Threshold")) {
         selectWindow("Threshold"); 
         run("Close" );
    }    
    if (isOpen("Summary")) {
         selectWindow("Summary"); 
         run("Close" );
    }
    if (isOpen("Log")) {
         selectWindow("Log");
         run("Close" );
    }
    while (nImages()>0) {
          selectImage(nImages());  
          run("Close");
    }
}	



//Loop through all images and analyze single and double positive cells
for (i = 0; i < fileList.length; i++) {
			path = directory + fileList[i];
			open(path);		
			Title = getTitle();

			run("Split Channels");

			//Analyze the single positive for both channel 1 and 2
			selectWindow("C1-"+Title+"");
			processImages( );
			selectWindow("C2-"+Title+"");
			processImages( );
			//Analyze the double positives
			analyzeDoublePositive ( );			

}

//saveAs("Results", ""+out_dir+"Results.csv");
roiManager("Save", ""+ROIs_dir+"RoiSet.zip");

cleanUp();


		
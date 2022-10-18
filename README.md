# ImageRenamer
A tool to rename images and extract timelapse files.

## How to use this tool

All files should be renamed to the designated metadata standard using the ImageRenamer.R then extract the Timelapse images using TimelapseExtractor.R.

To use this tool, download this repository as a zip file, extract it to a convinent location and follow the steps described in the .R file.

Your photos should be organised in the same way as in the ‘Test_Images_Original” folder, by camera station name. Folders can be nested within the station names folder (i.e. if you have photos from different checks - see ‘ALGAR01’). First run the Renaming script, then run the Timelapse Extractor script (if you use Reconyx units). These will produce two folders which are ready to be archived. 

### Important note
It is crucial that the names of the images in the Wild3 database match the renamed files, this ensures rapid extraction of data subsets. Never rename files after they have been uploaded.

If you plan to use Megadetector, or to blur human faces (using our script), rename the raw images prior to doing so.  

## Phenology
To work with the extracted timelapse photos for phenology/vegetation extraction, refer to the "Z:\Advice & Resources\WildCo R Codes\Extracting_Veg_FromCamTrapTimelapseImgs"

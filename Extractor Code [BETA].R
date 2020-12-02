##########################################
# WildCo Timelapse Image extractor.R
# Updated Oct. 21, 2020 - Chris B
#########################################

# ONLY RUN AFTER USING THE RENAMING TOOL #

# YOU WILL NEED ADMINISTRATOR PRIVILEGES TO USE THIS SCRIPT #

# Install perl prior to exifr installation from http://strawberryperl.com/

# Install the exif tool from https://exiftool.org/

#install.packages("exifr")
library(exifr)
# Should say "Using ExifTool version XX.X" - if it doesn't, make you have admin privilages and reinstall

#install.packages("stringr")
library(stringr)
#install.packages("R.utils")
library(R.utils)


################################
##### createStationFolders #####
## Extract the list of station folders to be renames

# If you are not working within  the WildCo "Example Codes" project you will need to set a working directory. 
# You *should* work inside the project though!
getwd()

# The following two must be edited if you want to use a new folder

# Specify the folder images you want to rename (organised by station)
renamed_images <- "Test_Images_Renamed"
# Specify the location you want the renamed images to go (originals are left untouched)
timelapse_location <- "Timelapse_Images_to_be_sorted" 

################################
################################
# FOR RECONYX CAMERAS
################################


# Create a folder to copy the original images into
dir.create(timelapse_location)

#Check the exif tool is working on the original data
test <- list.files(path = renamed_images,
                   full.names = T, include.dirs = F, recursive = T)[1]

tmp <- read_exif(test, recursive = F, quiet = TRUE) #, tags = c("DateTimeOriginal")
tmp
# You should see a tibble containing the file names the exif data
# If this doesnt work - check your exif installation!


# For each folder, Identify the timelapse photos and copy them over to the timelapse folder

# Get a list of the folders to be renamed
Folders <- list.dirs(path = renamed_images,
                     full.names = FALSE)

# Remove the empty argument
Folders <- Folders[Folders!=""]

# Remove any hollow folders -> folders that don't contain images (e.g. if you are using nested folders, some folders will just contain directories)

i <- 5
for(i in 1: length(Folders))
{
  tmp <-  dir.exists(list.files(path = paste0(renamed_images, "//",Folders[i]),
                                full.names = T, include.dirs = T))
  # Remove folders that just contain folders
  if(length(tmp[tmp==TRUE])>0)
  {
    Folders[i] <- "" 
  }
  # Remove folders that dont contain anything
  if(length(tmp)==0)
  {
    Folders[i] <- "" 
  }
}
Folders <- Folders[Folders!=""]

##### Image Move #####
# Sometimes we have a lot of files and moving them can take a long time, so lets do this folder by folder 
# This will enable you to see progress updates
i <- 1
for(i in 1:length(Folders))
{
  # Read in the files
  tmp.locs <- list.files(path = paste0(renamed_images, "//",Folders[i]),
                         full.names = T, include.dirs = T)
  
  tmp.sta <- gsub("\\__.*", "", sub('.*\\/', '', tmp.locs[1]))
  # Extract the sation ID and make a directory, but only if it doesnt already exists
  if(file.exists(paste0(timelapse_location, "//",tmp.sta))==FALSE)
  {
    dir.create(paste0(timelapse_location, "//",tmp.sta))
  }
  # Subset to just the timelapse
  tmp.exif <- read_exif(tmp.locs, tags = c("TriggerMode"), recursive = F, quiet = TRUE)
  tmp.exif <- tmp.exif[tmp.exif$TriggerMode=="T",]
  file.copy(tmp.exif$SourceFile, paste0(timelapse_location, "//",tmp.sta))   #paste0(tmp.sta, "//",sub('.*\\/', '', tmp.exif$SourceFile))[1])
 
  # Counter
  print(paste(i ,"Folders(s) extracted"))    
}

# Check a folder to see if it has worked!


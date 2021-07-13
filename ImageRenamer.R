##########################################
# WildCo Image Renaming.R
# Updated Aug. 20, 2020 - Chris B
#########################################

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
library(purrr)

################################
##### createStationFolders #####
## Extract the list of station folders to be renames


# Check you have opened the script through the "ImageRenamer.proj" file. The following command should end in '/ImageRenamer' (or whatever you have renamed the project folder to be)
getwd() 
# If you are not working within  the "ImageRenamer.proj" project file - you will need to set a working directory.
# However, I will always recommend that you work inside of a project (for better reproducibility)!


# The following two strings must be edited if you want to use a new folder

# Specify the folder images you want to rename (organised by station)
to_be_renamed <- "Test_Images_Original"

# Specify the location you want the renamed images to go (originals are left untouched)
renamed_location <- "Test_Renamed" 

# IMPORTANT
# Specify if your images are organised into check/deployment subfolders folders  which you want to 
# preserve in your renamed data e.g RICH01/CheckDate1 and ALGAR01/CheckDate2
keep_structure <- TRUE
# NOTE - IF YOU USE THIS THEN ALL STATION FOLDERS MUST HAVE A NESTED CHECK/DEPLOYMENT FOLDER

# If you want to remove that information and merge the images into one folder, specify FALSE
#keep_structure <- FALSE

################################
################################

# Create a folder to copy the original images into
dir.create(renamed_location)

# Copy over the files
copyDirectory(to_be_renamed, renamed_location, private=TRUE, recursive=TRUE)

#Check the exif tool is working on the original data
test <- list.files(path = renamed_location,
                   full.names = T, include.dirs = F, recursive = T)[1]

read_exif(test, tags = c("DateTimeOriginal"), recursive = F, quiet = TRUE)

# You should see a tibble containing the file names and DateTimeOriginal
# If this doesnt work - check your exif installation!


# Get a list of the folders to be renamed
Folders <- list.dirs(path = renamed_location,
                     full.names = FALSE)

# Remove the empty argument
Folders <- Folders[Folders!=""]

# Remove any hollow folders -> folders that don't contain images (e.g. if you are using nested folders, some folders will just contain directories)
for(i in 1: length(Folders))
{
  tmp <-  dir.exists(list.files(path = paste0(renamed_location, "//",Folders[i]),
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

##### imageRename #####
# Sometimes we have a lot of files and renaming can take a long time, so lets do this folder by folder 
# This will enable you to see progress updates

for(i in 1:length(Folders))
{
  # Read in the files
  tmp.locs <- list.files(path = paste0(renamed_location, "//",Folders[i]),
                         full.names = T, include.dirs = T)
  
  # If you have any .db files remove and delete
  for.del <- tmp.locs[str_sub(tmp.locs, start= -2)%in% c("db")]
  if(length(for.del)>0)
  {
    #remove it from your list
    tmp.locs <- tmp.locs[tmp.locs!=for.del]
    # Delete it
    file.remove(for.del)
  }
  # Replace colons with dashes
  tmp.exif <- read_exif(tmp.locs, tags = c("DateTimeOriginal"), recursive = F, quiet = TRUE)
  tmp.exif$DateTimeOriginal <- str_replace_all(tmp.exif$DateTimeOriginal, ":", "-")
  
  new.names<- paste0(renamed_location,"//", Folders[i], "//", 
                     strsplit(Folders[i], "/")[[1]][1], "__",                # The station name (the first element in the string if nested folders are used)
                     gsub( " .*$", "", tmp.exif$DateTimeOriginal), "__",     # The day
                     sub(".*? ", "", tmp.exif$DateTimeOriginal), ".jpg")     # The time 
  
  # if any files have the same name, add a counter (_#) to make it unique
  dups <- new.names[duplicated(new.names)]
  # Subset to the unique values
  dups <- unique(dups)
  # For each duplicate add a counter
  
  if(length(dups) > 0)
  {
    for(j in 1:length(dups))
    {
      n.dups <- length(new.names[new.names==dups[j]])
      new.names[new.names==dups[j]] <- paste0(sub("[.].*", "", new.names[new.names==dups[j]]),"_",1:n.dups, ".jpg")
    }
  }
  
  # Raname the images
  file.rename(tmp.locs, new.names)
  # Counter
  print(paste(i ,"Folders(s) renamed"))    
}

# Check a folder to see if it has worked

###### FOLDER CLEANUP  ###################
##########################################
# Some users want to merge the nested folders into a single Deployment location folder (no nesting),
# Or want to remove subfolders caused by there being lots of images in a given folder (e.g 100RCNX, 101RCNX)
# To do that, run the following code (assuming that the folder structure is Test_Images_Renamed/CameraStation/)

# Uncomment and run the following:

# Combines all images in 100RCNX, 101RCNX, etc. folders into the check/deployment folder

# List of the files you want to organise
to_organise <- list.files(path = renamed_location, recursive = T, full.names = F)

if(keep_structure==TRUE){
# A list how you want your files to be organised
organised <- paste0(unlist(map(strsplit(to_organise, "/"),1)),"/",
                    unlist(map(strsplit(to_organise, "/"),2)), "/", #adds date-date folders
                    mapply('[[', strsplit(to_organise, "/"), 
                           lengths(strsplit(to_organise, "/"))))
} 
if(keep_structure==FALSE){
  organised <- paste0(unlist(map(strsplit(to_organise, "/"),1)),"/", 
                      mapply('[[', strsplit(to_organise, "/"), lengths(strsplit(to_organise, "/"))))
  
}



# Remove files from this list that are already organised in the right way
to_organise <- to_organise[to_organise!=organised]

# Move the remaining files to their new locations
file.rename(paste0(renamed_location,"/", to_organise), #from
            paste0(renamed_location,"/",
                   unlist(map(strsplit(to_organise, "/"),1)),"/",
                   unlist(map(strsplit(to_organise, "/"),2)), "/", #adds date-date folders
                   mapply('[[', strsplit(to_organise, "/"), 
                          lengths(strsplit(to_organise, "/")))))  

### Remove empty folders (e.g. 100RCNX, 101RCNX, etc.)

# Get paths for empty folders
for(i in 1: length(Folders))
{
  tmp <-  dir.exists(list.files(path = paste0(renamed_location, "//", Folders[i]),
                                full.names = T, include.dirs = T))
  # Keep folders that don't contain anything
  if(length(tmp)!=0)
  {
    Folders[i] <- ""
  }
}
Folders <- Folders[Folders!=""]

# Delete the empty folders
unlink(paste0(renamed_location, "/", Folders), recursive = T, force = T)



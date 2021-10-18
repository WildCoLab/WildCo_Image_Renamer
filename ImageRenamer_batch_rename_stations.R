#### WildCo Image Renaming ####
# Updated Aug. 20, 2020 - Chris B
# Updated again 18 May 2021 - Laura Stewart

#### READ THIS CAREFULLY!!! ####
# THIS SCRIPT DIRECTLY RENAMES IMAGES. IT DOES NOT COPY THEM LIKE THE OTHER
# VERSION

# if you are feeling like you need to back up the originals (you probably 
# should), do this manually

# I have edited this to loop through stations as quickly as possible
# with the least manual effort needed. The first part renames images but 
# does not move them. In order for this to work your file
# structure needs to look something like this to begin with:

# ./Project_Name
#     ./Motion_and_Timelapse
#         ./Station_Name1
#               ./DCIM
#                   ./RECXN001
#                         images live in here
#                   ./RECXN002
#                         more images live in here
#         ./Station_Name2
#               ./DCIM
#                   ./RECXN001
#                         images live in here
#                   ./RECXN002
#                         more images live in here
#         ...etc.



# OR


# ./Project_Name
#     ./Motion_and_Timelapse
#         ./Station_Name1
#               ./Deployment1
#                   images live in here
#               ./Deployment2
#                   more images live in here
#         ./Station_Name2
#               ./Deployment1
#                   images live in here
#               ./Deployment2
#                   more images live in here
#         ...etc.

#The ImageRenamer R Project should be living in the ./Project_Name folder.

# You will need admin privileges to use this script

# Install perl prior to exifr installation from http://strawberryperl.com/
# Install the exif tool from https://exiftool.org/

#install.packages("exifr")
library(exifr)
# Should say "Using ExifTool version XX.X" - if it doesn't, make you have admin privileges and reinstall

#install.packages("stringr")
library(stringr)
#install.packages("R.utils")
library(R.utils)
library(purrr)
#install.packages("filesstrings")
library(filesstrings)

##### Get set up #####

# create a project in ./Project_Name level
# then set working directory to "./Motion_and_Timelapse" (see above)

setwd("./Motion_and_Timelapse")
getwd()
orig_dir=getwd()
dir() # should only be station names

# Get a list of the stations to be renamed
Stations <- list.dirs(path = orig_dir, full.names = FALSE,recursive = F)
Stations <- Stations[Stations!=""] # Remove the empty argument
Stations <- Stations[Stations!=".Rproj.user"] #Remove this weird file
Stations

n=length(Stations)
n

#Check the exif tool is working on the original data
j=1 
new_dir=dir(path=orig_dir,full.names = T)[j]
test <- list.files(path = new_dir, full.names = T, include.dirs = F, 
                   recursive = T)[1]
read_exif(test, tags = c("DateTimeOriginal"), recursive = F, quiet = TRUE)

# You should see a tibble containing the file names and DateTimeOriginal
# If this doesnt work - check your exif installation!


#### Rename Images in a loop ####
j=1
for (j in 1:n ) {
  new_dir=dir(path=orig_dir,full.names = T)[j]
  dbfiles=list.files(new_dir,pattern = "*.db",recursive = T,full.names = T) # find .db files
  file.remove(dbfiles) # delete db files
  # Get a list of the folders to be renamed
  Folders <- list.dirs(path = new_dir, full.names = FALSE)
  Folders
  # Remove the empty argument
  Folders <- Folders[Folders!=""]
  
  # Remove any hollow folders -> folders that don't contain images (e.g. if you 
  # are using nested folders, some folders will just contain directories)
  for(i in 1: length(Folders))
  {
    tmp <-  dir.exists(list.files(path = paste0(new_dir, "//",Folders[i]),
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
  Folders
  
  for(i in 1:length(Folders))
  {
    # Read in the files
    tmp.locs <- list.files(path = paste0(new_dir, "//",Folders[i]),
                           full.names = T, include.dirs = T)
    # Replace colons with dashes
    tmp.exif <- read_exif(tmp.locs, tags = c("DateTimeOriginal"), recursive = F, quiet = TRUE)
    tmp.exif$DateTimeOriginal <- str_replace_all(tmp.exif$DateTimeOriginal, ":", "-")
    
    new.names<- paste0(new_dir,"//", Folders[i], "//", 
                       basename(new_dir), "__",                # The station name (the first element in the string if nested folders are used)
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
    print(paste(i ,"/",length(Folders),"Folders(s) renamed at station",basename(new_dir)))    
  }
}

# Check a folder to see if it has worked

###### Optional: Merge Nested Folders ####
# Merge into a single Deployment location folder (no nesting)
# Your final folder structure will look like this:

# ./Project_Name
#     ./Motion_and_Timelapse
#         ./Station_Name1
#               images live in here
#         ./Station_Name2
#               images live in here
#         ./Station_Name3
#               images live in here
#         ...etc.




# Uncomment and run the following:
Stations
j=1

# Step 1 - Move the files

#for (j in 1: length(Stations)){
#  new_dir=dir(path=orig_dir,full.names = T)[j]
#  tmp_file_list=list.files(path = new_dir, full.names = T, include.dirs = F,
#                           all.files = F,recursive = T)
#  tmp_file_list
#  move_files(files = tmp_file_list, destinations = new_dir)
#  print(paste("files moved at",basename(new_dir)))
#}

j=1
# Step 2 - delete empty folders

#for (j in 1: length(Stations)){
#  new_dir=dir(path=orig_dir,full.names = T)[j]
#  directories=rev(list.dirs(path = new_dir, full.names = T, recursive = T))
#  for (k in 1: length(directories)){       # for all of the folders
#    if (length(dir(directories[k]))==0){   # if the folder is empty
#      unlink(directories[k],recursive = T) # delete it
#    }}}




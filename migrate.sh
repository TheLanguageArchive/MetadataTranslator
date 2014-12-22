# this file was used to import the SVN history into git.
svn2git https://svn.mpi.nl/LAT --username twagoo --authors ../users.txt --tags MetadataTranslator/tags --branches MetadataTranslator/branches --trunk MetadataTranslator/trunk;
git remote add origin https://github.com/TheLanguageArchive/MetadataTranslator.git;
git branch --set-upstream-to=origin/master master
git push --all -u;
git push --tags;
# please note that new clones taken from GitHub will not have the svn information required to 
# pull new changes from svn to git. So it is recommended to keep the original that you pushed
# to GitHub if you wish to updates from SVN. If this is not possible you can always pull whole
# lot from SVN again with this script into a fresh Git repostitory.

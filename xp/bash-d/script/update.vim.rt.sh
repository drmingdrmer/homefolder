Vim72=${1-~/share/vim/vim72}
echo vim72=$Vim72
cd $Vim72
rsync -avzcP --exclude="dos" --exclude="spell" ftp.nluug.nl::Vim/runtime/ .
cd -


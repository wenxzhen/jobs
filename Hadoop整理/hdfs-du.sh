SCRIPT=$(basename $0)
function usage(){
    echo -e "\nUSAGE: $SCRIPT <path> <depth>\n"
    exit 1
}

if [ $# -lt 2 ] ; then
   usage
fi

source /etc/profile

function ls_dir(){
    filelist=`hdfs dfs -ls $1 | awk '{print $8}'`
    for file in $filelist
    do 
      hdfs dfs -du -s -h $file
      if [ $2 -le $dep ]; then
        ls_dir $file $[ $2+1 ]
      fi
   done
}

dep=$2
ls_dir $1 2

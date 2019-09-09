#!/bin/sh


prog=`basename $0`
USAGE="Usage: $prog -d directory -f file -l (en|fr) -o output_file [ -x memory ] \n       $prog -h "

help=0

while getopts d:f:hl:o:x: i
        do
        case $i in
                d) dir=$OPTARG;;
                f) file=$OPTARG;;
                h) help=1;;
                l) language=$OPTARG;;
                o) output=$OPTARG;;
                x) memory=$OPTARG;;
               \?) /bin/echo $USAGE >&2
                   exit 1;;
        esac
        done

if [ "$help" -gt 0 ]
then
        /bin/echo -e $USAGE
        /bin/echo ""
        /bin/echo "       -d  indicates the temporary directory where the treatment "
        /bin/echo "           will be done"
        /bin/echo "       -f  gives the name of the file containing the list of files "
        /bin/echo "           to process "
        /bin/echo "       -h  displays that help and exits "
        /bin/echo "       -l  language to process (en|fr) "
        /bin/echo "       -o  gives the name of the output file "
        /bin/echo "       -x  modifies the maximum memory allocation for the Java "
        /bin/echo "           virtual machine (e.g. “512m” or “4g”)"
        /bin/echo ""
        exit 0
fi

if [ -n "$memory" ]
then
        case $memory in
        [1-9][0-9]*[kmg]) memory="-Xmx$memory";;
        *) /bin/echo "$prog: wrong memory value \"$memory\"" >&2
           /bin/echo -e "\nIt should be a positive integer followed by one letter: m or g. " >&2
            exit 4;;
        esac
fi

if [ -z "$dir" -o -z "$file" -o -z "$output" ] 
then
        /bin/echo -e $USAGE >&2
        exit 1
fi

if [ -z "$language" ] 
then
        /bin/echo -e $USAGE >&2
        exit 1
else
        case $language in
        en) ;;
        fr) ;;
         *) /bin/echo "$prog: wrong language option \"$language\"" >&2
            /bin/echo -e "\n$USAGE" >&2
            exit 1;;
        esac
fi

if [ ! -f $file ] 
then
        /bin/echo "$prog: file \"$file\" absent" >&2
        exit 2
fi

if [ ! -d $dir ] 
then
        mkdir -p $dir
fi

if [ ! -d $dir ] 
then
        /bin/echo "$prog: cannot create directory \"$dir\"" >&2
        exit 3
fi

if [ -f $output ]
then
        rm -f $output
fi

touch $output

perl -ne 's/^\s+//o; print if /\w/o;' $file | 
        sort |
        while read x
        do
                y=`basename $x .dat`
                ln -s $x $dir/$y.txt
        done

java $memory -cp /opt/TermSuite/termsuite-core-3.0.10.jar fr.univnantes.termsuite.tools.TerminologyExtractorCLI \
             -t /opt/treetagger/ -c $dir -l $language --json $output

rm -rf $dir


exit 0


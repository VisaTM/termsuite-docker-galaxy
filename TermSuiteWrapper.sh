#!/usr/bin/env bash


prog=`basename $0`
subs=`echo -n $prog | perl -C7 -pe 's/./\x{00A0}/go;'`
USAGE=" \n"
USAGE+="Usage: $prog -d directory -f file -l (en|fr) -o output [ -t (json|tsv) ] \n"
USAGE+="       $subs [ -x memory ] [ -a option ]\n"
USAGE+="       $prog -h "
# USAGE="$part1$part2$part3"

help=0
indice=0
ts="none"

while getopts a:d:f:hl:o:t:x: i
        do
        case $i in
                a) extra[$indice]=$OPTARG
                   indice=$((indice + 1));;
                d) dir=$OPTARG;;
                f) file=$OPTARG;;
                h) help=1;;
                l) language=$OPTARG;;
                o) output=$OPTARG;;
                t) ts=$OPTARG;;
                x) memory=$OPTARG;;
               \?) /bin/echo -e $USAGE >&2
                   exit 1;;
        esac
        done

if [ "$help" -gt 0 ]
then
        /bin/echo -e $USAGE
        /bin/echo ""
        /bin/echo "       -a  add an extra option. An option with an argument must "
        /bin/echo "           be written with an equal sign “=”, as for example: "
        /bin/echo "           “-a --ranking-asc=frequency” "
        /bin/echo "       -d  indicates the temporary directory where the treatment "
        /bin/echo "           will be done"
        /bin/echo "       -f  gives the name of the file containing the list of text "
        /bin/echo "           files to process "
        /bin/echo "       -h  displays that help and exits "
        /bin/echo "       -l  indicates the language to process (en|fr) "
        /bin/echo "       -o  gives the name of the output file (TSV by default) "
        /bin/echo "       -t  outputs the raw TermSuite file (JSON or TSV) "
        /bin/echo "       -x  modifies the maximum memory allocation for the Java "
        /bin/echo "           virtual machine (e.g. “512m” or “4g”)"
        /bin/echo ""
        exit 0
fi

if [ -n "$memory" ]
then
        case $memory in
        [1-9][0-9]*[kmg]) memory="-Xmx$memory";;
        *) /bin/echo -e "\n$prog: wrong memory value “$memory”" >&2
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
         *) /bin/echo -e "\n$prog: wrong language option “$language”" >&2
            /bin/echo -e "\n$USAGE" >&2
            exit 1;;
        esac
fi

if [ -z "$ts" ] 
then
        /bin/echo -e $USAGE >&2
        exit 1
else
        case $ts in
        json) ;;
        none) ;;
        tsv) ;;
         *) /bin/echo -e "\n$prog: wrong option “-t $ts”" >&2
            /bin/echo -e "\n$USAGE" >&2
            exit 1;;
        esac
fi

indice=0
erreur=0
for option in ${extra[@]}
do
        case $option in 
                --capped-size=*) ;; 
                --context-assoc-rate=*) ;;
                --context-coocc-th=*) ;;
                --context-scope=*) ;;
                --contextualize) ;;
                --disable-derivative-splitting) ;;
                --disable-gathering) ;;
                --disable-merging) ;;
                --disable-morphology) ;;
                --disable-native-splitting) ;;
                --disable-post-processing) ;;
                --disable-prefix-splitting) ;;
                --enable-semantic-gathering) ;;
                --encoding=*) ;;
                -e=*) ;;
                --from-prepared-corpus=*) ;;
                --from-text-corpus=*) ;;
                -c=*) ;;
                --graphical-similarity-th=*) ;;
                --nb-semantic-candidates=*) ;;
                --no-occurrence) ;;
                --post-filter-keep-variants) ;;
                --post-filter-max-variants=*) ;;
                --post-filter-property=*) ;;
                --post-filter-th=*) ;;
                --post-filter-top-n=*) ;;
                --postproc-affix-score-th=*) ;;
                --postproc-affix-score-th=*) ;;
                --postproc-independance-th=*) ;;
                --postproc-variation-score-th=*) ;;
                --pre-filter-max-variants=*) ;;
                --pre-filter-property=*) ;;
                --pre-filter-th=*) ;;
                --pre-filter-top-n=*) ;;
                --ranking-asc=*) ;;
                --ranking-desc=*) ;;
                --resource-dir=*) ;;
                --resource-jar=*) ;;
                --resource-url-prefix=*) ;;
                --semantic-dico-only) ;;
                --semantic-distance=*) ;;
                --semantic-similarity-th=*) ;;
                --synonyms-dico=*) ;;
                --tsv-hide-headers) ;;
                --tsv-hide-variants) ;;
                --tsv-properties=*) ;;
                --watch=*) ;;
                *) erreur=$((erreur + 1))
                   echo "$prog: wrong option “$option”" >&2;;
        esac
done

if [ $erreur -gt 0 ]
then
        echo "$prog: too many errors! " >&2
        exit 2
fi

extras=${extra[@]/=/ }

if [ ! -f $file ] 
then
        /bin/echo "$prog: cannot find file “$file”" >&2
        exit 2
fi

if [ ! -d $dir ] 
then
        mkdir -p $dir
fi

if [ ! -d $dir ] 
then
        /bin/echo "$prog: cannot create directory “$dir”" >&2
        exit 3
fi

if [ -f $output ]
then
        rm -f $output
fi

perl -ne 's/^\s+//o; print if /\w/o;' $file | 
        sort |
        while read x
        do
                y=`basename $x .dat`
                ln -s $x $dir/$y.txt
        done

if [ $ts = "json" ]
then
        java $memory -cp /opt/TermSuite/termsuite-core-3.0.10.jar fr.univnantes.termsuite.tools.TerminologyExtractorCLI \
                     -t /opt/treetagger/ -c $dir -l $language --json $output $extras
elif [ $ts = "tsv" ]
then
        java $memory -cp /opt/TermSuite/termsuite-core-3.0.10.jar fr.univnantes.termsuite.tools.TerminologyExtractorCLI \
                     -t /opt/treetagger/ -c $dir -l $language --tsv $output $extras
elif [ $ts = "none" ]
then
        java $memory -cp /opt/TermSuite/termsuite-core-3.0.10.jar fr.univnantes.termsuite.tools.TerminologyExtractorCLI \
                     -t /opt/treetagger/ -c $dir -l $language --json TS_output.json $extras
        TermSuiteJson2Tsv.pl -f TS_output.json -s $output
        rm -r TS_output.json
fi

rm -rf $dir


exit 0


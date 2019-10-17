#!/bin/sh


prog=`basename $0`
USAGE="\n"
USAGE="${USAGE}Usage: $prog -d directory -m metadata_file -l (en|fr) -o output_file [ --json ] [ -x memory ] \n"
USAGE="${USAGE}       $prog -h \n"

help=0
json=0

while getopts d:f:hjl:m:o:x: i
        do
        case $i in
                d) dir=$OPTARG;;
                h) help=1;;
                j) json=1;;
                l) language=$OPTARG;;
                m) file=$OPTARG;;
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
        /bin/echo "       -h  displays that help and exits "
        /bin/echo "       -j  outputs the raw TermSuite JSON file "
        /bin/echo "       -l  indicates the language to process (en|fr) "
        /bin/echo "       -m  gives the name of the metadata file containing the titles "
        /bin/echo "           and abstracts to process "
        /bin/echo "       -o  gives the name of the output file (TSV by default) "
        /bin/echo "       -x  modifies the maximum memory allocation for the Java "
        /bin/echo "           virtual machine (e.g. “512m” or “4g”)"
        /bin/echo ""
        exit 0
fi

if [ -n "$memory" ]
then
        case $memory in
        [1-9][0-9]*[kmg]) memory="-Xmx$memory";;
        *) /bin/echo -e "\n$prog: wrong memory value \"$memory\"" >&2
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

perl -e 'open(INP, "<:utf8", $ARGV[0]) or die "$!,";
         $header = <INP>;
         chomp($header);
         @fields = split(/\t/, $header);
         for ( $n = 0; $n <= $#fields ; $n ++ ) {
                if ( $fields[$n] =~ /^(Filename|Nom de fichier)\z/o ) {
                        $an = $n;
                        }
                if ( $fields[$n] =~ /^(Title|Titre)\z/o ) {
                        $ti = $n;
                        }
                if ( $fields[$n] =~ /^(Abstract|Résumé)\z/o ) {
                        $ab = $n;
                        }
                }
         while(<INP>) {
                chomp;
                @fields = split(/\t/);
                $file = $fields[$an];
                $title = $fields[$ti];
                $abstract = $fields[$ab];
                if ( $file =~ /^(.+)\.\w{3,4}\z/o ) {
                        $file = $1;
                        }
                $file .= ".txt";
                open(OUT, ">:utf8", "$ARGV[1]/$file") or die "$!,";
                print OUT "$ti\n$ab\n";
                close OUT;
                }' $file $dir

if [ $json -gt 0 ]
then
        java $memory -cp /opt/TermSuite/termsuite-core-3.0.10.jar fr.univnantes.termsuite.tools.TerminologyExtractorCLI \
                     -t /opt/treetagger/ -c $dir -l $language --json $output
else
        java $memory -cp /opt/TermSuite/termsuite-core-3.0.10.jar fr.univnantes.termsuite.tools.TerminologyExtractorCLI \
                     -t /opt/treetagger/ -c $dir -l $language --json TS_output.json
        TermSuiteJson2Tsv.pl -f TS_output.json -s $output
        rm -r TS_output.json
fi

rm -rf $dir


exit 0


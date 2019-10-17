#!/usr/bin/perl


# Déclaration des pragmas
use strict;
use utf8;
use open qw/:std :utf8/;

# Appel des modules externes de base
use Encode qw(decode_utf8 encode_utf8 is_utf8);
use Getopt::Long;

my ($programme) = $0 =~ m|^(?:.*/)?(.+)|;
my $substitut = " " x length($programme);

my $usage = "Usage : \n" .
            "    $programme -i input -o output [ -x ]\n" .
            "    $programme -h \n";

my $version   = "0.3.1";
my $dateModif = "September 18, 2019";

# Options
my $aide       = 0;
my $fichier    = "";
my $liste      = "";
my $repertoire = "";
my $sortie     = undef;
my $exclude    = undef;

eval    {
        $SIG{__WARN__} = sub {usage(1);};
        GetOptions(
                "help"       => \$aide,
                "input=s"    => \$fichier,
                "liste=s"    => \$liste,
                "output=s"   => \$sortie,
                "xclude"     => \$exclude,
                );
        };
$SIG{__WARN__} = sub {warn $_[0];};

if ( $aide ) {
        print "\nProgramme : \n    “$programme”, version $version ($dateModif)\n";
        print "    Transforms a list of terms extracted by “TermSuite” into \n";
        print "    a “doc × term” file. \n";
        print "    \n";
        print "$usage\n";
        print "Options : \n";
        print "   -h  displays that help and exits \n";
        print "   -i  gives the name of the input TSV file \n";
#       print "   -l  donne le nom du fichier contenant la liste des mots-clés valides, un \n";
#       print "       par ligne \n";
        print "   -o  gives the name of the output file \n";
        print "   -x  exclude shorter terms present in other terms \n";

        exit 0;
        }

usage(2) if not $fichier;
usage(4) if not $sortie;

# Autres variables
my $current = undef;
my $log10   = log(10);
my %att     = ();
my %statut  = statut();
my %nbDoc   = ();
my %valide  = ();

if ( $liste ) {
        open(MCV, "<:utf8", $liste) or die "$!,";
        while(<MCV>) {
                chomp;
                s/\r//go;
                s/^.*\t//o;
                s/^\s+//o;
                s/\s+\z//o;
                $valide{$_} ++;
                }
        close MCV;
        }

open(OUT, ">:utf8", $sortie)  or die "$!,";
open(INP, "<:utf8", $fichier) or die "$!,";
while(<INP>) {
        chomp;
        my ($file, $nb, $terme, $cat, $str) = split(/\t/);
        if ( $current and $current ne $file ) {
                traite();
                %att = ();
                }
        $current = $file;
        if ( $liste ) {
                next if not $valide{$terme};
                }
        if ( $statut{$cat} ) {
                next if $statut{$cat} eq 'S';
                }
        else    {
                print STDERR "Catégorie gramaticale inédite : “$cat”\n";
                next if $cat =~ /[cprv]/o;
                next if $cat !~ /n/o;
                next if length($cat) < 2;
                }
        $att{$terme}{'nb'} += $nb;
        $att{$terme}{'cat'}{$cat} += $nb;
        $att{$terme}{'str'}{$str} = $nb;
        }
close INP;

if ( $current ) {
        traite();
        }


exit 0;


sub usage
{
print STDERR $usage;

exit shift;
}

sub log10
{
my $valeur = shift;

return log($valeur)/$log10;
}

sub traite
{
if ( $exclude ) {
        my @termes = sort {length($a) <=> length($b) or $a cmp $b} keys %att;
        for ( my $i = 0 ; $i < $#termes ; $i ++ ) {
                for ( my $j = $i + 1 ; $j <= $#termes ; $j ++ ) {
                        if ( $termes[$j] =~ /\b$termes[$i]\b/ ) {
                                delete $att{$termes[$i]};
                                last;
                                }
                        }
                }
        }

foreach my $terme (sort keys %att) {
        print OUT "$current\t$terme\n";
        }
}

sub statut 
{
my %cat = (
        "a"      => "S",
        "aaan"   => "C",
        "aaann"  => "C",
        "aan"    => "C",
        "aann"   => "C",
        "aannn"  => "C",
        "acan"   => "S",
        "acann"  => "S",
        "an"     => "C",
        "anan"   => "C",
        "anann"  => "C",
        "ann"    => "C",
        "annn"   => "C",
        "annnn"  => "C",
        "anpn"   => "S",
        "anpnn"  => "S",
        "n"      => "S",
        "naan"   => "C",
        "nan"    => "C",
        "nann"   => "C",
        "ncan"   => "S",
        "ncnn"   => "S",
        "ncnpn"  => "S",
        "nn"     => "C",
        "nnan"   => "C",
        "nnn"    => "C",
        "nnnn"   => "C",
        "nnnnn"  => "C",
        "nnpn"   => "S",
        "npan"   => "S",
        "npn"    => "S",
        "npncn"  => "S",
        "npncnn" => "S",
        "npnn"   => "S",
        "npnnn"  => "S",
        "npnpn"  => "S",
        "nva"    => "S",
        "r"      => "S",
        "raan"   => "S",
        "ran"    => "S",
        "rann"   => "S",
        "rannn"  => "S",
        );

return %cat;
}
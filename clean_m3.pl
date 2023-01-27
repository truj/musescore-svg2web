#!/usr/bin/perl -w

# expects Musescore 3

use strict;

my $TARGET_DIR = '../midica.org/src/partials/examples';

my $file = $ARGV[0];

sub usage {
	print "$0 path/to/file.svg\n";
	exit 1;
}

# checks
usage() if !$file;
die "File not found: $file\n" if ! -e $file;
die "Not a normal file: $file\n" if ! -f $file;	
die "Not an svg file: $file\n" if $file !~ /\.svg$/;

my $outfile = '';
if ($file =~ /([^\/]+)\.svg$/) {
	my $basename = $1;
	$outfile  = $basename . '___' . '.svg';
}
else {
	die "Something's wrong";
}

# convert
# The first version doesn't work any more on my system - probably due to a bug in inkscape.
# The second one works but it needs the GUI and requires one extra click.
#system "inkscape --verb=FitCanvasToDrawing --verb=FileSave --verb=FileClose --verb=FileQuit '$file'";
system "inkscape --actions='FileSave;FitCanvasToDrawing;FileQuit' --with-gui '$file'";

# get content
my $svg = '';
open(my $in_fh, '<', $file) or die "Cannot open $file: $!\n";
while (my $line = <$in_fh>) {
	$svg .= $line;
}
close $in_fh or die "close failed: $!\n";

# find and convert height
my $height = 0;
if ($svg =~ m/height="([0-9.]+)(px)?"/) {
	$height = $1;
}
die "height not found\n" if ! $height;
$height /= 43;
$height = sprintf '%.2f', $height;
$height .= 'rem';

# replace
$svg =~ s!<\?.+\?>!!g;
$svg =~ s!<sodipodi[^>]+>!!msg;
$svg =~ s!<defs[^>]+>!!msg;
$svg =~ s!<metadata.+</metadata>!!msg;
$svg =~ s!<title.+</title>!!msg;
$svg =~ s!<desc.+</desc>!!msg;
$svg =~ s!xmlns=".+?"!!g;
$svg =~ s!xmlns:\w+=".+?"!!g;
$svg =~ s! sodipodi:.+"!!g;
$svg =~ s! inkscape:.+"!!g;
$svg =~ s! id="[^"]+"!!g;
$svg =~ s! style="[^"]*stroke\-width:12\.5;[^"]*"!REPLACE=2.5!g; # special case: <polyline class="BarLine" ... style="...;stroke-width:2.5;..."
$svg =~ s!<polyline\s+class="BarLine"([^>]+)stroke\-width="12\.50?"!<polyline class="BarLine25" $1!msg; # musescore 3.2.3
# die substr $svg, 0, 3000;
$svg =~ s! style="[^"]+"!!g;
$svg =~ s! version="1.2"!style="height: $height;"!g;

# remove unneeded attributes
$svg =~ s! baseProfile="tiny"!!g;
$svg =~ s! width="[^"]+"!!g;
$svg =~ s! height="[^"]+"!!g;
$svg =~ s! fill="none"!!g;
$svg =~ s! stroke="#000000"!!g;
$svg =~ s! stroke\-width="\d+(\.\d+)?"!!g;
$svg =~ s! stroke\-linejoin="bevel"!!g;
$svg =~ s! stroke\-linecap="square"!!g;

# remove unneeded classes (some are still needed)
$svg =~ s! class="Note"!!g;
$svg =~ s! class="Clef"!!g;
$svg =~ s! class="TimeSig"!!g;
$svg =~ s! class="Rest"!!g;
$svg =~ s! class="Beam"!!g;
$svg =~ s! class="StaffText"!!g;
$svg =~ s! class="Hook"!!g;
$svg =~ s! class="Articulation"!!g;
$svg =~ s! class="TrillSegment"!!g;
$svg =~ s! class="Tremolo"!!g;
$svg =~ s! class="Arpeggio"!!g;

# organize whitespaces
$svg =~ s!^  <!____<!msg;
$svg =~ s![ \r\n]+! !msg;
$svg =~ s!____!\n\t!msg;
$svg =~ s! >!>!g;
$svg =~ s!> !>!g;
$svg =~ s!</svg>!\n</svg>!g;
$svg =~ s!><!>\n\t<!g;

# special case: <polyline class="BarLine" ... style="...;stroke-width:12.5;..."
$svg =~ s!<polyline class="BarLine" (points="[^"]+"( transform="[^"]+")?) REPLACE=2\.5!<polyline class="BarLine25" $1!g;

# Musescore 3 - specific classes
my @convert_classes = qw(
	StaffLines  BarLine  BarLine25  LedgerLine
	Stem        Tuplet   Beam       LyricsLineSegment
);
foreach my $class (@convert_classes) {
	$svg =~ s!(\bclass="$class\b)!$1 v3!g;
}

# write to file
open(my $out_fh, '>', $outfile) or die "Cannot open $outfile: $!\n";
print $out_fh $svg;
close $out_fh or die "close failed: $!\n";

# ask for move
my $target = $TARGET_DIR . '/' . $file . '.html';
my $mv_cmd = "mv '$outfile' '$target'";
print "Move file to partial?\n";
print "$mv_cmd\n";
print "Type upper-cased 'y'\n";
my $response = <STDIN>;
chomp $response;

# move
if ('Y' eq $response) {
	system $mv_cmd;
}


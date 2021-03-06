#!/usr/bin/perl -w

# expects Musescore 2

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
system "inkscape --verb=FitCanvasToDrawing --verb=FileSave --verb=FileClose --verb=FileQuit '$file'";

# get content
my $svg = '';
open(my $in_fh, '<', $file) or die "Cannot open $file: $!\n";
while (my $line = <$in_fh>) {
	$svg .= $line;
}
close $in_fh or die "close failed: $!\n";

# find and convert height
my $height = 0;
if ($svg =~ m/height="([0-9.]+)"/) {
	$height = $1;
}
die "height not found\n" if ! $height;
$height /= 8.75;
$height = sprintf '%.2f', $height;
$height .= 'rem';

# replace
$svg =~ s!<\?.+\?>!!g;
$svg =~ s!<sodipodi[^>]+>!!msg;
$svg =~ s!<defs[^>]+>!!msg;
$svg =~ s!<metadata.+</metadata>!!msg;
$svg =~ s!<title.+</title>!!msg;
$svg =~ s!<desc.+</desc>!!msg;
$svg =~ s!xmlns.+"!!g;
$svg =~ s!sodipodi:.+"!!g;
$svg =~ s!inkscape:.+"!!g;
$svg =~ s!id="[^"]+"!!g;
$svg =~ s!width="[^"]+"!!g;
$svg =~ s!height="[^"]+"!!g;
$svg =~ s!style="[^"]*stroke\-width:2\.5;[^"]*"!REPLACE=2.5!g; # special case: <polyline class="BarLine" ... style="...;stroke-width:2.5;..."
$svg =~ s!style="[^"]+"!!g;
$svg =~ s!version="1.2"!style="height: $height;"!g;

# remove unneeded classes (some are still needed)
$svg =~ s!class="Note"!!g;
$svg =~ s!class="Clef"!!g;
$svg =~ s!class="TimeSig"!!g;
$svg =~ s!class="Rest"!!g;
$svg =~ s!class="Beam"!!g;
$svg =~ s!class="StaffText"!!g;
$svg =~ s!class="Hook"!!g;
$svg =~ s!class="Articulation"!!g;
$svg =~ s!class="TrillSegment"!!g;
$svg =~ s!class="Tremolo"!!g;

# organize whitespaces
$svg =~ s!^  <!____<!msg;
$svg =~ s![ \r\n]+! !msg;
$svg =~ s!____!\n\t!msg;
$svg =~ s! >!>!g;
$svg =~ s!> !>!g;
$svg =~ s!</svg>!\n</svg>!g;

# special case: <polyline class="BarLine" ... style="...;stroke-width:2.5;..."
$svg =~ s!<polyline class="BarLine" (points="[^"]+"( transform="[^"]+")?) REPLACE=2\.5!<polyline class="BarLine25" $1!g;

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


#!/usr/bin/perl

use strict;
use warnings;

my $filename = "sorce code.html";
open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";

my $html_content = do { local $/; <$fh> };
close($fh);

print "[\n";

my $first = 1;
while ($html_content =~ /<tr data-id="(\d+)" data-nation="([^"]*)" data-year="(\d+)".*?>(.*?)<\/tr>/gs) {
    my ($id, $nation, $year, $cells_html) = ($1, $2, $3, $4);

    my $href = "";
    if ($cells_html =~ /<a href="([^"]+)"/) {
        $href = "https://aamcardbase.com/$1";
    }

    my @cells;
    while ($cells_html =~ /<td.*?>(.*?)<\/td>/gs) {
        my $cell_content = $1;
        $cell_content =~ s/<a [^>]*>(.*?)<\/a>/$1/g;
        $cell_content =~ s/<br \s*\/?>/ /g;
        $cell_content =~ s/<[^>]+>//g;
        $cell_content =~ s/^\s+|\s+$//g;
        $cell_content =~ s/\s+/ /g;
        $cell_content =~ s/"/\\"/g;
        push @cells, $cell_content;
    }

    next if @cells < 9;

    my $name = $cells[2];
    my $category_type = $cells[3];
    my $cost = $cells[5];
    my $def_spd = $cells[6];
    my $ai_av = $cells[7];
    my $abilities = $cells[8];

    unless ($first) {
        print ",\n";
    }
    $first = 0;

    print "  {\n";
    print "    \"id\": \"$id\",\n";
    print "    \"nation\": \"$nation\",\n";
    print "    \"year\": \"$year\",\n";
    print "    \"name\": \"$name\",\n";
    print "    \"href\": \"$href\",\n";
    print "    \"category_type\": \"$category_type\",\n";
    print "    \"cost\": \"$cost\",\n";
    print "    \"def_spd\": \"$def_spd\",\n";
    print "    \"ai_av\": \"$ai_av\",\n";
    print "    \"abilities\": \"$abilities\"\n";
    print "  }";
}

print "\n]\n";

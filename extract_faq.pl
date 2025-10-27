#!/usr/bin/perl
use strict;
use warnings;
use Cwd qw(abs_path);
use File::Basename qw(dirname);

# --- Add local lib path ---
my $script_dir = dirname(abs_path($0));
my $lib_path = "$script_dir/JSON-4.10/lib";
unshift @INC, $lib_path;

use JSON;

# --- Configuration ---
my $units_file = 'units.json';
my $faq_file = 'faq.json';
my $debug_html_file = 'debug_unit.html'; # File to save HTML for debugging

# --- Main Logic ---
sub main {
    my $json_text = read_file($units_file);
    my $units = decode_json($json_text);
    my %faq_data;

    print "Starting FAQ extraction for a single unit for debugging...\n";

    my $unit = $units->[0]; # Just get the first unit for debugging
    my $id = $unit->{id};
    my $href = $unit->{href};

    print "Fetching FAQ for unit $id: $unit->{name}\n";

    my $html = `curl -sL "$href"`;
    if ($html) {
        write_file($debug_html_file, $html);
        print "  -> Saved HTML to $debug_html_file\n";
        my $faq_text = extract_faq_from_html($html);
        if ($faq_text) {
            $faq_data{$id} = $faq_text;
            print "  -> Found FAQ.\n";
        } else {
            print "  -> No FAQ found.\n";
        }
    } else {
        print "  -> Failed to fetch URL.\n";
    }

    # write_file($faq_file, encode_json(\%faq_data));
    # print "FAQ extraction complete. Data saved to $faq_file\n";
}

# --- Subroutines ---
sub read_file {
    my ($filename) = @_;
    open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
    my $content = do { local $/; <$fh> };
    close($fh);
    return $content;
}

sub write_file {
    my ($filename, $content) = @_;
    open(my $fh, '>:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
    print $fh $content;
    close($fh);
}

sub extract_faq_from_html {
    my ($html) = @_;
    # The regex might be the issue. Let's try a broader one first.
    if ($html =~ /Special\s+Abilities\s+Errata\s*&\s*FAQ/i) {
        my ($faq_section) = $html =~ /(<a name="specials">.*?)(<a name=|<div id="footer">)/si;
        if ($faq_section) {
            $faq_section =~ s/<[^>]*>//g; # Strip HTML tags
            $faq_section =~ s/^\s+|\s+$//g; # Trim whitespace
            return $faq_section;
        }
    }
    return '';
}

# --- Run ---
main();

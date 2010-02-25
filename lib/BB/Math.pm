# Math.pm (c) 2007-2008 nemesis, l.l.c.

use warnings;
use strict;

package BB::Math;

use POSIX;

# method to handle various calculations...
sub do_calc {

    # preamble...
    my ( $self, %arguments ) = @_;

    # snag the audio/video information...
    my $audio = $self->get_audio();
    my $video = $self->get_video();

    # 'video_bitrate' was passed...
    if ( exists $arguments{video_bitrate} ) {

        # some of this algorithm is based on code from the JavaScript SimpleRip project
        # by Matt Sparks located @ http://f0rked.com/projects/simplerip...

        # prepare values for calculation...
        my $input_length  = $video->{length};
        my $audio_size    = hf_bitrate_2_bytes( $arguments{video_bitrate}->[1], $audio->{length} );
        my $target_size   = $arguments{video_bitrate}->[0] * 1024 * 1024;
        my $avi_overhead  = 0.7;
        my $final_bitrate = hf_calc_bitrate( $target_size, $audio_size, $input_length, $avi_overhead );

        # return the calculated bitrate...
        return $final_bitrate;
    }

    # 'video_scale' was passed...
    if ( exists $arguments{video_scale} ) {

        # some of this algorithm is based on the Perl calcbpp.pl script
        # by Moritz Bunkus located @ http://svn.mplayerhq.hu/mplayer/trunk/TOOLS/calcbpp.pl...

        # preamble...
        my ( %struct, @bpp_list );

        # determine the raw-aspect of the input...
        my $raw_aspect = $video->{width} / $video->{height};

        # determine the cropped but not scaled resolution of the source input...
        my ( $cropped_width, $cropped_height, undef, undef ) 
            = split /\:/x, $self->get_video( autocrop => 1 );

        # prepare values for calculation...
        my $scaled_height = $cropped_height;
        my $scaled_width  = $cropped_width * ( $video->{aspect} / ($raw_aspect) );
        my $bits_ps       = $arguments{video_scale}->[0];
        my $bits_pp       = $arguments{video_scale}->[1];
        my $frames_ps     = $arguments{video_scale}->[2];

        # create a list of various aspect / bpp pairs...
        for ( my $width = $cropped_width; $width >= 320; $width -= 16 ) {

            # modify 'height' values for each iteration through the loop...
            my $height = 16 * hf_round( $width / ( $scaled_width / $scaled_height ) / 16 );

            # assign key/value pairs to structure...
            $struct{"${width}:${height}"} = ( $bits_ps * 1000 ) / ( $width * $height * $frames_ps );
            push @bpp_list, $struct{"${width}:${height}"};
        }

        # loop through the list of scale/bpp pairs...
        while ( my ( $scale, $bpp ) = each %struct ) {

            # if the value matches the desired bpp, return the calculated scale as a string...
            if ( $bpp == hf_closest( $bits_pp, @bpp_list ) ) {
                return $scale;
            }
        }
    }

    # 'longest_title' was passed...
    if ( exists $arguments{longest_title} ) {

        # preamble...
        my $titles = $self->get_titles();
        my @lengths;

        # append all of the title lengths to an array...
        while ( my ( $title, $value ) = each %{$titles} ) {
            push @lengths, $value->{length};
        }

        # determine the longest title length...
        my @numbers = sort { $a <=> $b } @lengths;
        my $longest = $numbers[$#numbers];

        # return the longest title number...
        while ( my ( $title, $value ) = each %{$titles} ) {
            if ( $value->{length} == $longest ) {
                return $title;
            }
        }
    }
    return;

}

# helper function for bitrate 2 bytes conversion...
sub hf_bitrate_2_bytes {

    # preamble...
    my @input = @_;

    # return numeric value...
    return ( $input[0] * $input[1] * 1000 ) / 8.0;
}

# helper function for bytes 2 bitrate conversion...
sub hf_bytes_2_bitrate {

    # preamble...
    my @input = @_;

    # if the length of the input file is more than 0 seconds...
    if ( $input[1] > 0 ) {

        # return numeric value...
        return $input[0] * 8.0 / $input[1] / 1000;
    }
}

# helper function for bitrate calculation...
sub hf_calc_bitrate {

    # preamble...
    my @input = @_;

    # prepare values for calculation...
    my $overhead = 1.0 + ( $input[3] / 100.0 );
    my $size = ( $input[0] - $input[1] ) / $overhead;

    # return in kpbs...
    return floor( hf_bytes_2_bitrate( $size, $input[2] ) );
}

# helper function to round numeric values...
sub hf_round {

    # preamble...
    my $arg = shift;

    # return value...
    return floor( $arg + 0.5 );
}

# helper function to determine closest value...
sub hf_closest {

    # preamble...
    my $arg  = shift;
    my @args = @_;

    # use abs to determine closest value...
    my @list = sort { abs( $a - $arg ) <=> abs( $b - $arg ) } @args;

    # return value...
    return $list[0];
}

# end of class...
1;

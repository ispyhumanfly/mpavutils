# Info.pm (c) 2007-2008 nemesis, l.l.c.

use warnings;
use strict;

package BB::Info;

# method to retrieve video data...
sub get_video {

    # preamble...
    my ( $self, %arguments ) = @_;
    my %struct;

    # provided video autocrop detection was requested...
    if ( exists $arguments{autocrop} ) {

        # double check that this line contains a CROP string...
        if ( ${ $self->{identify} }[ -10 ] =~ /CROP/x ) {

            # let's do some slicing and dicing :)
            my ( undef, $crop_query ) = split /crop=/x, ${ $self->{identify} }[ -10 ];
            my ( $value, undef ) = split /\)/x, $crop_query;

            # assign data to hash...
            return $value;
        }
    }

    # loop through the output collected from the Mplayer '-identify' argument...
    for my $line ( @{ $self->{identify} } ) {

        # video id...
        if ( $line =~ /^ID_VIDEO_ID/x ) {

            # get the attribute and value...
            my ( undef, undef, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$attribute} = $value;
        }

        # video demuxer...
        if ( $line =~ /^ID_DEMUXER/x ) {

            # get the attribute and value...
            my ( undef, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$attribute} = $value;
        }

        # video format...
        if ( $line =~ /^ID_VIDEO_FORMAT/x ) {

            # get the attribute and value...
            my ( undef, undef, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$attribute} = $value;
        }

        # video length...
        if ( $line =~ /^ID_LENGTH/x ) {

            # get the attribute and value...
            my ( undef, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$attribute} = $value;
        }

        # video bitrate...
        if ( $line =~ /^ID_VIDEO_BITRATE/x ) {

            # get the attribute and value...
            my ( undef, undef, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$attribute} = $value;
        }

        # video width...
        if ( $line =~ /^ID_VIDEO_WIDTH/x ) {

            # get the attribute and value...
            my ( undef, undef, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$attribute} = $value;
        }

        # video height...
        if ( $line =~ /^ID_VIDEO_HEIGHT/x ) {

            # get the attribute and value...
            my ( undef, undef, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$attribute} = $value;
        }

        # video fps...
        if ( $line =~ /^ID_VIDEO_FPS/x ) {

            # get the attribute and value...
            my ( undef, undef, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$attribute} = $value;
        }

        # video aspect...
        if ( $line =~ /^ID_VIDEO_ASPECT/x ) {

            # get the attribute and value...
            my ( undef, undef, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$attribute} = $value;
        }

        # video codec...
        if ( $line =~ /^ID_VIDEO_CODEC/x ) {

            # get the attribute and value...
            my ( undef, undef, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$attribute} = $value;
        }
    }
    return \%struct;

}

# method to retrieve audio data...
sub get_audio {

    # preamble...
    my ( $self, %arguments ) = @_;
    my %struct;

    # provided this is a 'tracks' request...
    if ( exists $arguments{tracks} ) {

        # preamble...
        my @tracks;

        # loop through the output collected from the Mplayer '-identify' argument...
        for my $line ( @{ $self->{identify} } ) {
            if ( $line =~ /^ID_AUDIO_ID/x ) {
                my ( undef, $value ) = split /ID_AUDIO_ID=/x, $line;
                push @tracks, int $value;
            }
        }
        return \@tracks;
    }

    # loop through the output collected from the Mplayer '-identify' argument...
    for my $line ( @{ $self->{identify} } ) {

        # audio format...
        if ( $line =~ /^ID_AUDIO_FORMAT/x ) {

            # get the attribute and value...
            my ( undef, undef, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$attribute} = $value;
        }

        # audio bitrate...
        if ( $line =~ /^ID_AUDIO_BITRATE/x ) {

            # get the attribute and value...
            my ( undef, undef, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$attribute} = $value;
        }

        # audio length...
        if ( $line =~ /^ID_LENGTH/x ) {

            # get the attribute and value...
            my ( undef, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$attribute} = $value;
        }

        # audio codec...
        if ( $line =~ /^ID_AUDIO_CODEC/x ) {

            # get the attribute and value...
            my ( undef, undef, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$attribute} = $value;
        }
    }
    return \%struct;

}

# method to retrieve title / chapter data...
sub get_titles {

    # preamble...
    my ( $self, %arguments ) = @_;
    my %struct;

    # loop through the output collected from the Mplayer '-identify' argument...
    for my $line ( @{ $self->{identify} } ) {
        if ( $line =~ /^ID_DVD_TITLE_/x ) {

            # i know this could be done better...
            my ( undef, undef, undef, $title, $attribute, $value ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $attribute =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$title}->{$attribute} = $value;
        }
    }
    return \%struct;

}

# method to handle the extraction of subtitle information...
sub get_subs {

    # preamble...
    my ( $self, %arguments ) = @_;
    my %struct;

    # loop through the output collected from the Mplayer '-identify' argument...
    for my $line ( @{ $self->{identify} } ) {
        if ( $line =~ /^ID_SID_/x ) {

            # i know this could be done better...
            my ( undef, undef, $sid, undef, $lang ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $lang =~ tr/A-Z/a-z/;
            $sid  =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$sid}->{lang} = $lang;
            $struct{$sid}->{sid}  = $sid;
        }
    }
    return \%struct;

}

# method to handle the extraction of language information...
sub get_langs {

    # preamble...
    my ( $self, %arguments ) = @_;
    my %struct;

    # loop through the output collected from the Mplayer '-identify' argument...
    for my $line ( @{ $self->{identify} } ) {
        if ( $line =~ /^ID_AID_/x ) {

            # i know this could be done better...
            my ( undef, undef, $aid, undef, $lang ) = split /\_|\=/x, $line;

            # convert to lowercase...
            $lang =~ tr/A-Z/a-z/;
            $aid  =~ tr/A-Z/a-z/;

            # assign data to hash...
            $struct{$aid}->{lang} = $lang;
            $struct{$aid}->{aid}  = $aid;
        }
    }
    return \%struct;

}

# end of class...
1;

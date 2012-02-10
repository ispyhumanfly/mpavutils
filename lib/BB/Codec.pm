# Codec.pm (c) 2007-2008 nemesis, l.l.c.

use warnings;
use strict;

package BB::Codec;

# method to handle video codec and related settings...
sub do_vcodec {

    # preamble...
    my ( $self, %arguments ) = @_;

    # ffmpeg codec...
    if ( $arguments{codec} eq 'ffmpeg' ) {
        
        # single pass...
        if ( ( $arguments{pass} == 1 ) and ( $arguments{final} == 1 ) ) {

            # codec options...
            my $opts =
                  '-of avi -ovc lavc -lavcopts threads='
                . $arguments{threads}
                . ':vcodec=mpeg4:vstrict=-1:mbd=2:trell:v4mv'
                . ':vmax_b_frames=2:autoaspect:cmp=256:vqcomp=0.6:vqdiff=2'
                . ':vqmax=6:mpeg_quant:vlelim=-4:vcelim=9:lumi_mask=0.05:dark_mask=0.01'
                . ':scplx_mask=0.1:tcplx_mask=0.1:qprd:naq:vbitrate='
                . $arguments{bitrate};

            # and return...
            return $opts;
        }

        # first and subsequent passes...
        if (    ( $arguments{pass} >= 1 )
            and ( $arguments{pass} != $arguments{final} ) )
        {
            # subsequent passes act like a 3rd pass...
            $arguments{pass} = 3 if $arguments{pass} >= 2;
            
            # codec options...
            my $opts =
                  '-of avi -ovc lavc -lavcopts threads='
                . $arguments{threads}
                . ':vcodec=mpeg4:vstrict=-1:mbd=2:trell:v4mv'
                . ':vmax_b_frames=2:autoaspect:cmp=256:vqcomp=0.6:vqdiff=2'
                . ':vqmax=6:mpeg_quant:vlelim=-4:vcelim=9:lumi_mask=0.05:dark_mask=0.01'
                . ':scplx_mask=0.1:tcplx_mask=0.1:qprd:naq:turbo:vpass='
                . $arguments{pass}
                . ':vqscale=2 -passlogfile tmp/bb_pass.log';

            # and return...
            return $opts;
        }

        # final pass...
        if ( $arguments{pass} == $arguments{final} ) {

            # final pass acts like the 2nd pass...
            $arguments{pass} = 2;
            
            # codec options...
            my $opts =
                  '-of avi -ovc lavc -lavcopts threads='
                . $arguments{threads}
                . ':vcodec=mpeg4:vstrict=-1:mbd=2:trell:v4mv'
                . ':vmax_b_frames=2:autoaspect:cmp=256:vqcomp=0.6:vqdiff=2'
                . ':vqmax=6:mpeg_quant:vlelim=-4:vcelim=9:lumi_mask=0.05:dark_mask=0.01'
                . ':scplx_mask=0.1:tcplx_mask=0.1:qprd:naq:vpass='
                . $arguments{pass}
                . ':vbitrate='
                . $arguments{bitrate} . ' -passlogfile tmp/bb_pass.log';

            # and return...
            return $opts;
        }
    }

    # x264 codec...
    if ( $arguments{codec} eq 'x264' ) {

        # single pass...
        if ( ( $arguments{pass} == 1 ) and ( $arguments{final} == 1 ) ) {

            # codec options...
            my $opts =
                  '-of avi -ovc x264 -x264encopts threads='
                . $arguments{threads}
                . ':subq=5:bframes=4:cabac:b_adapt:deblock:frameref=4:b_pyramid'
                . ':qp_step=4:weight_b:chroma_me:qcomp=0.7:bitrate='
                . $arguments{bitrate};

            # and return...
            return $opts;
        }

        # first and subsequent passes...
        if (    ( $arguments{pass} >= 1 )
            and ( $arguments{pass} != $arguments{final} ) )
        {
            # subsequent passes act like a 3rd pass...
            $arguments{pass} = 3 if $arguments{pass} >= 2;

            # codec options...
            my $opts =
                  '-of avi -ovc x264 -x264encopts threads='
                . $arguments{threads}
                . ':subq=5:bframes=4:cabac:b_adapt:deblock:frameref=4:b_pyramid'
                . ':qp_step=4:weight_b:chroma_me:qcomp=0.7:turbo=1:pass='
                . $arguments{pass}
                . ':bitrate='
                . $arguments{bitrate} . ' -passlogfile tmp/bb_pass.log';

            # and return...
            return $opts;
        }

        # final pass...
        if ( $arguments{pass} == $arguments{final} ) {

            # final pass acts like the 2nd pass...
            $arguments{pass} = 2;

            # codec options...
            my $opts =
                  '-of avi -ovc x264 -x264encopts threads='
                . $arguments{threads}
                . ':subq=5:bframes=4:cabac:b_adapt:deblock:frameref=4:b_pyramid'
                . ':qp_step=4:weight_b:chroma_me:qcomp=0.7:pass='
                . $arguments{pass}
                . ':bitrate='
                . $arguments{bitrate} . ' -passlogfile tmp/bb_pass.log';

            # and return...
            return $opts;
        }
    }

    # snow codec...
    if ( $arguments{codec} eq 'snow' ) {

        # single pass...
        if ( ( $arguments{pass} == 1 ) and ( $arguments{final} == 1 ) ) {

            # codec options...
            my $opts =
                  '-of avi -ovc lavc -lavcopts threads='
                . $arguments{threads}
                . ':vcodec=snow:vstrict=-2:autoaspect:cmp=1:subcmp=1'
                . ':mbcmp=1:qpel:vqcomp=0.6:lumi_mask=0.05:dark_mask=0.01'
                . ':scplx_mask=0.1:tcplx_mask=0.1:vbitrate='
                . $arguments{bitrate};

            # and return...
            return $opts;
        }

        # first and subsequent passes...
        if (    ( $arguments{pass} >= 1 )
            and ( $arguments{pass} != $arguments{final} ) )
        {
            # subsequent passes act like a 3rd pass...
            $arguments{pass} = 3 if $arguments{pass} >= 2;

            # codec options...
            my $opts =
                  '-of avi -ovc lavc -lavcopts threads='
                . $arguments{threads}
                . ':vcodec=snow:vstrict=-2:autoaspect:cmp=1:subcmp=1'
                . ':mbcmp=1:qpel:vqcomp=0.6:lumi_mask=0.05:dark_mask=0.01'
                . ':scplx_mask=0.1:tcplx_mask=0.1:turbo:vpass='
                . $arguments{pass}
                . ':vqscale=2 -passlogfile tmp/bb_pass.log';

            # and return...
            return $opts;
        }

        # final pass...
        if ( $arguments{pass} == $arguments{final} ) {

            # final pass acts like the 2nd pass...
            $arguments{pass} = 2;

            # codec options...
            my $opts =
                  '-of avi -ovc lavc -lavcopts threads='
                . $arguments{threads}
                . ':vcodec=snow:vstrict=-2:autoaspect:cmp=1:subcmp=1'
                . ':mbcmp=1:qpel:vqcomp=0.6:lumi_mask=0.05:dark_mask=0.01'
                . ':scplx_mask=0.1:tcplx_mask=0.1:vpass='
                . $arguments{pass}
                . ':vbitrate='
                . $arguments{bitrate} . ' -passlogfile tmp/bb_pass.log';

            # and return...
            return $opts;
        }
    }
    return;

}

# method to handle audio codec and related settings...
sub do_acodec {

    # preamble...
    my ( $self, %arguments ) = @_;

    # this method only works with the final pass...
    return '-nosound' unless $arguments{pass} == $arguments{final};

    # mp2 codec...
    if ( $arguments{codec} eq 'mp2' ) {

        # codec options...
        my $opts =
              '-oac lavc -lavcopts acodec=mp2:abitrate='
            . $arguments{bitrate}
            . ' -aid '
            . $arguments{lang}
            . ' -af volume='
            . $arguments{vol}
            . ':0 -af channels='
            . $arguments{chans};

        # and return...
        return $opts;
    }

    # mp3 codec...
    if ( $arguments{codec} eq 'mp3' ) {

        # codec options...
        my $opts =
              '-oac mp3lame -lameopts abr:br='
            . $arguments{bitrate}
            . ' -aid '
            . $arguments{lang}
            . ' -af volume='
            . $arguments{vol}
            . ':0 -af channels='
            . $arguments{chans};

        # and return...
        return $opts;
    }

    # ac3 codec...
    if ( $arguments{codec} eq 'ac3' ) {

        # codec options...
        my $opts =
              '-oac lavc -lavcopts acodec=ac3:abitrate='
            . $arguments{bitrate}
            . ' -aid '
            . $arguments{lang}
            . ' -af volume='
            . $arguments{vol}
            . ':0 -af channels='
            . $arguments{chans};

        # and return...
        return $opts;
    }

    # faac codec...
    if ( $arguments{codec} eq 'faac' ) {

        # codec options...
        my $opts =
              '-oac faac -faacopts mpeg=4:object=2:br='
            . $arguments{bitrate}
            . ' -aid '
            . $arguments{lang}
            . ' -af volume='
            . $arguments{vol}
            . ':0 -af channels='
            . $arguments{chans};

        # and return...
        return $opts;
    }
    return;
}

# end of class...
1;

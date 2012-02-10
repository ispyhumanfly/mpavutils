#!/usr/bin/perl
#####################################################################
#																	#
# x264/FFMpeg/XviD mencoder script by ispyhumanfly...	            #
#																	#
# (c) 2006 ispyhumanfly (dan stephenson) <ispyhumanfly@gmail.com>	#
#																	#
# This script is free software; you can redistribute it 			#
# and/or modify it under the terms of the GNU Lesser General 		#
# Public License as published by the Free Software Foundation; 		#
# either version 2 of the License, or (at your option) any later 	#
# version.															#
#																	#
# This script is distributed in the hope that it will be useful,	#
# but WITHOUT ANY WARRANTY; without even the implied warranty of	#
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU	#
# Lesser General Public License for more details.					#
#																	#
# You should have received a copy of the GNU Lesser General Public	#
# License along with this library; if not, write to the Free 		#
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, 	#
# MA 02110-1301 USA													#
#																	#
#####################################################################

# required modules...
use Getopt::Long;
use POSIX;

# version information...
my $mp4_version = "v1.1";
my $mp4_date    = "5 August 2006";

# assign value to initial arguments...
my $file_input  = $ARGV[0];
my $file_output = $ARGV[1];

# if --help argument passed..
if (($ARGV[0] eq "--help") or ($ARGV[1] eq "--help")) {
    print_usage();
    exit;
}

# if file input does not have .vob extension or device type...
unless ($file_input =~ /\.vob|dvd:/) {
    encode_status("valid input types must be either .vob or device type!\n",
        "first");
    exit;
}

# if file output does not have .avi or .mp4 container extension...
unless ($file_output =~ /\.mp4|\.avi/) {
    encode_status(
        "valid output file names must have the .avi or .mp4 extension!\n",
        "first");
    exit;
}

# subroutine to process command line arguments...
sub sort_arguments {

    # pre-declare variables...
    my ($a, $b);
    my $argument;
    my $argument_line;
    my $aspect;
    my $v_codec;
    my $a_codec;
    my $a_quality;
    my $lang_track;
    my $filesize;
    my $signature;
    my $change_owner;
    my $sub_track;
    my $sub_name;
    my $test_dvd;
    my $log;
    my $crop;

    # determine command line arguments...
    foreach $argument (@ARGV) {

        # if --screen-XXX switch selected...
        if ($argument =~ /--screen-/) {
            $argument_line = $argument;
            ($a, $b) = split(/--screen-/, $argument_line);

            # sort through screen types...
            unless ($b =~ /wide|full/) {
                encode_status(
                    "valid screen types are wide and full screen only...",
                    "first");
                exit;
            }
            elsif ($b eq "wide") {
                $aspect = 16 / 9;
            }
            elsif ($b eq "full") {
                $aspect = 4 / 3;
            }
        }

        # if --video-XXX switch selected...
        if ($argument =~ /--video-/) {
            $argument_line = $argument;
            ($a, $v_codec) = split(/--video-/, $argument_line);

            # sort through video codecs...
            unless ($v_codec =~ /x264|ffmpeg|xvid/) {
                encode_status(
                    "valid video codecs are x264, ffmpeg or xvid only...",
                    "first");
                exit;
            }
        }

        # if --audio-XXX-XXX switch selected...
        if ($argument =~ /--audio-/) {
            $argument_line = $argument;
            ($a,       $b)         = split(/--audio-/, $argument_line);
            ($a_codec, $a_quality) = split(/-/,        $b);

            # sort through audio codecs...
            unless ($a_codec =~ /faac|mp3|ac3/) {
                encode_status(
                    "valid audio codecs are faac, mp3 or ac3 only...\n",
                    "first");
                exit;
            }

            # sort through audio quality...
#            if ( ( $a_codec eq "faac" ) and ( $a_quality <= 0 ) or ( $a_quality >= 101 ) ) {
#                encode_status( "valid faac quality is between 1 and 100 only...\n", "first" );
#                exit;
#            }
#            elsif ( ( $a_codec eq "mp3" ) or ( $a_codec eq "ac3" ) and ( $a_quality <= 0 ) or ( $a_quality >= 1025 ) ) {
#                encode_status( "valid bitrates for mp3 and ac3 are between 1 and 1024 only...\n", "first" );
#                exit;
#            }
        }

        # if --language-XXX switch selected...
        if ($argument =~ /--language-/) {
            $argument_line = $argument;
            ($a, $lang_track) = split(/--language-/, $argument_line);

            # sort through language tracks...
            unless ($lang_track >= 128) {
                encode_status(
                    "valid language tracks are between 128 and 135 only...\n",
                    "first"
                );
                exit;
            }
        }

        # if --filesize-XXX switch selected...
        if ($argument =~ /--filesize-/) {
            $argument_line = $argument;
            ($a, $filesize) = split(/--filesize-/, $argument_line);

            # sort through file size...
            unless (($filesize >= 10) or ($filesize <= 3000)) {
                encode_status(
                    "valid file sizes are between 25MB and 3000MB's only...\n",
                    "first"
                );
                exit;
            }
        }

        # if --subtitle-XXX switch selected...
        if ($argument =~ /--subtitle-/) {
            $argument_line = $argument;
            ($a,        $sub_track) = split(/--subtitle-/, $argument_line);
            ($sub_name, $b)         = split(/\.avi|\.mp4/, $file_output);

            # sort through subtitle tracks...
            unless (($sub_track >= 0) or ($sub_track <= 31)) {
                encode_status(
                    "valid subtitle tracks are between 0 and 30 only...\n",
                    "first");
                exit;
            }
        }

        # if --signature-XXX switch selected...
        if ($argument =~ /--signature-/) {
            $argument_line = $argument;
            ($a, $signature) = split(/--signature-/, $argument_line);
        }

        # if --chown-XXX switch selected...
        if ($argument =~ /--chown-/) {
            $argument_line = $argument;
            ($a, $change_owner) = split(/--chown-/, $argument_line);
        }

        # if --test switch selected...
        if ($argument eq "--test") {
            $test_dvd = "true";
        }

        # if --logfile switch selected...
        if ($argument eq "--logfile") {
            $log = "true";
        }

        # if --autocrop switch selected...
        if ($argument eq "--autocrop") {
            $crop = "true";
        }
    }

    # missing manditory arguments ie. --switches...
    if (   ($aspect != 16 / 9) and ($aspect != 4 / 3)
        or ($lang_track eq "")
        or ($filesize   eq "")
        or ($a_codec    eq "")
        or ($a_quality  eq "")
        or ($v_codec    eq ""))
    {
        encode_status(
            "missing manditory switch! try --help for usage information...\n",
            "first"
        );
        exit;
    }

    calculate_settings(
        $aspect,     $v_codec,  $a_codec,   $a_quality,
        $lang_track, $filesize, $signature, $change_owner,
        $sub_track,  $sub_name, $test_dvd,  $log,
        $crop
    );

}

# subroutine to calculate audio/video settings...
sub calculate_settings {

    # pre-declare arguments, variables and arrays...
    my $encoded_at    = $_[0];
    my $codec         = $_[1];
    my $audio_codec   = $_[2];
    my $audio_quality = $_[3];
    my $lang          = $_[4];
    my $file_size     = $_[5];
    my $sig           = $_[6];
    my $chown         = $_[7];
    my $subtitle      = $_[8];
    my $subname       = $_[9];
    my $test          = $_[10];
    my $log_file      = $_[11];
    my $auto_crop     = $_[12];
    my $raw_aspect    = 720 / 576;
    my $bpp_set       = 0.240;
    my $audio_output  = "audio.stderr";
    my $video_output  = "video.stderr";
    my $bpp_output    = "bpp.stderr";
    my @mencoder;
    my @final_options;
    my @bits;
    my @lines;

    # determine video data...
    encode_status(
        "creating temporary file to help determine video settings...",
        "first");
    open my $CMD,
      "nice -n 19 mencoder $file_input -ofps 24000/1001 -o temp.avi -oac copy -ovc copy -ss 9:30 -endpos 0:10 1>/dev/tty8 2>/dev/tty8 |"
      or die "unable to open command: $!";
    close($CMD);

    encode_status("loading mplayer to generate video data...");
    open my $CMD,
      "nice -n 19 mplayer temp.avi -nosound -vf cropdetect 1>./video.stderr 2>/dev/tty8 |"
      or die "unable to open command: $!";
    close($CMD);

    # find the mencoder version and build...
    open my $OUTFILE, "<", $video_output
      or die "unable to open $video_output\: $!";
    @lines = <$OUTFILE>;
    foreach $line (@lines) {
        if ($line =~ /Software: /) {
            $software_detected = $line;
            ($a, $software_line) = split(/Software: /, $software_detected);
            $mencoder_version = $software_line;
        }
    }
    close($OUTFILE);

    # if --autocrop switch is true...
    if ($auto_crop eq "true") {

        # find the mplayer detected crop settings...
        open my $OUTFILE, "<", $video_output
          or die "unable to open $video_output\: $!";
        @lines = <$OUTFILE>;
        foreach $line (@lines) {
            if ($line =~ /9\.9/) {
                $crop_lines = $line;
                ($a,      $crop) = split(/crop=/, $crop_lines);
                ($f_crop, $b)    = split(/\)/,    $crop);
                $crop_settings = $f_crop;
            }
        }
        close($OUTFILE);
        encode_status("autocrop settings detected at $crop_settings...");
    }

    # determine length of dvd title...
    encode_status("calculating length of dvd title...");
    open my $CMD,
      "nice -n 19 mencoder $file_input -ofps 24000/1001 -o frameno.avi -oac copy -ovc frameno 1>./audio.stderr 2>/dev/tty8 |"
      or die "unable to open command: $!";
    close($CMD);

    # find the frameno.avi detected audio length...
    open my $OUTFILE, "<", $audio_output
      or die "unable to open $audio_output\: $!";
    @lines = <$OUTFILE>;
    foreach $line (@lines) {
        if ($line =~ /Audio stream:/) {
            $audio_lines = $line;
            ($a,        $audio_b) = split(/bytes  /, $audio_lines);
            ($a_length, $b)       = split(/\./,      $audio_b);
            $audio_length = $a_length;
        }
    }
    close($OUTFILE);
    encode_status("an audio length of "
          . ($audio_length / 60)
          . " minutes has been detected...");
    open my $CMD, "rm -f audio.stderr frameno.avi /dev/null |"
      or die "unable to open command: $!";
    close($CMD);

    # determine bitrate information based on audio codec...
    encode_status(
        "calculating the exact bitrate of the $audio_codec audio codec...");

    if ($audio_codec eq "faac") {
        open my $CMD,
          "nice -n 19 mencoder $file_input -ofps 24000/1001 -o frameno.avi -oac faac -aid $lang -faacopts object=0:tns:quality=$audio_quality -ovc frameno -ss 9:30 -endpos 0:60 1>./audio.stderr 2>/dev/tty8 |"
          or die "unable to open command: $!";
        close($CMD);
    }
    elsif ($audio_codec eq "mp3") {
        open my $CMD,
          "nice -n 19 mencoder $file_input -ofps 24000/1001 -o frameno.avi -oac mp3lame -aid $lang -lameopts abr:br=$audio_quality -ovc frameno -ss 9:30 -endpos 0:60 1>./audio.stderr 2>/dev/tty8 |"
          or die "unable to open command: $!";
        close($CMD);
    }
    elsif ($audio_codec eq "ac3") {
        open my $CMD,
          "nice -n 19 mencoder $file_input -ofps 24000/1001 -o frameno.avi -oac lavc -aid $lang -lavcopts acodec=ac3:abitrate=$audio_quality -ovc frameno -ss 9:30 -endpos 0:60 1>./audio.stderr 2>/dev/tty8 |"
          or die "unable to open command: $!";
        close($CMD);
    }

    # find the actual audio bitrate determined...
    open my $OUTFILE, "<", $audio_output
      or die "unable to open $audio_output\: $!";
    @lines = <$OUTFILE>;
    foreach $line (@lines) {
        if ($line =~ /Audio stream:/) {
            $audio_lines = $line;
            ($a, $abit_a) = split(/Audio stream:  /, $audio_lines);
            ($abit_b, $b) = split(/\./, $abit_a);
            $abit = $abit_b;
        }
    }
    close($OUTFILE);
    encode_status("audio bitrate calculated at $abit\kbps...");
    open my $CMD, "rm -f audio.stderr frameno.avi /dev/null |"
      or die "unable to open command: $!";
    close($CMD);

    # calculate the target file size / bitrate...
    $length = $audio_length;
    $size   = $file_size * 1024;
    $audio  = $abit / 8;
    $b_rate = ($size - ($audio * $length)) / $length * 8;
    ($final_rate, $b) = split(/\./, $b_rate);
    $bitrate = $final_rate;
    encode_status("a bitrate of $bitrate has been calculated...");

    # bits per pixel calculator...
    sub round {
        my $v = shift;
        return floor($v + 0.5);
    }

    # find the aspect ratio detected...
    open my $OUTFILE, "<", $video_output
      or die "unable to open $video_output\: $!";
    @lines = <$OUTFILE>;
    foreach $line (@lines) {
        if ($line =~ /\[\]  /) {
            $rez_detected = $line;
            ($a,            $aspect_line) = split(/\[\]  /, $rez_detected);
            ($aspect_ratio, $c)           = split(" ",       $aspect_line);
            ($unscaled_width, $unscaled_height) = split('x', $aspect_ratio);
        }
    }
    close($OUTFILE);

    if ($encoded_at =~ /\//) {
        my @a = split(/\//, $encoded_at);
        $encoded_at = $a[0] / $a[1];
    }

    # calculate scale...
    $scaled_width  = $unscaled_width * ($encoded_at / ($raw_aspect));
    $scaled_height = $unscaled_height;
    $picture_ar    = $scaled_width / $scaled_height;
    $bps           = $bitrate;
    $fps           = 24;

    # send the calculations to a file for review...
    open my $OUTFILE, ">>", $bpp_output
      or die "unable to open $bpp_output\: $!";
    printf $OUTFILE (
        "Prescaled picture: %dx%d, AR %.2f\n",
        $scaled_width, $scaled_height, $picture_ar
    );

    for ($width = 720; $width >= 320; $width -= 16) {
        $height           = 16 * round($width / $picture_ar / 16);
        $diff             = round($width / $picture_ar - $height);
        $new_ar           = $width / $height;
        $picture_ar_error = abs(100 - $picture_ar / $new_ar * 100);

        printf $OUTFILE (
            "${width}x${height}, diff % 3d, new AR %.2f, AR error %.2f%% "
              . "scale=%d:%d bpp: %.3f\n",
            $diff,
            $new_ar,
            $picture_ar_error,
            $width,
            $height,
            ($bps * 1000) / ($width * $height * $fps)
        );
    }
    close($OUTFILE);

    # determines bpp that is closest to $bpp_set...
    sub closest {
        my $val = shift;
        my @list = sort { abs($a - $val) <=> abs($b - $val) } @_;
        $list[0];
    }

    # now find the most optimum bpp, and select a final scale to use...
    open my $OUTFILE, "<", $bpp_output
      or die "unable to open $bpp_output\: $!";
    @lines = <$OUTFILE>;
    $i     = 0;
    foreach $line (@lines) {
        if ($line =~ /bpp: /) {
            $bpp_lines = $line;
            ($a,   $bpp_line) = split(/bpp: /, $bpp_lines);
            ($bpp, $c)        = split(" ",     $bpp_line);
            $bits[$i] = "$bpp";
            $i++;
        }
    }
    close($OUTFILE);

    # now select the optimum scale with the newly selected bpp...
    open my $OUTFILE, "<", $bpp_output
      or die "unable to open $bpp_output\: $!";
    @lines = <$OUTFILE>;
    $final_bpp = closest($bpp_set, @bits);
    foreach $line (@lines) {
        if ($line =~ /$final_bpp/) {
            $scale_line = $line;
            ($x,       $temp_scale) = split(/scale=/, $scale_line);
            ($f_scale, $x)          = split(" ",      $temp_scale);
            $final_scale = $f_scale;
        }
    }
    close($OUTFILE);
    encode_status("optimum bits per pixel was calculated at $final_bpp...");
    encode_status("optimum scale calculated at $final_scale...");
    open my $CMD, "rm -f video.stderr temp.avi bpp.stderr /dev/null |"
      or die "unable to open command: $!";
    close($CMD);

    # if --logfile switch is true...
    if ($log_file eq "true") {

        encode_log("$file_output", "mencoder version  :: $mencoder_version",
            "first");
        encode_log("$file_output", "video title       :: $file_output");
        encode_log("$file_output", "video size        :: $file_size\MB");
        encode_log("$file_output",
            "video length      :: " . ($audio_length / 60) . " minutes");
        encode_log("$file_output", "video bitrate     :: $bitrate");
        encode_log("$file_output", "video scale       :: $final_scale");
        encode_log("$file_output", "video aspect      :: $encoded_at");

        # if --autocrop switch is true...
        if ($auto_crop eq "true") {
            encode_log("$file_output", "video cropping    :: $crop_settings");
        }

        encode_log("$file_output",
            "audio codec       :: $audio_codec codec family");
        encode_log("$file_output", "audio bitrate     :: $abit\kbps");

        # if --subtitle- switch selected...
        if ($subtitle ne "") {
            encode_log("$file_output",
                "subtitle track    :: $subname ( sub & idx )");
        }

        encode_log("$file_output", "bits per pixel    :: $final_bpp");
        encode_log("$file_output",
            "encode strategy   :: 2-pass $codec codec family");

        # if --signature- switch selected...
        if ($sig ne "") {
            encode_log("$file_output", "ffourcc used      :: $codec");
            encode_log("$file_output", "encoded by        :: $sig", "last");
        }
        else {
            encode_log("$file_output", "ffourcc used      :: $codec", "last");
        }
    }

    # load command line arguments into an array...
    if ($codec eq "x264") {
        $final_options[0] =
          "subq=5:bframes=4:me=2:cabac:b_adapt:deblock:frameref=4:b_pyramid:qp_step=4:4x4mv:weight_b:chroma_me:qcomp=0.7";
    }
    elsif ($codec eq "ffmpeg") {
        $final_options[0] =
          "vcodec=mpeg4:mbd=2:trell:v4mv:autoaspect:cmp=256:vqcomp=0.6:mbqmin=2:mbqmax=10:vqdiff=2:vqmin=2:vqmax=6:mpeg_quant:vlelim=-4:vcelim=9:lumi_mask=0.05:dark_mask=0.01:scplx_mask=0.1:tcplx_mask=0.1:qprd:naq";
    }
    elsif ($codec eq "xvid") {
        $final_options[0] =
          "chroma_opt:vhq=2:gmc:bvhq=1:hq_ac:quant_type=mpeg:lumi_mask:trellis:chroma_me:max_bframes=1";
    }

    # load additional options into an array...
    $final_options[1] = $audio_quality;
    $final_options[2] = $lang;
    $final_options[3] = $bitrate;
    $final_options[4] = $final_scale;
    $final_options[5] = $crop_settings;

    # if --subtitle-XXX swith is selected...
    if ($subtitle ne "") {
        $final_options[6] = $subtitle;
        $final_options[7] = $subname;
    }

    # generate final mencoder options for each pass...
    for ($pass = 1; $pass <= 2; $pass++) {

        # initial commands and audio setup...
        if ($audio_codec eq "faac") {
            $mencoder[0] =
              "nice -n 19 mencoder $file_input -ofps 24000/1001 -oac faac -aid $final_options[2] -faacopts object=0:tns:quality=$final_options[1]";
        }
        elsif ($audio_codec eq "mp3") {
            $mencoder[0] =
              "nice -n 19 mencoder $file_input -ofps 24000/1001 -oac mp3lame -aid $final_options[2] -lameopts abr:br=$final_options[1]";
        }
        elsif ($audio_codec eq "ac3") {
            $mencoder[0] =
              "nice -n 19 mencoder $file_input -ofps 24000/1001 -oac lavc -aid $final_options[2] -lavcopts acodec=ac3:abitrate=$final_options[1]";
        }

        # pass one file output...
        if ($pass == 1) {
            if ($codec eq "x264") {
                $mencoder[1] = "-o /dev/null -ovc x264";
            }
            elsif ($codec eq "ffmpeg") {
                $mencoder[1] = "-o /dev/null -ovc lavc";
            }
            elsif ($codec eq "xvid") {
                $mencoder[1] = "-o /dev/null -ovc xvid";
            }
        }

        # pass two file output...
        if ($pass == 2) {
            if ($codec eq "x264") {
                $mencoder[1] = "-o $file_output -ovc x264";
            }
            elsif ($codec eq "ffmpeg") {
                $mencoder[1] = "-o $file_output -ovc lavc";
            }
            elsif ($codec eq "xvid") {
                $mencoder[1] = "-o $file_output -ovc xvid";
            }
        }

        # pass one encoding options...
        if ($pass == 1) {
            if ($codec eq "x264") {
                $mencoder[2] =
                  "-x264encopts $final_options[0]:bitrate=$final_options[3]:pass=$pass:turbo=1";
            }
            elsif ($codec eq "ffmpeg") {
                $mencoder[2] =
                  "-lavcopts $final_options[0]:vbitrate=$final_options[3]:vpass=$pass:turbo";
            }
            elsif ($codec eq "xvid") {
                $mencoder[2] =
                  "-xvidencopts $final_options[0]:turbo:pass=$pass";
            }
        }

        # pass two encoding options...
        if ($pass == 2) {
            if ($codec eq "x264") {
                $mencoder[2] =
                  "-x264encopts $final_options[0]:bitrate=$final_options[3]:pass=$pass";
            }
            elsif ($codec eq "ffmpeg") {
                $mencoder[2] =
                  "-lavcopts $final_options[0]:vbitrate=$final_options[3]:vpass=$pass";
            }
            elsif ($codec eq "xvid") {
                $mencoder[2] =
                  "-xvidencopts $final_options[0]:bitrate=$final_options[3]:pass=$pass";
            }
        }

        # scaling, cropping and video filters used...
        if ($auto_crop eq "true") {
            $mencoder[3] =
              "-vf pullup,softskip,crop=$final_options[5],scale=$final_options[4]";
        }
        else {
            $mencoder[3] = "-vf pullup,softskip,scale=$final_options[4]";
        }

        # if --subtitle-XXX switch selected...
        if (($subtitle ne "") and ($test ne "true") and ($pass == 1)) {
            $mencoder[4] =
              "-vobsubout $final_options[7] -vobsuboutindex 0 -sid $final_options[6]";
        }

        # the final generated command line for pass one...
        if (($pass == 1) and ($test eq "true")) {
            $cmd_one = "@mencoder -ss 9:30 -endpos 0:60";
        }
        elsif ($pass == 1) {
            $cmd_one = "@mencoder";
        }

        # the final generated command line for pass two...
        if (($pass == 2) and ($test eq "true")) {
            $cmd_two = "@mencoder -ss 9:30 -endpos 0:60";
        }
        elsif ($pass == 2) {
            $cmd_two = "@mencoder";
        }
    }

    # if --subtitle- switch selected...
    if ($subtitle ne "") {
        encode_status("extracting subtitles during first pass...");
    }

    encode_status("$codec codec family selected...");
    mencoder_command($cmd_one, $cmd_two, $chown);

}

# subroutine to run mencoder...
sub mencoder_command {

    # pre-declare argument variables...
    my $command_one = $_[0];
    my $command_two = $_[1];
    my $file_owner  = $_[2];

    # pass one...
    encode_status("running first pass of the encode...");
    open my $CMD, "$command_one 1>/dev/tty8 2>/dev/tty8 |"
      or die "unable to open command: $!";
    close($CMD);

    # pass two...
    encode_status("running second pass of the encode...");
    open my $CMD, "$command_two 1>/dev/tty8 2>/dev/tty8 |"
      or die "unable to open command: $!";
    close($CMD);

    # clean-up and end note...
    open my $CMD, "rm -f divx2pass.log /dev/null |"
      or die "unable to open command: $!";
    close($CMD);

    # if --chown- switch selected...
    if ($file_owner ne "") {
        open my $CMD, "chown $file_owner $file_name 1>/dev/tty8 2>/dev/tty8 |"
          or die "unable to open command: $!";
        close($CMD);
        encode_status("ownership of $file_output changed to $file_owner...");
    }

    encode_status("all finished!\n");
    exit;
}

# subroutine to generate log files...
sub encode_log {

    # pre-declare argument variables...
    my $dvd_title = $_[0];
    my $info_log  = $_[1];
    my $special   = $_[2];
    my ($a, $b);

    # create logfile name...
    ($a, $b) = split(/\.avi|\.mp4/, $dvd_title);
    my $log_name = "$a.log";

    # write the information to the log file...
    open my $OUTFILE, ">>", $log_name or die "unable to open $log_file\: $!";
    if ($special eq "first") {
        print $OUTFILE
          " ________________  _______________________________________ _ _   _ \n";
        print $OUTFILE
          "( mp4_encoder.pl )( $mp4_version created on $mp4_date encode log...\n\n";
    }
    print $OUTFILE "  $info_log\n";

    if ($special eq "last") {
        print $OUTFILE " _____  _____________________ _ _   _ \n";
        print $OUTFILE "( log )( log file concluded...\n";
    }
    close($OUTFILE);
}

# subroutine to handle encoding status...
sub encode_status {

    # pre-declare argument variables...
    my $message = $_[0];
    my $special = $_[1];

    # display a header if this is the first argument passed...
    if ($special eq "first") {
        system("clear");
        print
          " ________________  _______________________________________ _ _   _ \n";
        print
          "( mp4_encoder.pl )( $mp4_version created on $mp4_date preparing for encode...\n\n";

        print "    ________  _____________________ _ _   _ \n";
        print "   ( status )( dumping screen output to /dev/tty8...\n";
    }

    # display messages sent from encode process...
    print "    ________  _____________________ _ _   _ \n";
    print "   ( status )( $message\n";
}

# subroutine to handle print usage information...
sub print_usage {
    system("clear");
    print <<USAGE;
 ________________  _______________________________________ _ _   _ 
( mp4_encoder.pl )( $mp4_version created on $mp4_date usage information...
	
    --screen-      :: use either wide or full screen aspects ie. "--screen-wide"...
    --video-       :: choose from x264, ffmpeg or XviD ie. "--video-ffmpeg"...	
    --audio-xxx-   :: choose from faac, mp3 or ac3 ie. "--audio-faac-100"...
    --language-    :: which language track to use ie. "--language-128"...
    --subtitle-    :: which subtitle to extract ie. "--subtitle-0"...	
    --filesize-    :: final output file size ie. "--filesize-900"...
    --signature-   :: add a user sig to logfile ie. "--signature-user"...
    --chown-       :: change owner of file once encoded ie. "--chown-user"...		
    --test         :: only encode 60 seconds of video for testing...
    --logfile      :: creates a log file of all settings calculated...
    --autocrop     :: automatically determines crop settings...
    --help         :: this usage list...
 _________  _____________________________ _ _   _
( example )( a minimum mp4_encoder.pl command line... 

  "INPUT.vob output.avi --video-x264 --screen-wide 
   --filesize-900 --audio-ac3-192 --language-128"
	 	
USAGE

}

# set start point for script...
sort_arguments();

# end of file...


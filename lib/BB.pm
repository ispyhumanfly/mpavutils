# BB.pm (c) 2007-2008 nemesis, l.l.c.

use warnings;
use strict;

BEGIN {

    # croak unless this is a supported operating system...
    die "The operating system '$^O' is not supported!\n"
      unless $^O =~ /^[linux|darwin|mswin]/i;

    # the WE_LIKE_MOVIES environment variable must be set...
    die "WE_LIKE_MOVIES Environment error : $!"
      unless exists $ENV{WE_LIKE_MOVIES} and -d $ENV{WE_LIKE_MOVIES};
}

package BB;

use Cwd;

# class contsructor...
sub new {

    # preamble...
    my ($class, %params) = @_;
    my (@identify, $i);

    # store the current location...
    $params{'cwd'} = getcwd();

    # change to the bb home directory...
    chdir $ENV{WE_LIKE_MOVIES} or die "Unable to change directory: $!\n";

    # for Linux & Mac OSX...
    if ($^O =~ /^[linux|darwin]/i) {

        # check every directory located in the $PATH variable...
        my @path = split /\:/, $ENV{PATH};
        for my $directory (@path) {

            # as long as it both exists and is executable...
            if (    (-e "$directory/mplayer")
                and (-x "$directory/mplayer"))
            {

                # we've found it...
                $params{'mplayer'} = "$directory/mplayer";
            }

            # as long as it both exists and is executable...
            if (    (-e "$directory/mencoder")
                and (-x "$directory/mencoder"))
            {

                # we've found it...
                $params{'mencoder'} = "$directory/mencoder";
            }
        }

        # can't find mplayer...
        die "Unable to locate 'mplayer' in your system path!\n"
          unless exists $params{mplayer};

        # can't find mencoder...
        die "Unable to locate 'mencoder' in your system path!\n"
          unless exists $params{mencoder};
    }

    # for Windows XP & Vista...
    if ($^O =~ /^mswin/i) {

        # mplayer...
        $params{'mplayer'} = 'bin\mplayer.exe'
          if -e 'bin\mplayer.exe'
              or die "Unable to find mplayer.exe!\n";

        # mencoder...
        $params{'mencoder'} = 'bin\mencoder.exe'
          if -e 'bin\mencoder.exe'
              or die "Unable to find mencoder.exe!\n";
    }

    # if the input type is for an mplayer command line...
    if ($params{type} eq 'mplayer') {

        # mplayer command line...
        open my $cmd_line,
          "$params{mplayer} $params{input} -ao null -vo null -msglevel "
          . 'identify=6 -ss 100 -endpos 0:05 -vf cropdetect 2> tmp/bb_trash |'
          or die "Unable to open command: $!\n";

        while (my $line = <$cmd_line>) {
            $i++;

            # enable screen output if 'debug' is enabled...
            print $line if $params{debug} == 1;

       # assuming the line doesn't have these few strings we want to ignore...
            unless ($line
                =~ /ID_AUDIO_BITRATE=0|ID_AUDIO_RATE=0|ID_AUDIO_NCH=0|ID_VIDEO_ASPECT=0.0000/x
              )
            {
                chomp $line;
                push @identify, $line;
            }
        }
        close $cmd_line;
    }

    # if the input is for an existing mplayer output file...
    elsif ($params{type} eq 'file') {

        # read the source file...
        open my $fh_input, '<', $params{input}
          or die "Unable to open the input specified: $!\n";

        while (my $line = <$fh_input>) {
            $i++;

            # enable screen output if 'debug' is enabled...
            print $line if $params{debug} == 1;

            # these strings we want to ignore...
            unless ($line
                =~ /ID_AUDIO_BITRATE=0|ID_AUDIO_RATE=0|ID_AUDIO_NCH=0|ID_VIDEO_ASPECT=0.0000/x
              )
            {
                chomp $line;
                push @identify, $line;
            }
        }
        close $fh_input;
    }

    # append class extensions...
    use base 'BB::Info', 'BB::Math', 'BB::Codec';

    # working the OO magic =] ...
    $params{identify} = \@identify;
    return bless \%params, $class;

}

# method to terminate the bb instance...
sub do_killbb {

    # preamble...
    my ($self, %params) = @_;

    # change back to the original location...
    chdir $self->{cwd} or die "Unable to change directory: $!\n";

    # bye!
    return $self = ();

}

# end of super-class...
1;

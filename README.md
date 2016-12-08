# mpavutils
A collection of useful audio and video endcoding utilities. The purpose of this collection is to offer a wide range of utilities that could prove useful when used in conjunction with other software.

## Synopsis

Search for supported media files on your system.

    mpscan ~/Movies

Or...

    mpscan ~/Downloads ~/Movies mysong.mp3

Create a 3-pass high-quality ffmpeg movie.

    mpffmpeg dvd://1 -o file.avi -m "-af volume=10"

You could juse as easily do the same in x264.

    mpx264 dvd://1 -o file.avi -m "-af volume=10"

## Copyright
Copyright 2010 - 2017 Dan Stephenson (ispyhumanfly)

## License
MIT


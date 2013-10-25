#!/bin/sh
make
cp CuteSpotify click/
cp libspotify/lib/libspotify* click/lib/
click build click

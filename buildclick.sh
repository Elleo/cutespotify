#!/bin/sh
make
cp src/CuteSpotify click/
mkdir click/lib
cp libspotify/lib/libspotify* click/lib/
click build click

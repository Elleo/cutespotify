[![Join the chat at https://gitter.im/lukedirtwalker/cutespotify](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/lukedirtwalker/cutespotify?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
# Cute Spotify
## Note about versioning
Starting from 1.5.2-*: Release 0 is always the harbour version, Release > 0 is always non-harbour compliant version.
The harbour version is a limited version with all *.harbour.patch patches applied. This is due to API limitations in harbour.

## Build Requirements
### Prerequisites
You need some libraries to build CuteSpotify, also you need QtCreator if you want to open the .pro file.

sudo apt-get install libpulse-dev qtcreator

Also, you might need some of the Qt development package, e.g. qt5-qtsysteminfo-devel.

### libSpotify
You need to download libspotify 12 to be able to compile and create the rpm package.
Get it there: https://developer.spotify.com/technologies/libspotify/
(For the device you need the version for the eabi-armv6hf architecture)


Extract the content of the tarball inside 'libspotify' at the root of the project.

The resulting hierarchy should be:
* libspotify/
  * include/
    * libspotify/
      * api.h
  * lib/
    * libspotify.so
    * libspotify.so.9

### Spotify API Key
You also need your own libspotify API key to be able to compile and run the program
(see https://developer.spotify.com/technologies/libspotify/keys/)
Create a file spotify_key.h inside libQtSpotify and copy the provided key inside it
using the following format:

```C
#ifndef SPOTIFY_KEY_H
#define SPOTIFY_KEY_H

const uint8_t g_appkey[] = { 0x00, 0x00, ..., ... };
const size_t g_appkey_size = sizeof(g_appkey);

#endif // SPOTIFY_KEY_H
```

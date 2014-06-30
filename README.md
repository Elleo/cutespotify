# Cute Spotify 
## Build Requirements
### Prerequisites
You need some libraries to build CuteSpotify, also you need QtCreator if you want to open the .pro file.

sudo apt-get install libpulse-dev qtcreator

### libSpotify
You need to download libspotify 12 to be able to compile and create the .click package.
Get it there: https://developer.spotify.com/technologies/libspotify/

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

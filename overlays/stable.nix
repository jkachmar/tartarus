final: _prev: {
  plex-plexpass = final.plex.override { plexRaw = final.plexRaw-plexpass; };
  plexRaw-plexpass = final.callPackage ./plexpass { };
}

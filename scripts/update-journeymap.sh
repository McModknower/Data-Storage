#!/bin/bash
# This script helps the user update the map for Wynntils, using journeymap.
# Please install journeymap 5.7, found in the bin directory.
#
# Made by magicus (https://github.com/magicus)
#

base_dir="$(cd $(dirname "$0")/.. 2>/dev/null && pwd)"
WYNNCRAFT_WORLD_NAME=${WYNNCRAFT_WORLD_NAME:-Wynncraft}
WYNNDATA_DIR=${WYNNDATA_DIR:-$base_dir/worldmap}
COMMAND=$1

if [[ ! -e options.txt ]]; then
    echo "This does not seem to be a Minecraft directory"
    echo "Please cd to your Minecraft directory and try again"
    exit 1
fi
if [[ ! -d journeymap ]]; then
    echo "Cannot find journeymap directory"
    echo "Please verify that you are in the correct directory"
    exit 1
fi

if [[ $COMMAND = "get-from-journeymap" ]]; then
  mkdir -p $WYNNDATA_DIR/journeymap-data/DIM0/day
  echo "Changed files:"
  diff -q journeymap/data/mp/$WYNNCRAFT_WORLD_NAME/DIM0/day $WYNNDATA_DIR/journeymap-data/DIM0/day
  cp -f journeymap/data/mp/$WYNNCRAFT_WORLD_NAME/DIM0/day/* $WYNNDATA_DIR/journeymap-data/DIM0/day
  echo "Please go to $WYNNDATA_DIR and commit and push your changes"
elif [[ $COMMAND == "install-in-journeymap" ]]; then
  mkdir -p journeymap/data/mp/$WYNNCRAFT_WORLD_NAME/DIM0/day
  echo "Changed files:"
  diff -q $WYNNDATA_DIR/journeymap-data/DIM0/day journeymap/data/mp/$WYNNCRAFT_WORLD_NAME/DIM0/day
  cp -f $WYNNDATA_DIR/journeymap-data/DIM0/day/* journeymap/data/mp/$WYNNCRAFT_WORLD_NAME/DIM0/day
  echo "Your journeymap installation now has the latest map data"
elif [[ $COMMAND == "update-raw-map" ]]; then
  mkdir -p $WYNNDATA_DIR/rawmap
  TMPDIR=$(mktemp -dt wynntils-map.XXXXX)
  if [[ ! -e $TMPDIR ]]; then
    echo "Failed to create temporary directory"
    exit 1
  fi
  echo "Using java:"
  java -version

  #### Do main map
  OUTPUT_MAP=map-raw-main.png
  SOURCE_TILES="$(ls $WYNNDATA_DIR/journeymap-data/DIM0/day/[0-5],-[1-9].png $WYNNDATA_DIR/journeymap-data/DIM0/day/-[1-5],-[1-9].png $WYNNDATA_DIR/journeymap-data/DIM0/day/[0-5],-1[0-3].png $WYNNDATA_DIR/journeymap-data/DIM0/day/-[1-5],-1[0-3].png $WYNNDATA_DIR/journeymap-data/DIM0/day/0,0.png)"
  mkdir -p $TMPDIR/DIM0/day
  cp -a $SOURCE_TILES $TMPDIR/DIM0/day/
  # for syntax regarding journeymaptools-0.3.jar, see https://journeymap.info/JourneyMapTools
#  java -jar $WYNNDATA_DIR/bin/journeymaptools-0.3.jar MapSaver $TMPDIR $WYNNDATA_DIR/rawmap/$OUTPUT_MAP 512 512 -1 0 false day
  rm -rf $TMPDIR/DIM0/day

  #### Do side maps
  # Bonfire area
  OUTPUT_MAP=map-raw-bonfire.png
  SOURCE_TILES="$(ls $WYNNDATA_DIR/journeymap-data/DIM0/day/-[3-4],19.png)"
  mkdir -p $TMPDIR/DIM0/day
  cp -a $SOURCE_TILES $TMPDIR/DIM0/day/
  # for syntax regarding journeymaptools-0.3.jar, see https://journeymap.info/JourneyMapTools
  java -jar $WYNNDATA_DIR/bin/journeymaptools-0.3.jar MapSaver $TMPDIR $WYNNDATA_DIR/rawmap/$OUTPUT_MAP 512 512 -1 0 false day
  rm -rf $TMPDIR/DIM0/day

  rm -rf $TMPDIR
  echo "Rawmap updated. Please go to $WYNNDATA_DIR and commit and push your changes"
elif [[ $COMMAND == "install-wynntils-config" ]]; then
  if [[ ! -d journeymap/config/5.7 ]]; then
      echo "Cannot find journeymap 5.7 config directory"
      echo "Please verify that you are in the correct directory and that you have journeymap 5.7 installed"
      exit 1
  fi
  cp -a journeymap/config/5.7/journeymap.core.config journeymap/config/5.7/journeymap.core.config.orig
  cp -a journeymap/colorpalette.json journeymap/colorpalette.json.orig
  cp $WYNNDATA_DIR/config/journeymap.core.config journeymap/config/5.7/journeymap.core.config
  cp $WYNNDATA_DIR/config/colorpalette.json journeymap/colorpalette.json
  echo "Replaced journeymap.core.config and colorpalette.json (backups saved as .orig)"
elif [[ $COMMAND == "restore-orig-config" ]]; then
  if [[ ! -d journeymap/config/5.7 ]]; then
      echo "Cannot find journeymap 5.7 config directory"
      echo "Please verify that you are in the correct directory and that you have journeymap 5.7 installed"
      exit 1
  fi
  cp -a journeymap/config/5.7/journeymap.core.config.orig journeymap/config/5.7/journeymap.core.config
  cp -a journeymap/colorpalette.json.orig journeymap/colorpalette.json
  echo "Restored journeymap.core.config and colorpalette.json from backups"
else
  echo "Usage: $0 [get-from-journeymap|install-in-journeymap|update-raw-map|install-wynntils-config|restore-orig-config]"
fi

#!/bin/bash -e

# Creates 7z archive of configured OpenSong with all standard song databases (Chvaly, 400, ...) and slovak translations of Bible (Ekumenicky, Evanjelicky, Rohackov).

REPOS_DIR=../git

function copySongDatabase {
	local SOURCE_DIR_NAME="$1"
	local DESTINATION_DIR_NAME="$2"
	local DESTINATION="$OPENSONG_DIR/OpenSong Data/Songs/$DESTINATION_DIR_NAME"
	mkdir -p "$DESTINATION"
	cp "$REPOS_DIR/$SOURCE_DIR_NAME/"* "$DESTINATION"
}

function copyBible {
	local BIBLE_NAME="$1"
	local DESTINATION="$OPENSONG_DIR/OpenSong Scripture"
	mkdir -p "$DESTINATION/indexes"
	cp "$REPOS_DIR/opensong-bibles/$BIBLE_NAME" "$DESTINATION"
	cp "$REPOS_DIR/opensong-bibles/indexes/$BIBLE_NAME.ind" "$DESTINATION/indexes"
}

WORK_DIR=$(mktemp -d)

# Unpack OpenSong
7z x -o$WORK_DIR OpenSong-portable-configured-nocontent.7z
OPENSONG_DIR="$WORK_DIR/OpenSong-portable"

# Copy songs
copySongDatabase "bratske-piesne" "Bratske piesne"
copySongDatabase "chvaly" "Chvaly"
copySongDatabase "oranzovy-spevnicek" "Oranzovy Spevnicek"
copySongDatabase "spevnik-400" "400"
copySongDatabase "chvalte-pana-jezisa" "Chvalte Pana Jezisa"
copySongDatabase "detske-piesne" "Ine/Detske piesne"
copySongDatabase "matuzalem" "Ine/Matuzalem"

# Copy Bibles
copyBible "SK Ekumenický"
copyBible "SK Evanjelický"
copyBible "SK Roháčkov"

# Pack everything into 7Z archive
rm -f opensong.7z
7z a -l -mx=9 opensong.7z "$OPENSONG_DIR"

# Clean up
rm -r $WORK_DIR

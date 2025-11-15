#!/bin/bash -e

# Creates 7z archive of configured OpenSong with all standard hymn books (Chvaly, 400, ...) and slovak translations of Bible (Ekumenicky, Evanjelicky, Rohackov).

HYMN_BOOKS_DIR=../spevniky
BIBLES_DIR=../biblie/opensong-bibles

function copySongDatabase {
	local SOURCE_DIR_NAME="$1"
	local DESTINATION_DIR_NAME="$2"
	local DESTINATION="$OPENSONG_DIR/OpenSong Data/Songs/$DESTINATION_DIR_NAME"
	mkdir -p "$DESTINATION"
	cp "$HYMN_BOOKS_DIR/$SOURCE_DIR_NAME/"* "$DESTINATION"
}

function copyBible {
	local BIBLE_NAME="$1"
	local DESTINATION="$OPENSONG_DIR/OpenSong Scripture"
	mkdir -p "$DESTINATION/indexes"
	cp "$BIBLES_DIR/$BIBLE_NAME" "$DESTINATION"
	cp "$BIBLES_DIR/indexes/$BIBLE_NAME.ind" "$DESTINATION/indexes"
}

WORK_DIR=$(mktemp -d)

# Unpack OpenSong
7z x -o$WORK_DIR opensong-portable-configured-nocontent.7z
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
7z a -mx=9 opensong.7z "$OPENSONG_DIR"

# Clean up
rm -r $WORK_DIR

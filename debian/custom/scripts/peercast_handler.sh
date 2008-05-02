#!/bin/sh

# Peercast kmenu for peercast:// links
# By Romain Beauxis <toots@rastageeks.org>

# You can add your own services.
# Just have a look to those for xmms, you'll see how it works.
# Then add yours to the same directory, and add it to the list below.

SERVICES="Geekast Audacious-Enqueue Audacious-Play Totem VLC Other"
MENU_SERVICES="Geekast Open-with-Geekast Audacious-Enqueue Enqueue-in-audacious Audacious-Play Play-in-audacious Totem Play-with-Totem VLC Play-with-VLC Other Use-your-own-command"

# Set default options:
host="127.0.0.1:7144"

# Check for pref file:
if ! [ -f ~/.peercast_handlerrc ]; then
	echo "host=\"$host\"" >| ~/.peercast_handlerrc;
fi;

# Then source it
. ~/.peercast_handlerrc

#
# support different types of dialog
#

# Determine which dialog to use in which situation:
if [ "$DISPLAY" != "" ] ; then
	if [ -x "`which kdialog`" ] ; then
		binary=$(kdialog --title "Peercast Handler" --menu Service $MENU_SERVICES 2> /dev/null)
		if [ "$binary" = "" ]; then
			exit 1;
		elif [ "$binary" = "Other" ]; then
			binary=$(kdialog --title "Custom command" --inputbox "Enter your command, %u for url:" "my_command --play %u" 2> /dev/null)
			if [ "$binary" = "" ]; then
			exit 1;
			fi;
		fi;
		if [ "$binary" != "Geekast" ]; then
			host=$(kdialog --title "PeerCast server" --inputbox "What is the adress of you server?" "$host" 2> /dev/null)
			if [ "$host" = "" ]; then
			exit 1;
			fi;
		fi;
	elif [ -x "`which zenity`" ] ; then
		binary=$(zenity --list --title="Peercast Handler" --text=Service --column="Multimedia player" $SERVICES 2> /dev/null)
		if [ "$binary" = "" ]; then
		exit 1;
		elif [ "$binary" = "Other" ]; then
			binary=$(zenity --entry --title="Custom command" --text="Enter your command, %u for url:" --entry-text="my_command --play %u" 2> /dev/null)
			if [ "$binary" = "" ]; then
			exit 1;
			fi;
		fi;
		if [ "$binary" != "Geekast" ]; then
			host=$(zenity --entry --title="PeerCast server" --text="What is the adress of you server?" --entry-text="$host" 2> /dev/null)
			if [ "$host" = "" ]; then
			exit 1;
			fi;
		fi;
	elif [ -x "`which Xdialog`" ] ; then
		binary=$(Xdialog --stdout --menubox "Peercast Handler" 13 40 5 $MENU_SERVICES 2> /dev/null)
		if [ "$binary" = "" ]; then
		exit 1;
		elif [ "$binary" = "Other" ]; then
			binary=$(Xdialog --stdout --title "Custom command" --inputbox "Enter your command, %u for url:" 8 30 "my_command --play %u" 2> /dev/null)
			if [ "$binary" = "" ]; then
			exit 1;
			fi;
		fi;
		if [ "$binary" != "Geekast" ]; then
			host=$(Xdialog --stdout --title "PeerCast server" --inputbox "What is the adress of you server?" 8 30 "$host" 2> /dev/null)
			if [ "$host" = "" ]; then
			exit 1;
			fi;
		fi;
	fi;
elif [ -x "`which dialog`" ] && [ -e $(tty) ] ; then 
	# This intented for an execution within a concole.. Dunno if this will ever occur except for dbaelde ;) .. !
	binary=$(dialog --stdout --menu "Peercast Handler" 13 40 5 $MENU_SERVICES 2> /dev/null)
	if [ "$binary" = "" ]; then
		echo "Cancel!";
		exit 1;
	elif [ "$binary" = "Other" ]; then
		binary=$(dialog --stdout --title "Custom command" --inputbox "Enter your command, %u for url:" 8 30 "my_command --play %u" 2> /dev/null)
		if [ "$binary" = "" ]; then
		echo "Cancel!";
		exit 1;
		fi;
	fi;
	if [ "$binary" != "Geekast" ]; then
		host=$(dialog --stdout --title "PeerCast server" --inputbox "What is the adress of you server?" 8 30 "$host" 2> /dev/null)
		if [ "$host" = "" ]; then
			echo "Cancel!";
			exit 1;
		fi;
	fi;
else
	echo "Could not find a suitable dialog binary..."
fi;

# Choose command:
if [ "$binary" = "Audacious-Enqueue" ] ; then
	binary="audacious --enqueue %u"
elif [ "$binary" = "Audacious-Play" ] ; then
	binary="audacious --play %u"
elif [ "$binary" = "Totem" ] ; then
	binary="totem %u"
elif [ "$binary" = "VLC" ] ; then
	binary="vlc %u"
fi;

# Save prefs:

echo "host=\"$host\"" >| ~/.peercast_handlerrc;

# Launch the parser or Geekast..

if [ "$binary" = "Geekast" ] ; then
	geekast $binary
else
	peercast-parser.pl -h=$host -b="$binary" $1
fi;


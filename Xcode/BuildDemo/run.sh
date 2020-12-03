#!/bin/bash

osascript -e ' display dialog "Hello World"' 
osascript -e 'display notification "Lorem ipsum dolor sit amet" with title "Title"'
osascript -e 'display alert "Alert title" message "Your message text line here." as critical'

buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_FILE")
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$INFOPLIST_FILE"
echo "External Build Tool" 
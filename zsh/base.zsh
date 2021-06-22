stty -ixon

. $HOME/.asdf/asdf.sh

export EDITOR='vim'
export APPS_HOME=/home/imtiaz/apps
export ANDROID_HOME=/home/imtiaz/Android
export ANDROID_SDK_ROOT=/home/imtiaz/Android
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

export PATH="$PATH:$JAVA_HOME/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$APPS_HOME"

TIMEFMT='%J   %U  user %S system %P cpu %*E total'$'\n'\
'avg shared (code):         %X KB'$'\n'\
'avg unshared (data/stack): %D KB'$'\n'\
'total (sum):               %K KB'$'\n'\
'max memory:                %M MB'$'\n'\
'page faults from disk:     %F'$'\n'\
'other page faults:         %R'

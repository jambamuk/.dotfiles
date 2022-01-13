stty -ixon

. $HOME/.asdf/asdf.sh

export EDITOR='nvim'
export JAVA_HOME=/home/chappie/.asdf/installs/java/adoptopenjdk-8.0.292+10/bin/java

TIMEFMT='%J   %U  user %S system %P cpu %*E total'$'\n'\
'avg shared (code):         %X KB'$'\n'\
'avg unshared (data/stack): %D KB'$'\n'\
'total (sum):               %K KB'$'\n'\
'max memory:                %M MB'$'\n'\
'page faults from disk:     %F'$'\n'\
'other page faults:         %R'

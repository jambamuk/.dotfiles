alias cl='clear'
alias q='exit'
alias mux='tmuxinator'
alias v='nvim .'

alias sz='source ~/.zshrc'
alias python='python3'
alias python2='python2.7'

#cd aliases
alias cdus='cd ~/Library/Application\ Support/Übersicht/widgets/'

#deploy aliases
#Build intouch
alias bi='mvn -s C:/maven.repo2/settings.xml -Dmaven.test.skip clean install'
#Deploy to wildfly server 
alias di='cp /home/chappie/intouch/modules/intouch/target/InTouchWeb-1.0-SNAPSHOT.war /mnt/c/PPS-project/Mutual/wildfly10.1_mutual/standalone/deployments/InTouchWeb-1.0-SNAPSHOT.war'
#Run wildfly server 
alias ri='./mnt/c/PPS-project/Mutual/wildfly11.1_mutual/bin/standalone.sh'

# prevents .wget-hsts from being created in $HOME
wget="wget --hsts-file=${XDG_STATE_HOME}/wget-hsts"

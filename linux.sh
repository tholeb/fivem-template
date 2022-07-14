#!/bin/bash
# CONTENT  : Simple server manager script
# AUTHOR   : tholeb
# CREATION : 25/06/2021
# SOURCE   : https://gist.github.com/tholeb/c3f98e8a9fb3845367d15db31a89650c
# @param   : type - The type of action you want to do (start, restart, stop, status, screen)

# Colors
asciiWhite="\033[0;39m"
asciiGray="\033[0;37m"
asciiRed="\033[1;31m"
asciiGreen="\033[1;32m"
asciiOrange="\033[1;33m"
asciiBlue="\033[1;34m"
asciiPurple="\033[1;35m"
asciiCyan="\033[1;36m"

# Path
FXServer=/home/fivem/FXServer/server
FXServerData=/home/fivem/FXServer/server-data
FXServerLogs=/home/fivem/FXServer/logs

# Screen
screenName="fxserver"
stopMessage="Le serveur s'arretera dans 30 secondes!"
restartMessage="Le serveur redémarrera dans 30 secondes!"

cd $fxserver

# CONTENT  : Tell weather the server is running or not
isRunning(){
    if ! screen -list | grep -q "$screenName"
    then 
        return 1
    else
        return 0
    fi
}

# CONTENT  : Start the server
startServer(){
    if ( isRunning )
    then
        echo -e "$asciiOrange[WARN] Screen : $asciiCyan{$screenName}$asciiWhite is $asciiCyan{RUNNING}$asciiWhite"
        echo -e "$asciiOrange[WARN] Nothing was done $asciiWhite"
    else
        echo -e "$asciiGreen[INFO] $asciiWhite Date : $asciiCyan"`date '+%d %B %Y %H:%M:%S'`"$asciiWhite - Launching server..."
        sleep 2
        cd $FXServerData
        screen -S "$screenName" -dm -L -Logfile /home/fivem/FXServer/logs/`date '+%Y-%m-%d_%H:%M:%S'`.log bash $FXServer/run.sh +exec server.cfg
        echo -e "$asciiOrange[WARN] Screen : $asciiCyan{$screenName}$asciiWhite is $asciiCyan{RUNNING}$asciiWhite"
        screen -list
    fi
}

# CONTENT  : Stop the server
# @Param   : 
stopServer(){
    if [ "$1" = "restart" ]
    then
        message=$restartMessage
    else
        message=$stopMessage
    fi
    
    if ( isRunning )
    then
        echo -e "$asciiGreen[INFO] $asciiWhite Date : $asciiCyan"`date '+%d %B %Y %H:%M:%S'`"$asciiWhite - Stoppping server..."
        echo -e "$asciiOrange[WARN] Stopping the server: $asciiCyan{$screenName}$asciiWhite will$asciiRed SHUTDOWN IN 30 SECONDS$asciiWhite"
        screen -S $screenName -p 0 -X stuff "say $message^M"; sleep 30
        screen -S $screenName -X quit
        echo -e "$asciiOrange[WARN] Server stopped : $asciiCyan{$screenName}$asciiWhite is $asciiRed{STOPPED}$asciiWhite"
    else
        echo -e "$asciiOrange[WARN] Screen : $asciiCyan{$screenName}$asciiWhite is $asciiRed{STOPPED}$asciiWhite"
        if [ "$1" != "restart" ]
        then
            echo -e "$asciiOrange[WARN] Nothing was done $asciiWhite"
        fi
    fi
}

case "$1" in
    # -----------------[ Start ]---------------- #
    start)
        startServer
    ;;

    # -----------------[ Restart ]---------------- #
    restart)
        stopServer "restart"
        startServer
    ;;

    # -----------------[ Stop ]---------------- #
    stop)
        stopServer "stop"
    ;;

    # -----------------[ Status ]---------------- #
    status)
        if ( isRunning )
        then
            echo -e "$asciiOrange[WARN] Screen : $asciiCyan{$screenName}$asciiWhite is $asciiCyan{RUNNING}$asciiWhite"
            echo -e "$asciiGreen[INFO] Logs : tail -f $asciiCyan$FXServerLogs/file$asciiWhite"
        else
            echo -e "$asciiOrange[WARN] Screen : $asciiCyan{$screenName}$asciiWhite is $asciiRed{STOPPED}$asciiWhite"
        fi
    ;;

    # -----------------[ Screen ]---------------- #
    screen)
        echo -e "$asciiGreen[INFO] Screen : $asciiWhite $asciiCyan{$screenName} $asciiWhite"
        echo -e "$asciiOrange[WARN] keybinds: $asciiWhite To detach the screen $asciiCyan(keep it running in the background)$asciiWhite do$asciiRed {CTRL+A,CTRL+D}$asciiWhite"
        echo -e "$asciiGreen[INFO] Screen : $asciiCyan{$screenName}$asciiWhite will launch in $asciiCyan{20 seconds} $asciiWhite"
        sleep 20
        screen -R $screenName
    ;;

    # -----------------[ Else ]---------------- #
    *)
        echo -e "$asciiOrange[WARN] Usage : $asciiGray./`basename "$0"` $asciiCyan{start|restart|stop|status|screen}$asciiWhite"
    ;;
esac
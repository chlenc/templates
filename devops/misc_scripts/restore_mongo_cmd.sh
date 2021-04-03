#!/usr/bin/env bash

help () {
    echo 'There are 3 available options:'
    echo
    echo '-f (required) -- path to file'
    echo '-h (required) -- connection uri'
    echo '-o            -- additional options for mongorestore command; wrap in double quotas all the options'
}

if [ $1 == '--help' ]
 then
    help
    exit
fi

declare -a file_check
file_check=0
uri_check=0

while getopts :h:p:f:o: option
  do
    case "${option}"
        in
        h)
            URI=${OPTARG}
            uri_check=1
            ;;
        p) PORT=${OPTARG};;
        o) OPTIONS=${OPTARG};;
        f)
            FILEPATH=${OPTARG}
            file_check=1
            ;;
        :)
            echo "Option $option have to be set"
            help
            exit
            ;;
        esac
done

if [[ $file_check == 0 || $uri_check == 0 ]]
then
    echo "-f and -h options must be set"
    help
    exit
fi

OPTIONS=${OPTIONS:-""}

echo $FILEPATH

echo $URI

if [ -f $FILEPATH ]
    then
        read -p "The database will be DROPPED. Proceed? [Y/n]" DROPDB
        if [[ $DROPDB == "n" ]]
            then
                exit
        fi

        cat $FILEPATH | docker run --rm -i mongo mongorestore --uri $URI --archive --gzip --drop $OPTIONS
    else
        echo "Such file doesn't exists!"
fi

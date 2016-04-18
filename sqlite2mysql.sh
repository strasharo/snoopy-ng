#!/bin/bash

set -e;

# Set the following variables to configure the MySQL connection correctly
ADDR=<IP Address of host>
PORT=<MySQL port>
USER=<Login Username>
PASS=<Login Password>
BASE=<Database Schema>

for f in "$@"; do
    if [ $(basename "$(dirname "$f")") = "Done" ]; then
        LOC="$(basename "$(dirname "$(dirname "$(dirname $f)")")")";
    else
        LOC="$(basename "$(dirname "$(dirname $f)")")";
    fi

    fname="$(basename "$f")"
    CSV_DIR="/home/samuelwn/Documents/Hood/Spring 2016/Senior Project/SnoopyDBs/CSV"

    mkdir -p "${CSV_DIR}/${LOC}"

    SES="$(dirname "$f")/${fname%.*}_sessions.sql"
    AP_OBS="$(dirname "$f")/${fname%.*}_wifi_AP_obs.sql"
    AP_SSIDS="$(dirname "$f")/${fname%.*}_wifi_AP_ssids.sql"
    CLIENT_OBS="$(dirname "$f")/${fname%.*}_wifi_client_obs.sql"
    CLIENT_SSIDS="$(dirname "$f")/${fname%.*}_wifi_client_ssids.sql"


    echo -e "REPLACE INTO sessions VALUES\n" > "$SES"
    sqlite3 -header -csv "$f" "select * from sessions;" | sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba' | \
    tail -n +2 | sed -e "s/\"//g" | sed -e "s/,/','/g" | sed "s/','/,\"/1" | sed "s/','/\",\"/1" | \
    sed "s/',/\",/1" | sed "s/','/',/4" | sed "s/,'wifi',/,\"wifi\",/" | awk '{print "("$0"),"}' | sed -e '$s/,$/;/' \
    >> "$SES"

    echo -e "REPLACE INTO wifi_AP_obs VALUES\n" > "$AP_OBS"
    sqlite3 -header -csv "$f" "select * from wifi_AP_obs;" | sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba' | \
    tail -n +2 | sed -e "s/\"/'/g" | sed 's/,/",/1' | sed "s/.*/(\"&),/" | sed -e '$s/,$/;/' \
    >> "$AP_OBS";

    echo -e "REPLACE INTO wifi_AP_ssids VALUES\n" > "$AP_SSIDS"
    sqlite3 -header -csv "$f" "select * from wifi_AP_ssids;" | sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba' | \
    tail -n +2 | sed -e 's/"//g' | sed 's/,/","/1' |  sed 's/,0,/",0,/1' | sed "s/.*/(\"&),/" | sed -e '$s/,$/;/' | sed -e 's/""/"/g' \
    >> "$AP_SSIDS"

    echo -e "REPLACE INTO wifi_client_obs VALUES\n" > "$CLIENT_OBS"
    sqlite3 -header -csv "$f" "select * from wifi_client_obs;" | sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba' | \
    tail -n +2 | sed -e "s/\"/'/g" | sed 's/,/",/1' | sed "s/.*/(\"&),/" | sed -e '$s/,$/;/' \
    >> "$CLIENT_OBS"

    echo -e "REPLACE INTO wifi_client_ssids VALUES\n" > "$CLIENT_SSIDS"
    sqlite3 -header -csv "$f" "select * from wifi_client_ssids;" | sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba' | \
    tail -n +2 | sed -e 's/"//g' | sed 's/,/","/1' |  sed 's/,0,/",0,/1' | sed "s/.*/(\"&),/" | sed -e '$s/,$/;/' | sed -e 's/""/"/g' \
    >> "$CLIENT_SSIDS"
done;

mysql --host=$ADDR --port=$PORT --user=$USER --password=$PASS -D $BASE < "$SES";
mysql --host=$ADDR --port=$PORT --user=$USER --password=$PASS -D $BASE < "$AP_OBS";
mysql --host=$ADDR --port=$PORT --user=$USER --password=$PASS -D $BASE < "$AP_SSIDS";
mysql --host=$ADDR --port=$PORT --user=$USER --password=$PASS -D $BASE < "$CLIENT_OBS";
mysql --host=$ADDR --port=$PORT --user=$USER --password=$PASS -D $BASE < "$CLIENT_SSIDS";

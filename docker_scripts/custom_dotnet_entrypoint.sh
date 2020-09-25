#!/bin/bash
set -e

# extracting connection params from connection string
str=`echo "$CUSTOMCONNSTR_SSOConnection" | tr ", = ;" "\t"`
server=`echo "$str" | cut -f2`
port=`echo "$str" | cut -f4`
database=`echo "$str" | cut -f6`
user=`echo "$str" | cut -f8`
password=`echo "$str" | cut -f10`

check_db_exist (){
    set +e
    mysql --host="$server" --port="$port" -u $user --password="$password" -e "SHOW DATABASES LIKE '$database'" | grep "$database" > /dev/null
    success=$?
    set -e
}

timeouts=(5 10 15 25 45 60 60 60)
i=1

check_db_exist
# calls check function until db is ready or timeout occurs
while [ "$success" -ne 0 ] && [ "$i" -le "${#timeouts[@]}" ]; do
    t="${timeouts[$i]}"
    echo "#$i Waiting ${t}s for DB initialization"
    sleep $t

    echo "#$i Executing checking query"
    check_db_exist

    i=$((i+1))
done

if [ "$success" -ne 0 ]; then
    echo "DB initialization timeout"
    exit 1
fi

echo "DB initialized. Starting dotnet app..."
exec dotnet "$1"
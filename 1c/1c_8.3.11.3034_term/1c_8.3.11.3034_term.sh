
#!/bin/bash
#06.08.2019

USERNAME=
PASSWORD=

NEW_VER='8.3.11.3034'

if [[ -z "$USERNAME" ]];then
   echo "USERNAME not set"
   exit 1
fi

if [[ -z "$PASSWORD" ]];then
   echo "PASSWORD not set"
   exit 1
fi

echo "Getting versions, please wait."

SRC=$(curl -c /tmp/cookies.txt -s -L https://releases.1c.ru)

ACTION=$(echo "$SRC" | grep -oP '(?<=form method="post" id="loginForm" action=")[^"]+(?=")')
EXECUTION=$(echo "$SRC" | grep -oP '(?<=input type="hidden" name="execution" value=")[^"]+(?=")')

curl -s -L \
   -o /dev/null \
   -b /tmp/cookies.txt \
   -c /tmp/cookies.txt \
   --data-urlencode "inviteCode=" \
   --data-urlencode "execution=$EXECUTION" \
   --data-urlencode "_eventId=submit" \
   --data-urlencode "username=$USERNAME" \
   --data-urlencode "password=$PASSWORD" \
   https://login.1c.ru"$ACTION"

if ! grep -q "TGC" /tmp/cookies.txt ;then
   echo "Auth failed"
   exit 1
fi

clear

curl -s -b /tmp/cookies.txt https://releases.1c.ru/project/Platform83 |

   grep 'a href="/version_files?nick=Platform83' |
   tr -s '="  ' ' ' |
   awk -F ' ' '{print $5}' |
   sort -V | pr -a -T -5 #|tail -5
read -i "8.3." -p "Input version for download: " -e VER

if [[ -z "$VER" ]];then
   echo "VERSION not set"
   exit 1
fi

if [[ "8.3." = "$VER" ]];then
   echo "Need full VERSION number"
   exit 1
fi

VER1=${VER//./_}

# if $VER >= $NEW_VER

if [[ $(echo -e $NEW_VER\\n$VER |sort -V|head -1) = $NEW_VER ]]; then

# new verision filename

 CLIENTLINK=$(curl -s -G \
   -b /tmp/cookies.txt \
   --data-urlencode "nick=Platform83" \
   --data-urlencode "ver=$VER" \
   --data-urlencode "path=Platform\\$VER1\\client_$VER1.deb64.tar.gz" \
   https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')

 SERVERLINK=$(curl -s -G \
   -b /tmp/cookies.txt \
   --data-urlencode "nick=Platform83" \
   --data-urlencode "ver=$VER" \
   --data-urlencode "path=Platform\\$VER1\\deb64_$VER1.tar.gz" \
   https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
else

 # Old version filename

 CLIENTLINK=$(curl -s -G \
   -b /tmp/cookies.txt \
   --data-urlencode "nick=Platform83" \
   --data-urlencode "ver=$VER" \
   --data-urlencode "path=Platform\\${VER1}\\client.deb64.tar.gz" \
   https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')

 SERVERLINK=$(curl -s -G \
   -b /tmp/cookies.txt \
   --data-urlencode "nick=Platform83" \
   --data-urlencode "ver=$VER" \
   --data-urlencode "path=Platform\\${VER1}\\deb64.tar.gz" \
   https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
fi

mkdir -p dist

curl --fail -b /tmp/cookies.txt -o dist/${VER}_client64.tar.gz -L "$CLIENTLINK"
curl --fail -b /tmp/cookies.txt -o dist/${VER}_server64.tar.gz -L "$SERVERLINK"

rm /tmp/cookies.txt



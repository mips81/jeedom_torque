#!/bin/bash
echo "Début d'installation des dépendances, reverse proxy"
cd $1

escaped="$3"

# escape all backslashes first
escaped="${escaped//\\/\\\\}"

# escape slashes
escaped="${escaped//\//\\/}"

# escape asterisks
escaped="${escaped//\*/\\*}"

# escape full stops
escaped="${escaped//./\\.}"

# escape [ and ]
escaped="${escaped//\[/\\[}"
escaped="${escaped//\[/\\]}"

# escape ^ and $
escaped="${escaped//^/\\^}"
escaped="${escaped//\$/\\\$}"

# remove newlines
escaped="${escaped//[$'\n']/}"


FILE="/etc/nginx/sites-available/jeedom_dynamic_rule"
if [ -f "$FILE" ]; then
  echo "Fichier dynamique existant, la règle du reverse proxy doit être dans ce fichier"
  grep "${2}" $FILE
  if [ $? -eq 0 ]
  then
    echo "Règle déjà présente, aucune action"
  else
    echo "Ajout de la règle"
    #sudo sed -i '$ d' /etc/nginx/sites-available/jeedom_dynamic_rule
    sudo cat ${2}.conf >> /etc/nginx/sites-available/jeedom_dynamic_rule
    #sudo echo "{" >> /etc/nginx/sites-available/jeedom_dynamic_rule
    sudo service nginx restart
  fi
else
  echo "Nouveau format de conf Nginx, répertoire include"
  DIRECTORY="/etc/nginx/sites-available/jeedom.d"
  if [ ! -d "$DIRECTORY" ]; then
    sudo mkdir $DIRECTORY
  fi
  FILE="${DIRECTORY}/${2}.conf"
  if [ -f "$FILE" ]
  then
    echo "Fichier déjà présent, aucune action"
  else
    echo "Ajout du fichier"
    sudo cp ${2}.conf $DIRECTORY
    sudo sed -i -e 's/###URL###/'${escaped}'/g' ${DIRECTORY}/${2}.conf
    sudo service nginx restart
  fi
fi

echo "Fin d'installation des dépendances, reverse proxy"

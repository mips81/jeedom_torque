#!/bin/bash
echo "Début d'installation des dépendances, reverse proxy"
cd $1

escaped="$4"

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

if [ $3 == "apache" ]; then
  grep "/etc/apache2/jeedom.conf/" "/etc/apache2/sites-enabled/000-default.conf"
  if [ $? -eq 0 ]
  then
    echo "Attention, votre fichier de configuration Apache ne permet pas l'ajout de configuration"
  fi
  if [ -f "/etc/apache2/jeedom.conf/${2}.conf" ]; then
    echo "Fichier dynamique existant, la règle du reverse proxy doit être dans ce fichier"
  else
    DIRECTORY="/etc/apache2/jeedom.conf/"
    if [ ! -d "$DIRECTORY" ]; then
      sudo mkdir $DIRECTORY
    fi
    echo "Ajout du fichier de conf Apache"
    sudo cp apache.conf /etc/apache2/jeedom.conf/${2}.conf
    sudo sed -i -e 's/###URL###/'${escaped}'/g' /etc/apache2/jeedom.conf/${2}.conf
  fi
  sudo service apache2 reload
else
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
      sudo sed -i -e 's/###URL###/'${escaped}'/g' /etc/nginx/sites-available/jeedom_dynamic_rule
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
fi

echo "Fin d'installation des dépendances, reverse proxy"

#!/bin/bash
echo "Début d'installation des dépendances, reverse proxy"
cd $1

escaped="$4"

# escape all backslashes first
#escaped="${escaped//\\/\\\\}"

# escape slashes
#escaped="${escaped//\//\\/}"

# escape asterisks
#escaped="${escaped//\*/\\*}"

# escape full stops
#escaped="${escaped//./\\.}"

# escape [ and ]
#escaped="${escaped//\[/\\[}"
#escaped="${escaped//\[/\\]}"

# escape ^ and $
#escaped="${escaped//^/\\^}"
#escaped="${escaped//\$/\\\$}"

# escape &
escaped="${escaped//\&/\\&}"

# remove newlines
#escaped="${escaped//[$'\n']/}"

if [ $3 == "apache" ]; then
  #grep "/etc/apache2/jeedom.conf/" "/etc/apache2/sites-enabled/000-default.conf"
  grep "/etc/apache2/conf-available/" "/etc/apache2/sites-enabled/000-default.conf"
  if [ $? -eq 0 ]
  then
    echo "Attention, votre fichier de configuration Apache ne permet pas l'ajout de configuration"
  fi
  if [ -f "/etc/apache2/conf-available/${2}.jeedom.conf" ]; then
    echo "Fichier dynamique existant, la règle du reverse proxy doit être dans ce fichier"
  else
    DIRECTORY="/etc/apache2/conf-available/"
    if [ ! -d "$DIRECTORY" ]; then
      sudo mkdir $DIRECTORY
    fi
    echo "Ajout du fichier de conf Apache"
    sudo cp apache.conf /etc/apache2/conf-available/${2}.jeedom.conf
    sudo sed -i -e "s%###URL###%$escaped%g" /etc/apache2/conf-available/${2}.jeedom.conf
  fi
  sudo a2enconf ${2}
  if [ $? -eq 0 ]
  then  
    echo "Activation dans la configuration ajouté"
  else
    echo "Erreur d'activation de la configuration ajouté"
    exit $?
  fi
  sudo a2enmod rewrite
  if [ $? -eq 0 ]
  then  
    echo "Activation du moteur de de réécriture"
  else
    echo "Erreur d'activation du moteur de de réécriture"
    exit $?
  fi
  echo "Vérification de la configuration ajouté"
  sudo apachectl configtest
    if [ $? -eq 0 ]
    then  
      echo "Recharger de la configuration d' $3"
      sudo apachectl graceful
    else
      echo "Erreur dans la configuration ajouté"
      exit $?
    fi
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
      sudo sed -i -e "s%###URL###%${escaped}%g" ${DIRECTORY}/${2}.conf
      sudo service nginx restart
    fi
  fi
fi

echo "Fin d'installation des dépendances, reverse proxy"

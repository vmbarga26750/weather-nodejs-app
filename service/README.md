# Creation du service systemd pour l'application chrisley weather

cd /lib/systemd/system/
vim chrisley_weather.service // ajouter le contenu du script present à la racine de ce readme
systemctl daemon-reload
systemctl status chrisley_weather
systemctl start chrisley_weather
systemctl stop chrisley_weather

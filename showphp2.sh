# aus den aktiven prozessen die umgebungsvariablen auslesen 
# und daraus die php datei bestimmen
for pid in `ps -u www-data | awk '{print $1}' | grep -v PID`; 
do 
  cat /proc/$pid/environ | grep "SCRIPT_FILENAME"; 
  echo; 
done

#!/bin/bash

# Copyleft by Bernd Moessinger (bernd@welcome2inter.net)

##Als Shellscript speichern

declare firewallscript=/sbin/firewall.sh;

if [ ! -r $firewallscript ]; then
 touch $firewallscript;
 chmod u+rwx $firewallscript;
 chmod og-rwx $firewallscript;
 ln -s $firewallscript /etc/rc2.d/S99firewall;
 ln -s $firewallscript /etc/init.d/rc2.d/S99firewall;
fi

clear;
printf "Firewalladministration\n";

until test "$option" = "q"; do

 printf "\n";
 read -p "IP (s)perren, (e)ntsperren, auf(l)isten und beenden (q): " option

 if test "$option" = "l"; then
   printf "\n";
   cat $firewallscript | awk '/ / {print $5}';
 fi 

 if test "$option" = "s"; then
  printf "\n";
  read -p "Zu sperrende IP (bsp: 192.168.1.25 oder 80.51.240.0/24): " ip
  if test "$ip" != ""; then
   echo "iptables -I INPUT -s $ip -j DROP" >> $firewallscript;
   iptables -I INPUT -s $ip -j DROP;
  fi
 fi

 if test "$option" = "e"; then
  printf "\n";
  read -p "Zu entsperrende IP (bsp: 192.168.1.25): " ip
  if test "$ip" != ""; then
   cat $firewallscript | sed /$ip/d > $firewallscript"_tmp"; 
   cat $firewallscript"_tmp" > $firewallscript;
   rm -rf $firewallscript"_tmp"; 
   iptables -D INPUT -s $ip -j DROP;
  fi
 fi

done

printf "\n";


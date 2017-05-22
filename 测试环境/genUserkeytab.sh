ipa_server=$(cat /etc/ipa/default.conf | awk '/^server =/ {print $3}')
#mkdir /etc/security/keytabs/
chown root:hadoop /etc/security/keytabs/
awk -F"," '$4=="USER" {print "ipa-getkeytab -s '${ipa_server}' -p "$3" -k "$6";chown "$7":"$9,$6";chmod "$11,$6}' kerberos.csv | sort -u > gen_user_keytabs.sh
#bash ./gen_user_keytabs.sh

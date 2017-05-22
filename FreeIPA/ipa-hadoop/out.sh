ipa-getkeytab -s ipamaster.csdn.net -p yarn/node01.csdn.net@CSDN.NET -k yarn.service.keytab
chown yarn:hadoop yarn.service.keytab;chmod 400 yarn.service.keytab
scp -p yarn.service.keytab root@node01.csdn.net:/etc/security/keytabs/
rm -rf yarn.service.keytab
ipa-getkeytab -s ipamaster.csdn.net -p yarn/node02.csdn.net@CSDN.NET -k yarn.service.keytab
chown yarn:hadoop yarn.service.keytab;chmod 400 yarn.service.keytab
scp -p yarn.service.keytab root@node02.csdn.net:/etc/security/keytabs/
rm -rf yarn.service.keytab
ipa-getkeytab -s ipamaster.csdn.net -p yarn/node03.csdn.net@CSDN.NET -k yarn.service.keytab
chown yarn:hadoop yarn.service.keytab;chmod 400 yarn.service.keytab
scp -p yarn.service.keytab root@node03.csdn.net:/etc/security/keytabs/
rm -rf yarn.service.keytab
ipa-getkeytab -s ipamaster.csdn.net -p yarn/node04.csdn.net@CSDN.NET -k yarn.service.keytab
chown yarn:hadoop yarn.service.keytab;chmod 400 yarn.service.keytab
scp -p yarn.service.keytab root@node04.csdn.net:/etc/security/keytabs/
rm -rf yarn.service.keytab
ipa-getkeytab -s ipamaster.csdn.net -p yarn/node05.csdn.net@CSDN.NET -k yarn.service.keytab
chown yarn:hadoop yarn.service.keytab;chmod 400 yarn.service.keytab
scp -p yarn.service.keytab root@node05.csdn.net:/etc/security/keytabs/
rm -rf yarn.service.keytab
ipa-getkeytab -s ipamaster.csdn.net -p yarn/node06.csdn.net@CSDN.NET -k yarn.service.keytab
chown yarn:hadoop yarn.service.keytab;chmod 400 yarn.service.keytab
scp -p yarn.service.keytab root@node06.csdn.net:/etc/security/keytabs/
rm -rf yarn.service.keytab
ipa-getkeytab -s ipamaster.csdn.net -p yarn/node07.csdn.net@CSDN.NET -k yarn.service.keytab
chown yarn:hadoop yarn.service.keytab;chmod 400 yarn.service.keytab
scp -p yarn.service.keytab root@node07.csdn.net:/etc/security/keytabs/
rm -rf yarn.service.keytab

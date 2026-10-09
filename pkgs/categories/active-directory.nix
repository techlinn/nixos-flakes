{ pkgs, ... }:
with pkgs;
[
  netexec
  bloodhound-ce
  certipy
  coercer
  donpapi
  enum4linux-ng
  evil-winrm
  kerbrute
  samba
  freerdp
  responder
  (mitm6.override { python3 = python312; })
  krb5

  python3Packages.impacket
  python3Packages.pypykatz
  python3Packages.lsassy

  smbmap
  openldap
  python3Packages.ldapdomaindump
  python3Packages.pywerview
  python3Packages.ldap3
  python3Packages.minikerberos
  python3Packages.bloodyad
  python3Packages.kerbad
]

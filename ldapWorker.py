# To install, use 'apt-get install python-ldap'
import ldap

# Initialize variables.
# Note that the password should be replaced with the real password.
ldapServer = "10.50.1.10"
user = "dude@berrysecure.net"
passwd = "###PASS###"


def ldapAuthen(ldapServer, user, passwd):
    try:
        # Connect to the ldap server via port 389
        l = ldap.open(host=ldapServer, port=389);
        
        # Set some options to allow it to authenticate.
        l.protocol_version = 3
        l.set_option(ldap.OPT_REFERRALS, 0)

        # Authenticate to the AD.
        l.simple_bind_s(user, passwd)
        print ("LDAP object bound")

	res = l.search_s("CN=Users,DC=ctf,DC=org", ldap.SCOPE_SUBTREE, "(objectClass=User)")
	# Print all users.
	for dn, entry in res:
	    print dn

        # Exit after authentication
        l.unbind_s()
        print ("Unbound")

        # Return an array indicating successful authentication.
        return([1, ""])

    # If an exception is created, print a descriptive message and return an array indicating failure.
    except ldap.LDAPError, e:
        print "Exception created: " + e[0]["desc"]
        return([0, e[0]["desc"]])

ldapAuthen(ldapServer, user, passwd)
        

This is a wrapper for auth0's LDAP connector.

Current state
============
It checksums and verifies packages checksum match a known-good point in time checksum,
packages everything into a single RPM and has systemd init support.

Ideally
=======
The upstream package would need modifications to properly install without prompting the user on first install.
Additionally, all npm packages should be separate RPMs.

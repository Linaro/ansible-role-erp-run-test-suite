ERP Run Test Suite
==================

Run the Enteprise Reference Platform (ERP) test suite against a given host.

Role Variables
--------------

| variable | description | default
|----------|-------------|---------
| erp_build_number | ERP build number | No default - required
| erp_squad_environment | [production|staging] | production
| erp_squad_auth_token | Squad API auth token | No default - required


Dependencies
------------

If ansible-role-erp-get-build is run first, then erp_build_number will be set.
Otherwise, it must be set to the erp build number that is installed on the
host.

Example Playbook
----------------

    - hosts: all
      vars:
        erp_build_number: 454 # ERP build installed on host
      roles:
        - role: Linaro.erp-run-test-suite

License
-------

BSD

Author Information
------------------

Dan Rue <dan.rue@linaro.org>

ERP Run Test Suite
==================

Run the Enteprise Reference Platform (ERP) test suite against a given host.

Role Variables
--------------

| variable | description | default
|----------|-------------|---------
| erp_latest_build | ERP build number | No default - required
| erp_squad_environment | [production|staging] | production
| erp_squad_auth_token | Squad API auth token | No default - required


Dependencies
------------

If ansible-role-erp-get-build is run first, then erp_latest_build will be set.
Otherwise, it must be set to the erp build number that is installed on the
host.

Example Playbook
----------------

    - hosts: servers
      roles:
        - role: ansible-role-erp-run-test-suite

License
-------

BSD

Author Information
------------------

Dan Rue <dan.rue@linaro.org>

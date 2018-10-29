Define login information to different hosts in yaml.
An existing hosts.yml in same directory is used by default
else the first argument is used.

### Yaml format
Format is a list of items. Each item is a dictionary with following keys.
An item can be one line long at most.

#### required keys
- ip - ip address of host

#### optional keys
- name - name to identify host
- user - default is env var USER or USERNAME
- keyfile - path to ssh private key
- password - password
- detail - extra information to display

### Console sample
```
λ ./login.sh
id | name    | ip        | user   | detail
 0 | vagrant | 127.0.0.1 | ubuntu | gcc483 jdk8
 1 | aws     | 192.0.0.1 |        |
enter id to login:
```

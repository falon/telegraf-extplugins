Role Name
=========

Use this Ansible role to install CSI External Telegraf Plugins.

Requirements
------------

None.

Role Variables
--------------

This role provides the `telegraf_plugins_external` list of dicts. Following the example of **dj-wasabi.telegraf** role, these are the keys:

| key  | description | default |
|----------|----------|----------|
| `name`     | The instance name of the plugin, corresponding to a configuration file. | <ul><li>ds389-default</li><li>ldap_org-default</li></ul> |
| `plugin`   | The plugin name. This is the part following _input._ in the configuration file. | <ul><li>ds389</li><li>ldap_org</li></ul>|
| `config`   | A list of configuration items of the plugin. | Plugin dependent |
| `path`     | Plugin config file path. __Please, don't change this__. | `/etc/CSI-telegraf-plugins` |
| `only_in_this_host` | An host of your inventory. This plugin will install only that host. Leave undefined in order to install in all hosts. | |

Dependencies
------------

In your playbook, you can run this role after Telegraf has installed.

Telegraf must include the _execd_ plugins as well.

For instance, if you use the **dj-wasabi.telegraf** role you must define a var like this:

```
vars:
    telegraf_plugins_extra:
      ds389-default:
        plugin: execd
        config:
          - command = ['/usr/bin/telegraf-ds389', '-config', '/etc/CSI-telegraf-plugins/ds389-default.conf', '-poll_interval', '1m']
        tags:
          - instance = 'default'
      ldap_org:
        plugin: execd
        config:
          - command = ['/usr/bin/telegraf-ldap_org', '-config', '/etc/CSI-telegraf-plugins/ldap_org-default.conf', '-poll_interval', '24h']
        tags:
          - instance = 'default'

roles:
  - dj-wasabi.telegraf
  - falon.telegraf
```

The role assumes that the `telegraf` user already exists, as created by some Telegraf role which runs before.


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: all
      vars:
        telegraf_plugins_extra:
          ds389-default:
            plugin: execd
            config:
              - command = ['/usr/bin/telegraf-ds389', '-config', '/etc/CSI-telegraf-plugins/ds389-default.conf', '-poll_interval', '1m']
            tags:
              - instance = 'default'
          ldap_org-default:
            plugin: execd
            config:
              - command = ['/usr/bin/telegraf-ldap_org', '-config', '/etc/CSI-telegraf-plugins/ldap_org-default.conf', '-poll_interval', '24h']
            tags:
              - instance = 'default'
        telegraf_plugins_external:
          - name: ds389-default
            plugin: ds389
            config:
              - host = "localhost"
              - port = 389
              -
              - "# dn/password to bind with. If bind_dn is empty, an anonymous bind is performed."
              - bindDn = "cn=Directory Manager"
              - bindPassword = "password"
              -
              - '# If true, alldbmonitor monitors all db and overrides "dbtomonitor".'
              - alldbmonitor = true
              -
              - "# Connections status monitor"
              - status = true
            tags:
              - instance = default
            path: /etc/CSI-telegraf-plugins
          - name: ldap_org-default
            plugin: ldap_org
            config:
              - "# LDAP Host and post to query"
              - host = "localhost"
              - port = 389
              -
              - "# dn/password to bind with. If bind_dn is empty, an anonymous bind is performed."
              - bindDn = "cn=Directory Manager"
              - bindPassword = "password"
              -
              - "# Where to count metrics"
              - searchBase = "c=en"
              - retAttr = "o"
              - filter = "(objectClass=*)"
            only_in_this_host: master.example.com

      roles:
         - falon.telegraf-extplugins

If you don't add the `path` key, then the default value will be used. Other keys must be specified.

Add any tags to `execd` plugin in Telegraf. We can't add tags to the external plugin config file, they are not managed by _shim_.

Once you have placed all your execd plugin in Telegraf too, you can test them by:

```
telegraf --config /etc/telegraf/telegraf.conf --config-directory /etc/telegraf/telegraf.d/ --input-filter execd --test-wait 70
```

The real value of `test-wait` is greather than  the maximum `poll_interval` you defined.

At this moment the role doesn't perform tests to validate the configuration of the external plugins.

License
-------
GNU GPL 3 

Author Information
------------------

Marco Favero
 - https://github.com/falon

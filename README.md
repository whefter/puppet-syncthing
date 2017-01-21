#syncthing
[![Build Status](https://travis-ci.org/whefter/puppet-syncthing.png)](https://travis-ci.org/whefter/puppet-syncthing)

**Version 1.0.0 has a (small) number of incompatible changes, most notably:**

* The `version` parameter has been renamed to `package_version` to reflect that this will only affact the version of the package installed, not of binaries.
* Almost all defined types relevant to instance configuration now require `instance_name` in addition to `home_path`.
* On the plus side, it is now possible to create what I like to call "binary" instances that install a defined version of the syncthing binary. See the `binary_version` parameter for more details.

####Table of Contents

1. [Overview](#overview)
2. [Simple setup](#simple-setup)
    * [Beginning with Syncthing](#beginning-with-syncthing)
    * [Syncthing instances](#syncthing-instances)
3. [Usage - Classes and defined types available for configuration](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
        * [Class: syncthing](#class-syncthing)
        * [Defined Type: syncthing::instance](#defined-type-syncthinginstance)
        * [Defined Type: syncthing::device](#defined-type-syncthingdevice)
        * [Defined Type: syncthing::folder](#defined-type-syncthingfolder)
        * [Defined Type: syncthing::folder_device](#defined-type-syncthingfolder-device)
4. [Limitations - OS compatibility, etc.](#limitations)

##Overview
**This module is still very much beta. Syncthing itself is still changing rapidly and has a few quirks.**

This Syncthing module is meant to automate large parts of the Syncthing installation, service management and configuration editing. If provides defined types for Syncthing instances and various parts of the Syncthing configuration files.

Daemonization is currently achieved through a modified version of the Yeasoft btsync init.d script. Currently, there are a number of issues, mostly to do with the fact that Syncthing spawns new processes so often.

##Simple setup

**What syncthing affects:**

* The syncthing installation directory (`/usr/bin/syncthing` by default)
* Configuration file directory `(/etc/syncthing` by default)
* The `init.d` script for Syncthing, if present (`/etc/init.d/syncthing`)

###Beginning with Syncthing

Install Syncthing, the service (init.d script) with default paths, no instances:

```puppet
class { 'syncthing': }
```

###Syncthing instances

Instances can be declared directly in the Syncthing base class, or by defined types:

```puppet
class { '::syncthing':
  instances => {
    'example' => {
      home_path   => '/home/synctester/example_instance',
      daemon_uid  => 'synctest', # Default: root
      daemon_gid  => 'synctester', # Default: root

      # Variables for standard parameters
      gui_tls     => true,
      gui_address => '0.0.0.0', # (Default)
      gui_port    => '8888', # Default: 8080

      # Override or set arbitrary options
      options     => {
        'listenAddress' => 'tcp4://0.0.0.0:19000',
        'startBrowser'  => 'false',
      },
    }
  }
}
```
or:
```puppet
::syncthing::instance { 'example':
  home_path => '/home/synctester/example_instance',
  ...
}
```

##Usage

###Classes and Defined Types


####Class: `syncthing`

Installs Syncthing and sets up the init.d service. The download URL is determined from the Syncthing Github releases page.

**Parameters within `syncthing`:**

#####`bin`

Override the assumed value for the Syncthing binary name. Defaults to `syncthing`.

#####`binpath`

Override the assumed value for the path to the Syncthing binary. Defaults to `/usr/local/bin`. This will actually by a symlink to the latest downloaded syncthing Binary.

#####`store_path`

Override the assumed path to store downloaded and extracted Syncthing releases in. Defaults to `/usr/local/share/syncthing`.

#####`instancespath`

Override the assumed value to the Syncthing instances configuration files. Defaults to `/etc/syncthing`.

#####`package_version`

Override the value used for the installation. Defaults to `latest`, in which case new releases will be downloaded when they are publishing on the Syncthing Github page. Note that Syncthing also has an auto-update mechanism.

#####`manage_repo`

Boolean to install syncthing APT repository. Defaults to `true`.
Set it to `false` to control package installation using your internal / personal repository.

#####`package_name`

The name of the package that will be used for syncthing installation. Defaults to `syncthing`.
Nice option for those we built their own packages.

#####`instances`

Hash that will be used to declare `syncthing::instance` resources.

#####`folders`

Hash that will be used to declare `syncthing::folder` resources.

#####`devices`

Hash that will be used to declare `syncthing::device` resources.

#####`create_home_path`

Override the default value passed to `syncthing::instance`for `create_home_path`.

#####`daemon_uid`

Override the default value passed to `syncthing::instance`for `daemon_uid`.

#####`daemon_gid`

Override the default value passed to `syncthing::instance`for `daemon_gid`.

#####`daemon_umask`

Override the default value passed to `syncthing::instance`for `daemon_umask`.

#####`daemon_nice`

Override the default value passed to `syncthing::instance`for`daemon_nice`.

#####`daemon_debug`

Override the default value passed to `syncthing::instance` for `daemon_debug`.

#####`gui`

Override the default value passed to `syncthing::instance`for `gui`.

#####`gui_tls`

Override the default value passed to `syncthing::instance`for `gui_tls`.

#####`gui_address`

Override the default value passed to `syncthing::instance`for `gui_address`.

#####`gui_port`

Override the default value passed to `syncthing::instance` for `gui_port`.

#####`gui_apikey`

Override the default value passed to `syncthing::instance`for `gui_apikey`.

#####`gui_user`

Override the default value passed to `syncthing::instance`for `gui_user`.

#####`gui_password`

Override the default value passed to `syncthing::instance`for `gui_password`.

> See the notes on `gui_password` and `gui_password_salt` in the parameters for `syncthing::instance` for some important information regarding these two options.

#####`gui_password_salt`

Override the default value passed to `syncthing::instance`for `gui_password_salt`.

#####`gui_options`

Override the default value passed to `syncthing::instance`for `gui_options`.

#####`instance_options`

Override the default value passed to `syncthing::instance` for `options`.

#####`device_compression `

Override the default value passed to `syncthing::device` for `compression `.

#####`device_introducer `

Override the default value passed to `syncthing::device` for `introducer`.

#####`device_options`

Override the default value passed to `syncthing::device` for `options`.

####Defined Type: `syncthing::instance`

Creates an instance. Provides some parameters for common options and an `options` parameter to override or set arbitrary options.

```puppet
  syncthing::instance { 'example':
    home_path  => '/etc/backups/example',
    daemon_uid => 'user',
    gui_tls    => true,
  }
```

**Parameters within `syncthing::instance`:**

#####`ensure`

Specify whether the instance configuration file is present or absent. Defaults to 'present'. Valid values are 'present' and 'absent'.

#####`home_path`

The home path for this instance. Where the configuration file and all certificates are stored. Mandatory parameter, will be created by Syncthing if not present.

#####`create_home_path`

Attempt to recursively create the passed home path prior to calling Syncthing to generate the configuration/certificates. This will be
called in the context of the user identified by `daemon_uid`.

#####`binary`

Sets this instance to be a "binary instance", meaning it will download a Syncthing binary to the path specified by `binary_path` and use that binary instead of the package-provided binary.

#####`binary_path`

If `binary` is set to `true`, the Syncthing binary will be downloaded to this path.

#####`binary_version`

The Syncthing version to get when downloading a Syncthing binary. Defaults to `latest`.

**Note that once a binary has been downloaded, this parameter becomes ineffective due to the fact that only the existance of a binary is checked, not the version.**

**This has the advantage that a binary instance, once created, can be upgraded independently from other instances, in constrast with "package instances", which all share the package binary and get upgraded/restarted when the package is upgraded.**

#####`daemon_uid`

The UID to run the daemon for this instance as.

#####`daemon_gid`

The GID to run the daemon for this instance as.

#####`daemon_umask`
The umask to run the daemon for this instance with.

#####`daemon_nice`

The niceness level for the instance daemon.

#####`daemon_debug`

The debug level for the instance daemon.

#####`gui`

Enable or disable the GUI. Valid values are `true` or `false`. Defaults to `true`.

#####`gui_tls`

Enable or disable SSL for the GUI. Valid values are `true` or `false`. Defaults to `true`.

#####`gui_address`

The address the GUI should listen at. Defaults to `0.0.0.0`.

#####`gui_port`

Binding port for the GUI. Defaults to `8080`.

#####`gui_apikey`

The API key for the GUI.

#####`gui_user`

Providing this and `gui_password` enables user authentication.

#####`gui_password`

Password to use to authenticate for the GUI.

If a salt string is provided through the `gui_password_salt` parameter (see below), then the value passed to `gui_password` is assumed to be the plaintext password and will be hashed with BCrypt prior to being inserted into the configuration file, using `gui_password_salt` as salt.

If `gui_password_salt` is not provided, the value passed to `gui_password` will be inserted as-is into the configuration file. This way, a BCrypt hash can be provided directly so as not to have plaintext passwords in the Puppet/Hiera files.

One method to hash a password with a random salt to obtain a hash for that password for direct insertion is (requires the `bcrypt` gem):

```ruby
ruby -e "require 'bcrypt'; puts BCrypt::Engine.hash_secret('<<<PASSWORD>>>', BCrypt::Engine.generate_salt);"`
```

#####`gui_password_salt`

This must be set to a valid BCrypt salt such as `$2a$10$vI8aWBnW3fID.ZQ4/zo1G.` when providing plaintext passwords for hashing through this module.

One method to generate hashes is (requires the `brypt` gem):

```ruby
ruby -e "require 'bcrypt'; salt = BCrypt::Engine.generate_salt; puts salt;"
```

> Setting this parameter will result in the module attempting to generate a BCrypt-encrypted password. This requires the `bcrypt` gem to be installed on the puppetmaster.

#####`gui_options`

Set or override arbitrary GUI options. Created as XML nodes in the `<gui></gui>` element.

#####`options`

Set or override arbitrary options. Created as XML nodes in the `<options></options>` element.

####Defined Type: `syncthing::device`

Adds a `<device>` entry to the configuration file for the instance associated with the passed home path.

Direct declarations of this type are possible, but discouraged outside of programatical declarations due to its cumbersome options. Defining devices through the `devices` parameter of the `syncthing::instance` class is much more practical in any manual definition scenario.

```puppet
  ::syncthing::device { 'laptop':
    home_path     => '/etc/backup/instance1',
    instance_name => 'instance1',
    id            => '523LMDC-KKQPKVU-JBPGYQU-IAGHP5B-TU38GN4-G7CEEHG-OOL32IR-YWQSFAX',
    compression   => true,
  }
```

**Parameters within `syncthing::device`:**

#####`ensure`

Specify whether the device configuration is present or absent. Defaults to 'present'. Valid values are 'present' and 'absent'.

#####`home_path`

The home path for the instance that should be told about this device. Mandatory parameter.

#####`instance_name`

The name of the instance that should be told about this device, as passed to the `instances` parameter on the `syncthing` class. Mandatory parameter.

#####`id`

The ID for the device in the usual form.

#####`device_name`

The name for the device, defaults to the resource name.

#####`compression`

Value to set for the `compression` option for this device. Can be `true` or `false`, defaults to `false`.

#####`introducer`

Value to set for the `introducer` option for this device. Can be `true` or `false`, defaults to `false`.

#####`address`

Set an address to use to contact the device. Defaults to `dynamic`.

#####`options`

Set or override arbitrary options. Created as XML nodes in the `<device></device>` element.

####Defined Type: `syncthing::folder`

Adds a `<folder>` entry to the configuration file for the instance associated with the passed home path.

Direct declarations of this type are possible, but discouraged outside of programatical declarations due to its cumbersome options. Defining folders through the `folders` parameter of the `syncthing::instance` class is much more practical in any manual definition scenario.

```puppet
::syncthing::folder { 'laptop':
  home_path     => '/etc/backup/instance1',
  instance_name => 'instance1',
  id            => 'backupfolder1',
  path          => '/home/syncuser/myfiles',
  options       => {
    # Override options here
  },
  devices       => {
    '523LMDC-KKQPKVU-JBPGYQU-IAGHP5B-TU38GN4-G7CEEHG-OOL32IR-YWQSFAX' => 'present',
  }
}
```

**Parameters within `syncthing::folder`:**

#####`ensure`

Specify whether the device configuration is present or absent. Defaults to 'present'. Valid values are 'present' and 'absent'.

#####`home_path`

The home path for the instance that should be told about this folder. Mandatory parameter.

#####`instance_name`

The name of the instance that should be told about this device, as passed to the `instances` parameter on the `syncthing` class. Mandatory parameter.

#####`id`

The ID for the folder. Defaults to the `name` parameter.

#####`path`

Path to the folder that should be synced.

#####`ro`

Value to set for the `ro` option for this folder. Can be `true` or `false`, defaults to `false`.

#####`rescanIntervalS`

Value to set for the `rescanIntervalS` option for this device. Defaults to `60`.

#####`ignorePerms`

Value to set for the `ignorePerms` option for this device. Can be `true` or `false`, defaults to `false`.

#####`options`

Set or override arbitrary options. Created as XML nodes in the `<folder></folder>` element.

#####`devices`

A hash of devices to enable for the folder. Invididual device IDs can be specified and set to `present` or `absent`:

```puppet
::syncthing::folder { 'laptop':
  ...
  devices => {
    '523LMDC-KKQPKVU-JBPGYQU-IAGHP5B-TU38GN4-G7CEEHG-OOL32IR-YWQSFAX' => 'present',
    'IAGHP5B-7IASKM-JBPGYQU-G7CEEHG-TU38GN4-TU38GN4-523LMDC-OOL32IR'  => 'absent',
  }
  ...
}
```

####Defined Type: `syncthing::folder_device`

Adds a `<device>` entry for the specified folder.

```puppet
::syncthing::folder { 'backupfolder1_on_laptop':
  home_path     => '/etc/backup/instance1',
  instance_name => 'instance1',
  folder_id     => 'backupfolder1',
  device_id     => '523LMDC-KKQPKVU-JBPGYQU-IAGHP5B-TU38GN4-G7CEEHG-OOL32IR-YWQSFAX',
}
```

**Parameters within `syncthing::folder_device`:**

#####`ensure`

Specify whether the device entry is present or absent. Defaults to 'present'. Valid values are 'present' and 'absent'.

#####`home_path`

The home path for the instance that should be told about this device. Mandatory parameter.

#####`instance_name`

The name of the instance that should be told about this device, as passed to the `instances` parameter on the `syncthing` class. Mandatory parameter.

#####`folder_id`

The ID of the folder.

#####`device_id`

The ID of the device.

##Reference

###Classes

####Public Classes

* [`syncthing`](#class-syncthing): Basic setup.

####Private Classes

* `syncthing::install_package`: Installs the Syncthing package.
* `syncthing::install_binary`: Downloads a Syncthing binary.
* `syncthing::service`: Installs the Syncthing init.d daemon.
* `syncthing::instance_service`: Provides commands that emulate service start/stop/restart for binary Syncthing instances.
* `syncthing::params`: Manages Syncthing parameters.

###Defined Types

####Public Defined Types

* `syncthing::instance`
* `syncthing::device`
* `syncthing::folder`
* `syncthing::folder_device`: Adds a known device to a folder.

##Limitations

###Operating system support

Currently, only Debian and Ubuntu are supported. Debian has been tested more extensively. Contributions adding support for further OSes are welcome!

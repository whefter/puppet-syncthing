class syncthing::install {

  case $::operatingsystem {
    Debian: {
      file { $syncthing::binpath:
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }->
      exec { "download and unpack syncthing":
        cwd     => $syncthing::binpath,
        command => "wget -O - https://github.com/syncthing/syncthing/releases/download/v${syncthing::version}/syncthing-linux-amd64-v${syncthing::version}.tar.gz | tar xzf - --strip-components=1 syncthing-linux-amd64-v${syncthing::version}/syncthing",
        creates => "${syncthing::binpath}/${syncthing::bin}",
        path    => $::path,
      }
    }
    Ubuntu: {
      apt::ppa { 'ppa:ytvwld/syncthing': }
      ->
      package { 'syncthing':
        ensure => $syncthing::version,
      }
    }
    default: {
        fail "Unsupported Operating System: ${::operatingsystem}"
    }
  }

}

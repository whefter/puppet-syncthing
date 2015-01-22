class syncthing::install
(
)
{
  case $::operatingsystem {
      Debian: {
			  file { $syncthing::binpath:
			    ensure        => directory,
			    owner         => root,
			    group         => root,
			    mode          => '0755',
			  }
			  ->
			  exec { "download and unpack syncthing":
			    #provider    => shell,
			    cwd         => $syncthing::binpath,
			    #command     => "wget -q -O /tmp/syncthing.tar.gz https://github.com/syncthing/syncthing/releases/download/v${syncthing::version}/syncthing-linux-amd64-v${syncthing::version}.tar.gz && tar xvz --strip-components=1 -f /tmp/syncthing.tar.gz",
			    command     => "wget -O - https://github.com/syncthing/syncthing/releases/download/v${syncthing::version}/syncthing-linux-amd64-v${syncthing::version}.tar.gz | tar xzf - --strip-components=1",
			    creates     => "${syncthing::binpath}/${syncthing::bin}",
			    path        => $::path,
			  }
      }
      Ubuntu: {
        apt::ppa { 'ppa:ytvwld/syncthing': }
        ->
        package { 'syncthing':
          ensure    => $syncthing::version,
        }
      }
      default: {
          fail "Unsupported Operating System: ${::operatingsystem}"
      }
  }
}
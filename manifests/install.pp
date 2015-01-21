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
			  
			  #https://github.com/syncthing/syncthing/releases/download/v0.10.20/syncthing-linux-amd64-v0.10.20.tar.gz
			  exec { "download and unpack syncthing":
			    #provider    => shell,
			    cwd         => $syncthing::binpath,
			    #command     => "wget -q -O /tmp/syncthing.tar.gz https://github.com/syncthing/syncthing/releases/download/v${syncthing::version}/syncthing-linux-amd64-v${syncthing::version}.tar.gz && tar xvz --strip-components=1 -f /tmp/syncthing.tar.gz",
			    command     => "wget -O - https://github.com/syncthing/syncthing/releases/download/v${syncthing::version}/syncthing-linux-amd64-v${syncthing::version}.tar.gz | tar xzf - --strip-components=1",
			    creates     => "${syncthing::binpath}/${syncthing::bin}",
			    path        => $::path,
			    
			    require     => [
			      File[$syncthing::binpath],
			    ], 
			  }
      }
      Ubuntu: {
        package { 'syncthing': }
      }
      default: {
          fail "Unsupported Operating System: ${::operatingsystem}"
      }
  }
}
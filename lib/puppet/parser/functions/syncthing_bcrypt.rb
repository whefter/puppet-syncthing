module Puppet::Parser::Functions
  newfunction(:syncthing_bcrypt, :type => :rvalue) do |args|
    begin
      require 'bcrypt'
    rescue LoadError
      raise Puppet::ParseError, "syncthing_bcrypt(): bcrypt gem is required to hash passwords."
    end

    if args.length == 1
      BCrypt::Password.create(args[0]).to_s
    elsif args.length == 2
      # Custom salt.
      BCrypt::Engine.hash_secret args[0], args[1]
    else
      raise Puppet::ParseError, "syncthing_bcrypt(): Invalid number of arguments."
    end
  end
end

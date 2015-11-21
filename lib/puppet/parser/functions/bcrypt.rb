module Puppet::Parser::Functions
  newfunction(:bcrypt, :type => :rvalue) do |args|
    require 'bcrypt'

    if args.length == 1
      BCrypt::Password.create(args[0]).to_s
    elsif args.length == 2
      # Custom salt.
      BCrypt::Engine.hash_secret args[0], args[1]
    else
      raise Puppet::ParseError, "bcrypt(): Invalid number of arguments"
    end
  end
end

module Puppet::Parser::Functions
  newfunction(:bcrypt, :type => :rvalue) do |plain|
    require 'bcrypt'
    BCrypt::Password.create(plain).to_s
  end
end
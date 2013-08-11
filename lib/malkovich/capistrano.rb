require "capistrano"
require "malkovich/capistrano/version"
require 'malkovich/capistrano/puppet'

if Capistrano::Configuration.instance
  require "malkovich/capistrano/defaults"
  require "malkovich/capistrano/tasks"
end

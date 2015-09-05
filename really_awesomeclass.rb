require 'fileutils' # A standard library class
require 'diffy' # A class installed by the diffy gem
require_relative './awesomeclass.rb' # A local class file

module AwesomeInc # Awesome class is declared in the file we're requiring
  class ReallyAwesome < Awesome
  end
end

stam = AwesomeInc::ReallyAwesome.new(777)
p stam.awesome_level
#!/usr/bin/env ruby
require 'optparse'
require 'jxparameter_spec'

class JXParameter
  include JXParameterSpec
  
  attr_accessor :options
  attr_accessor :arguments

  def initialize(run_name='{this program}')
    # parsed from the command-line by OptionParser.
     options = {}
     
     @o = optparse = OptionParser.new do|opts|
       # Set a banner, displayed at the top of the help screen.
       opts.banner = "Usage: #{run_name}.rb [--store | --clean | --fetch to_where]  ..."

       spec(options, opts)
     
       # This displays the help screen, all programs are
       # assumed to have this option.
       opts.on( '-h', '--help', 'Display this screen' ) do
         puts opts
         exit
       end
       
     end
     
     # The 'parse!' method parses ARGV and removes
     # any options found there, as well as any parameters for
     # the options. What's left is the list of other args.
     begin
      optparse.parse!
      # require at least one option to be set
      is_set = false
        options.each do |k,v| 
        if v
          is_set = true
        end
      end
      if !is_set
       puts "Missing Option Argument.  Use '--help' to see all valid options."
       exit 2
      end
     rescue OptionParser::InvalidOption => e
       puts "Invalid Option.  Use '--help' to see all valid options."
       puts "Found: #{e}.", @o
       exit 1
     rescue OptionParser::MissingArgument => e
       puts "Missing Option Argument.  Use '--help' to see all valid options."
       puts "Found: #{e}.", @o
       exit 2
     rescue OptionParser::ParseError => e
       puts "Found: #{e}.", @o
       exit 3
     end
     
     @arguments = []
     ARGV.each do|v|
       if !validate_arg v, @options
         puts "Invalid Option. Use '--help' to see all valid options."
         exit 4
       end
       @arguments << v
     end
     
     @options = options
  end
end


     




#!/usr/bin/env ruby

module JXParameterSpec
  # an argument is interpreted as a fetch directory
  $valid = false
  
  # Define the options we want to have, and what they do
  def spec(options, opts)
    
    # mutually exclusive switches
    # store. fetch, clean
     options[:store] = false
     options[:fetch] = false
     options[:clean] = false
     switches = 0
     
     opts.on( '-s', '--store', 'Store toolkit.') do
       options[:store] = true
       switches = switches + 1
       if switches > 1
         remove_all! options
       end
     end
     
     opts.on( '-c', '--clean', 'Remove toolkit.') do
       options[:clean] = true
       switches = switches + 1
       if switches > 1
         remove_all! options
       end
     end
     
     opts.on( '-f', '--fetch', 'Fetch toolkit.') do |fetch|
       options[:fetch] = fetch
       switches = switches + 1
       if switches == 1
         $valid = true
       elsif switches > 1
         remove_all! options
       end
     end
  end
  
  def remove_all! options
    $valid = false
    options[:store] = false
    options[:fetch] = false
    options[:clean] = false
    options[:help] = true
  end
  
  def validate_arg(arg, options)
    return $valid
  end
end
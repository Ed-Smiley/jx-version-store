#!/usr/bin/env ruby
# Copyright 2011 ebrary
# Encapsulate Isis toolkit for a Maven-ish JXTR repo on S3
# author Ed Smiley
#

require 'lib/jxartifact'
require 'lib/jxparameter'

class IsisToolkit
  attr_reader :art
  attr_reader :isis_release
  attr_reader :isis_location
  attr_reader :version
  attr_reader :dependencies
  attr_reader :project
  attr_reader :module

  def initialize
    @isis_location = ENV["ISIS"]
    if @isis_location.nil?
      @isis_location = '../isis'
    end
    @isis_release = "#{@isis_location}/release"
    if !File.exist?(@isis_release)
      warn "Please rebuild Isis in: '#{@isis_location}'.  Missing required file: '#{@isis_release}'."
      exit(1)
    end
    
    @project = "com.ebrary.isis"
    @module = 'toolkit'
    
    version_number = ENV["ISIS_VERSION"]
    if version_number.nil?
      puts "Toolkit ISIS_VERSION not set, using SHA1"
      @version = sha1
    else
      @version = version_number
    end
    
    @dependencies =
      [  "#{@isis_release}/isis-modules/document-client.jar", 
          "#{@isis_release}/isis-modules/document-processor.jar", 
          "#{@isis_release}/isis-server/client-server.jar", 
          "#{@isis_release}/isis-server/document-server.jar", 
          "#{@isis_release}/isis-server/search-server.jar", 
          "#{@isis_release}/isis-server/server.jar", 
          "#{@isis_release}/isis-server/software-server.jar", 
          "#{@isis_release}/isis-server/transport-server.jar", 
          "#{@isis_release}/isis-server/user-server.jar", 
          "#{@isis_release}/isis-server/util.jar", 
          "#{@isis_release}/admin/lib/netstore.jar",
          "#{@isis_location}/lib/common.jar",
          "#{@isis_location}/artifactor/lib/IsisServices.rb", #TODO, make part of vertical generator
          "#{@isis_location}/artifactor/lib/IsisUtil.rb", #TODO, make part of vertical generator
      ]

    @art = JXArtifact.new(@isis_release, @project, @module, @version, @dependencies)
  end
  
  def run run_name
    param = JXParameter.new(run_name)
    if param.options[:fetch]
      param.arguments.each do |dir|
        fetch dir
      end
    elsif param.options[:store]
      store
    elsif param.options[:clean]
      clean
    end
  end
  
  def fetch dir
    @art.fetch dir
  end
  
  def store
    @art.store
  end
  
  def clean
    @art.clean
  end
  
  private
  
    # computes and returns the GIT SHA1 for an Isis release 
  def sha1
    currwd = Dir.pwd
    Dir.chdir(@isis_release)
    res = Git.git("log -n1").split
    Dir.chdir(currwd)
    return res[1]
  end
end

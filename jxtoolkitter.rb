# Copyright 2011 ebrary
# Create Isis toolkit in a Maven-ish JXTR repo on S3
# author Ed Smiley
#
# Usage: ./toolkitter.rb [store|fetch]
# Version number for this release

require 'jxartifact'

VERSION_NUMBER = ENV["ISIS_VERSION"]

# Group identifier for project
PROJECT = "com.ebrary.isis"
# Module
MODULE = 'toolkit'
  
ISIS = ENV["ISIS"]
if ISIS.nil?
  ISIS = '../isis'
end
ISIS_RELEASE = "#{ISIS}/release"
if !File.exist?(ISIS_RELEASE)
  warn "Please rebuild Isis in: '#{ISIS}'.  Missing required file: '#{ISIS_RELEASE}'."
  exit(1)
end

if VERSION_NUMBER.nil?
  puts "Toolkit ISIS_VERSION not set, using SHA1"
  VERSION = isis_git_sha1
else
  VERSION = VERSION_NUMBER
end
puts "ISIS_RELEASE=#{ISIS_RELEASE}"
puts "ISIS TOOLKIT PROJECT=#{PROJECT}"
puts "ISIS TOOLKI MODULE=#{MODULE}"
puts "ISIS TOOLKIT VERSION=#{VERSION}"

dependencies =
  [  "#{ISIS_RELEASE}/isis-modules/document-client.jar", 
      "#{ISIS_RELEASE}/isis-modules/document-processor.jar", 
      "#{ISIS_RELEASE}/isis-server/client-server.jar", 
      "#{ISIS_RELEASE}/isis-server/document-server.jar", 
      "#{ISIS_RELEASE}/isis-server/search-server.jar", 
      "#{ISIS_RELEASE}/isis-server/server.jar", 
      "#{ISIS_RELEASE}/isis-server/software-server.jar", 
      "#{ISIS_RELEASE}/isis-server/transport-server.jar", 
      "#{ISIS_RELEASE}/isis-server/user-server.jar", 
      "#{ISIS_RELEASE}/isis-server/util.jar", 
      "#{ISIS_RELEASE}/admin/lib/netstore.jar",
      "#{ISIS}/lib/common.jar",
      "#{ISIS}/artifactor/lib/IsisServices.rb", #TODO, make part of vertical generator
      "#{ISIS}/artifactor/lib/IsisUtil.rb", #TODO, make part of vertical generator
  ]

puts "ISIS_RELEASE=#{ISIS_RELEASE}"
puts "ISIS TOOLKIT PROJECT=#{PROJECT}"
puts "ISIS TOOLKIjxstoreE=#{MODULE}"
puts "ISIS TOOLKIT VERSION=#{VERSION}"

jxartifact = JXArtifact.new(ISIS_RELEASE, PROJECT, MODULE, VERSION, dependencies)

# computes and returns the GIT SHA1 for an Isis release 
def isis_git_sha1(isis_git_dir=ISIS_RELEASE)
  currwd = Dir.pwd
  Dir.chdir(isis_git_dir)
  res = Git.git("log -n1").split
  Dir.chdir(currwd)
  return res[1]
end


#!/usr/bin/env ruby
# Copyright 2011 ebrary
# Run Isis toolkit from command line.
# author Ed Smiley
#
# Usage: ./isis-toolkitter.rb [--store | --clean | --fetch to_where]
# 
# NOTE: uses two environment variables, $ISIS, and $ISIS_VERSION
# $ISIS: the location of the Isis repo where the build has been done
#  - if $ISIS is NOT SET it will default to the relative path "../isis"
# $ISIS_VERSION the version of the toolkit module (e.g. 2.01), each is stored separately
#  - if $ISIS_VERSION is NOT SET it will default to the SHA1 digest of the Isis repo


require 'rubygems'
require 'isis_toolkit'

IsisToolkit.new.run "./isis-toolkitter.rb"

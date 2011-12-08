#!/usr/bin/env ruby
# Copyright 2011 ebrary
# Run Isis toolkit from command line.
# author Ed Smiley
#
# Usage: ./isis-toolkitter.rb [--store | --clean | --fetch to_where]
# 
require 'rubygems'
require 'isis_toolkit'

IsisToolkit.new.run "./isis-toolkitter.rb"

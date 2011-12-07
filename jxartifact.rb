# Copyright 2011 ebrary
# Encapsulate a Maven-like artifact implmented using a JXTR repo on S3
# author Ed Smiley
#

class JXArtifact
  attr_accessor :release
  attr_accessor :project
  attr_accessor :module
  attr_accessor :version
  attr_accessor :files
  attr_accessor :jxstore
  
  # 
  #  rel: the project release location for the artifact
  #  proj: the project name for project containing the artifact
  #  mod: the module name for the artifact
  #  ver: the version of the artifact
  #  files: array of required files for the artifact
  # 
  def initialize(rel, proj, mod, ver, files)
    @release = rel
    @project = proj
    @module = mod
    @version = ver
    @files = files
    @files.each do |d|
      if !File.exist? d
        throw Exception.new "Please rebuild '#{@project}:#{@module}:#{@version}' artifact components in: '#{@release}'.  Missing required file: '#{d}'."
      end
    end
    @jxstore = JXVersionStore.new(@project, @module, @version)
  end
  
  def store
    puts 'Creating temporary workspace.'
    tempdir = "#{Dir.tmpdir}/_d#{rand 99999999999999}"
    if !File.exists? tempdir
      Dir.mkdir tempdir
    end
    FileUtils.chmod(0777, tempdir)
    files.each do |d|
      FileUtils.cp d, tempdir
    end
    puts 'Storing toolkit.'
    @jxstore.store tempdir
    puts 'Cleaning temporary workspace.'
    FileUtils.rm_r(tempdir)
  end


  def fetch dest
    @jxstore.fetch dest
  end
  
  def clean
    @jxstore.kill
  end
end
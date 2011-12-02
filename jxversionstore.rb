require 'fileutils'
require 'digest'

require 'jxrepo'
require 'jxtr/receiver'
require 'jxtr/sender'
require 'jxtr/deleter'
require 'jxtr/utils'

# Implement a Maven-like bucket repository on top of Jxtr.
# If you are not using any format, just use regular Jxtr for free format buckets.
# author: Ed Smiley
# copyright ebrary 2011
#
# usage example:
# jx_store = JXVersionStore.new('com.ebrary.isis', 'toolkit', '2.0')
# jx_store.send(src, dest)
# jx_store.receive(dest)
#
# note: requires 'HOME, 'AMAZON_ACCESS_KEY_ID','AMAZON_SECRET_ACCESS_KEY' to be set in environment

mutex = Mutex.new
REPORT_TYPES = {
  :read => "Received",
  :write => "Wrote",
  :delete => "Deleted",
  :info => "INFO:",
  :error => "An error occured:"
}
REPORTER = Proc.new {|info| mutex.synchronize { puts "#{REPORT_TYPES[info[:type]]} #{info[:msg]}"}}
DEFAULT_THREADS = 1 # test performance on dev mac---maybe s/b 2, 3, 4?
# e.g. 'dev-us-west-1.ebrary.com' 
S3_STORE = ENV['AMAZON_S3_STORE'] 


class JXVersionStore
  include Jxtr
  include Utils

  attr_reader :repo
  attr_reader :threads
  
  # project: e.g. 'com.ebrary.isis'
  # component: e.g. 'utils', 'toolkit', 'release' etc.
  # version: e.g '1.0.1', '2.0' etc.
  # user_namespace: either a private personal namespace, or as 'common'--a public namespace (default)
  # threads: number of threads to use for sending and receiving. default = DEFAULT_THREADS
  def initialize(project, component, version, user_namespace = 'common', threads = DEFAULT_THREADS)
    @repo = JXRepo.new(project, component, version, user_namespace)
    @threads = threads
  end
  
  # bucket_str: format is _namespace_|"common":_project_:_component_:_version_
  # threads: number of threads to use for sending and receiving. default = DEFAULT_THREADS
  #
  # def initialize(bucket_str, threads = DEFAULT_THREADS)
  #   @repo = JXRepo.new(bucket_str)
  #   @threads = threads
  # end
  
  # store src at dest under JXRepo namespace
  # src: the source
  def store src
    dest=@repo.to_s
    if File.readable?(src) && File.writable?(src) && File.directory?(src)
      if src.match /.\//
        dir = src
      else
        dir = src + '/'
      end
      manifest = make_manifest src
      manifest_file = ::File.join(src, 'manifest')
      write_manifest manifest, manifest_file
      puts "Sending: #{dest} to #{S3_STORE}"
      sender = Sender.new(S3_STORE, src, dest)
      sender.send @threads, &REPORTER
    elsif !File.directory?(src)
      raise "Source #{src} not a directory."
    else
      raise "Source #{src} not readable and writable."
    end
  end
  
  # fetch to dest from S3 under JXRepo namespace
  # dest: the location of the local cache, if it is not specified
  def fetch dest=@repo.cache_path
    src = @repo.to_s
    if !File.exists? dest
      FileUtils.mkdir_p(dest+'/')
    end 
    receiver = Receiver.new S3_STORE
    puts "DEBUG: fetching from: #{src} at #{S3_STORE}"
    receiver.receive src, dest, @threads, &REPORTER
  end
  
  # Fetch a copy of the current version in cache and place it in new_dest.
  # Note: WARNING: destructive copy over any contents of new_dest
  # 
  # new_dest: 
  #   if new_dest does not exist, it will be created
  #   if it does exist, its contents will be REMOVED and REPLACED with the new contents!
  # fetch_if_missing: 
  #   if true, and only if cache does not exist, it will be created, 
  #   otherwise a missing cache will NOT be created and an exception will be thrown
  def fetch_local(new_dest, fetch_if_missing = true)
    if !File.exists? @repo.cache_path
      if fetch_if_missing
        fetch
      else
        raise "Source cache #{@repo.cache_path} not readable."
      end
    end
    FileUtils.cp_r @repo.cache_path, new_dest
  end
  
  # remove versioned stored object from S3
  def kill 
    remote_data = @repo.to_s
    deleter = Deleter.new S3_STORE
    deleter.delete remote_data, @threads, &REPORTER
  end
  
  private
  
  def make_manifest files_dir, manifest_name='manifest'
    manifest = {}
    files = Dir["#{files_dir}/**/*"]
    files.each do |f|
      if !File.directory? f
        hash = Digest::MD5.file(f).hexdigest
        file = f.sub "#{files_dir}/", ''
        if file!=manifest_name
          manifest[file] = hash
        else
        end
      end
    end
    manifest
  end
end


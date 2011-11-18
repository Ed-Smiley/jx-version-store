# copyright 2011 ebrary
#  author: Ed Smiley
# Encapsulate JXTR maven-like repo information to implement a Maven-like bucket repository on top of Jxtr.
class JXRepo
  attr_accessor :namespace
  attr_accessor :project
  attr_accessor :component
  attr_accessor :version
  
  # namespace: personal namespace
  # project: e.g. 'com.ebrary.isis'
  # component: e.g. 'utils', 'toolkit', 'release' etc.
  # version: e.g '1.0.1', '2.0' etc.
  def initialize(project, component, version, namespace)
    if project==nil || component==nil || version==nil || namespace==nil
      raise 'Nil bucket.'
    end
    @namespace = namespace
    @project = project
    @version = version
    @component = component
  end
  
  # bucket_str: format is _namespace_|"common":_project_:_component_:_version_
  def intialize(storage_str)
    if storage_str == nil
      raise 'Nil storage.'
    end
    b = storage_str.split[":"]
    
    if b.length==3
      @namespace = 'common'
    elsif b.length==4
      @namespace = b[0]
      b.delete_at 0
    else
      raise 'Malformed storage'
    end
      @project = b[0]
      @component = b[1]
      @version = b[2]
  end
  
  # the local cache path
  def cache_path
    home = ENV['HOME']!=nil ? ENV['HOME'] : ''
    return "#{home}/.jx/repository/#{to_s}/"
  end
  
  # string style representation of repo
  def to_s
    return "#{namespace}:#{project}:#{component}:#{version}"
  end
  
end


#!/usr/bin/env ruby

# remove all cached files
require 'fileutils'

if __FILE__ == $0
  public_dir = File.join(File.dirname(__FILE__),'..','public')
  FileUtils.rm_f File.join(public_dir,'apiloc.html')
  FileUtils.rm_f File.join(public_dir,'index.html')
  FileUtils.rm_rf File.join(public_dir,'apiloc')
  FileUtils.rm_rf File.join(public_dir,'microscopy')
  FileUtils.rm_rf File.join(public_dir,'species')
  FileUtils.rm_rf File.join(public_dir,'developmental_stage')
else
  raise Exception, 'eh?'
end

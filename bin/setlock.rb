#!/usr/bin/env ruby
# 
# setlock implementation in Ruby
# The original setlock.c is in https://cr.yp.to/daemontools.html
#
require 'optparse'

Version = '1.0.0'
flagx = false
flagndelay = false

parser = OptionParser.new
parser.banner = "Usage: setlock.rb [ -nNxX ] file program [ arg ... ]"
parser.on('-n','No delay. If fn is locked by another process, setlock gives up.'){|v|flagndelay=v}
parser.on('-N','(Default.) Delay. If fn is locked by another process, setlock waits until it can obtain a new lock.'){|v|flagndelay=!v}
parser.on('-x','If fn cannot be opened (or created) or locked, setlock exits zero.'){|v|flagx=v}
parser.on('-X','(Default.) If fn cannot be opened (or created) or locked, setlock prints an error message and exits nonzero.'){|v|flagx=!v}
parser.summary_width=3

begin
	parser.parse!(ARGV)
rescue => e
	abort "#{e.message}"
end

lockfile = ARGV.shift

abort "missing argument.\n#{parser.help}" if ARGV.size == 0
	
f = nil
begin
  f = File.open(lockfile, 'w')
rescue => e
  exit 0 if flagx
  abort "unable to open #{lockfile}"
end

if not f.flock(flagndelay ? (File::LOCK_EX|File::LOCK_NB) : File::LOCK_EX)
  exit 0 if flagx
  abort "unable to lock #{lockfile}"
end

system ARGV[0], *ARGV[1..-1]
exit $?.exitstatus

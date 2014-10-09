require 'thor'
require_relative 'util'

module WTool
	class Application < Thor
		desc "check RANGE", "Check IPs"
		def check(range)
			net = range.split(',').map(&:strip)
			net.each do |ip|
				l = WTool::Util.get_ipaddr_list(ip)
				l.each do |t|
					puts t
				end
			end
		end
	end
end


WTool::Application.start(ARGV)
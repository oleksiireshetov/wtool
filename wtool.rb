require 'thor'
require_relative 'util'

module WTool
	class Application < Thor
		desc "check RANGE", "Check IPs"
		def check(range)
			colo = []
			net = range.split(',').map(&:strip)
			net.each do |ip|
				l = WTool::Util.get_ipaddr_list(ip)
				l.each do |t|
					print "Checking IPv4: #{t} "
					result = WTool::Util.revise(t)
					result.each do |res|
						if res.isClean
							status = "SUCCESS"
						else
							status = "FAIL #{res.url}"
						end	
						print " #{res.type}:#{status} "
					end
					puts
				end
			end
		end
	end
end


WTool::Application.start(ARGV)
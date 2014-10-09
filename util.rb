require 'ipaddr'

module WTool
	class Util	
		def self.get_ipaddr_list(ip_entry)
			if ip_entry.include? "/"
				return IPAddr.new(ip_entry).to_range
			end
			if 	ip_entry.include? "-"
				range = ip_entry.split("-")
				low_range = IPAddr.new(range[0]).to_i
				high_range = IPAddr.new(range[1]).to_i
				array = []			
				for numeric_ip in low_range..high_range
					array.push IPAddr.new(numeric_ip, Socket::AF_INET).to_s
				end	
				return array
			end
			return [IPAddr.new(ip_entry)];
		end
	end
end	
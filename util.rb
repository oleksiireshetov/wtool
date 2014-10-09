require 'ipaddr'
require 'net/http'

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

		def self.revise(ip_addr)
			result = []
			if revise_by_type(ip_addr, :mcafee) == false
				result.push :mcafee
			end
			if revise_by_type(ip_addr, :drweb) == false
				result.push :drweb
			end
			return result
		end

		def self.revise_by_type(ip_addr, type)
			case type
				when :mcafee
					url = "http://www.siteadvisor.com/sites/#{ip_addr}"
					uri = URI(url)
					res = Net::HTTP.get_response(uri)
					if res.body.include? "This link might be dangerous"
						return false
					end
				when :drweb
					url = "http://online.us.drweb.com/result"
					uri = URI(url)
					error = false
					begin
						res = Net::HTTP.post_form(uri, 'url' => ip_addr)
						rescue Timeout::Error => e
							error = true
					end
					if error === false and res.body.include? "is in Dr.Web malicious sites list"							
						return false
					end
					
			end
			return true	
		end
	end
end	
require 'ipaddr'
require 'net/http'
require "resolv"
require "url"


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

		Struct.new("IPCheckResult", :ip, :url, :isClean, :type)
		def self.revise(ip_addr)			
			array = []
			array.push revise_by_type(ip_addr, :mcafee);
			array.push revise_by_type(ip_addr, :drweb)
			array.push revise_by_type(ip_addr, :sbl)
			return array
		end

		
		def self.revise_by_type(ip_addr, type)
			url = ""
			isClean = true
			case type
				when :mcafee
					url = "http://www.siteadvisor.com/sites/#{ip_addr}"
					uri = URI(url)
					res = Net::HTTP.get_response(uri)
					if res.body.include? "This link might be dangerous"
						isClean = false
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
						isClean = false
					end	
				when :sbl
					host = ip_addr.to_s.split(".").reverse.join(".")
					url = "#{host}.sbl-xbl.spamhaus.org"
					answer = dns_resolv(url)
					if (answer == '127.0.0.2')
						isClean = false
					end
			end
			return Struct::IPCheckResult.new(ip_addr.to_s, url, isClean, type)
		end

		def self.dns_resolv(name)
        begin
          dns = Resolv::DNS.new
          result = dns.getresources(name, Resolv::DNS::Resource::IN::A)
          return (result.size > 0 ? result.first.address.to_s : nil)
        rescue Resolv::ResolvError => e
          return :error
        end

      end
	end
end	
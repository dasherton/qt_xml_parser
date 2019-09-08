#
#
#

require_relative 'xml_dom_reader'
require_relative 'xml_stream_reader'

module XmlReaderFactory
	def self.for(type)
		case type
		when :dom
			XmlDomReader
		when :stream_reader
			XmlStreamReader
		else
			nil
		end
	end
end

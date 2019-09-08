#
#
#

require 'qt'

require_relative 'xml_reader_factory'

reader_type = :stream_reader
filename = 'bookindex.xml'

app = Qt::Application.new(ARGV)

w = Qt::TreeWidget.new
w.setColumnCount(2)
w.setHeaderLabels %w{Term Page(s)}
w.show

reader_klass = XmlReaderFactory.for(reader_type)
raise RuntimeError.new("Cannot create reader for type: #{reader_type}") unless reader_klass

reader = reader_klass.new(tree_widget: w)

if( !reader.read_file(filename) )
	puts "Error: Cannot read #{filename}"
	exit
end

app.exec

#
#
#

require_relative 'defaults'

class XmlStreamReader
	attr_reader :reader, :tree_widget

	def initialize(tree_widget:)
		@reader = Qt::XmlStreamReader.new 
		@tree_widget = tree_widget
	end

	def read_file(filename)
		file = Qt::File.new(filename)
		return false unless file.open(Qt::File::ReadOnly|Qt::File::Text)

		set_reader_device(file)
		parse
		file.close

		if reader_error?
			puts reader.errorString
			return false
		end

		return false if file.error != Qt::File::NoError
		return true
	end

	private

	def parse
		advance_reader

		while !finished?
			if start_element?
				if current_token_name == 'bookindex'
					read_bookindex_element
				else
					raise_error('Not a bookindex file')
				end
			else
				advance_reader
			end
		end
	end

	def read_bookindex_element
		advance_reader

		while !finished?
			if end_element?
				advance_reader
				break
			end

			if start_element?
				if current_token_name == Tokens::ENTRY
					read_entry_element(root_item)
				else
					skip_unknown_element
				end
			else
				advance_reader
			end
		end
	end

	def read_entry_element(parent)
		item = Qt::TreeWidgetItem.new(parent)
		item.setText(Defaults::TERM_COLUMN, get_attribute(Tokens::TERM))

		advance_reader

		while !finished?
			if end_element?
				advance_reader
				break
			end

			if start_element?
				case current_token_name
				when Tokens::ENTRY
					read_entry_element(item)
				when Tokens::PAGE
					read_page_element(item)
				else
					skip_unknown_element
				end
			else
				advance_reader
			end
		end
	end

	def read_page_element(parent)
		page = read_element_text
		advance_reader if end_element?

		all_pages = parent.text(Defaults::PAGES_COLUMN) || ''
		all_pages += ', ' unless all_pages.empty?
		all_pages += page

		parent.setText(Defaults::PAGES_COLUMN, all_pages)
	end

	def skip_unknown_element
		advance_reader

		while !finished?
			if end_element?
				advance_reader
				break
			end

			if start_element?
				skip_unknown_element
			else
				advance_reader
			end
		end
	end

	def set_reader_device(device)
		reader.setDevice(device)
	end

	def advance_reader
		reader.readNext
	end

	def finished?
		reader.atEnd
	end

	def start_element?
		reader.isStartElement
	end

	def end_element?
		reader.isEndElement
	end

	def current_token_name
		reader.name.toString
	end

	def reader_error?
		reader.hasError
	end

	def root_item
		tree_widget.invisibleRootItem
	end

	def get_attribute(attr)
		reader.attributes.value(attr).toString
	end

	def read_element_text
		reader.readElementText
	end

	def raise_error(error)
		reader.raise_error(error) # reader.atEnd will return true, error can be queried through QFile
	end
end

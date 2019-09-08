#
#
#

class XmlDomReader
	attr_reader :tree_widget

	def initialize(tree_widget:)
		@tree_widget = tree_widget
	end

	def read_file(filename)
		file = Qt::File.new(filename)
		return false unless file.open(Qt::File::ReadOnly|Qt::File::Text)

		error_string = ''
		error_line = 0
		error_column = 0

		doc = Qt::DomDocument.new

		return false unless doc.setContent(file, false, error_string, error_line, error_column)

		root = doc.documentElement
		return false if root.tagName != 'bookindex'

		parse_bookindex_element(root)
		return true
	end

	private

	def parse_bookindex_element(element)
		child = element.firstChild

		while !child.isNull
			if child.toElement.tagName == 'entry'
				parse_entry_element(child.toElement, root_item)
			end

			child = child.nextSibling
		end
	end

	def parse_entry_element(element, parent_item)
		item = Qt::TreeWidgetItem.new(parent_item)
		item.setText(Defaults::TERM_COLUMN, element.attribute(Tokens::TERM))

		child = element.firstChild

		while !child.isNull
			if child.toElement.tagName == Tokens::ENTRY
				parse_entry_element(child.toElement, item)
			elsif child.toElement.tagName == Tokens::PAGE
				parse_page_element(child.toElement, item)
			end

			child = child.nextSibling
		end
	end

	def parse_page_element(element, parent_item)
		page = element.text		
		all_pages = parent_item.text(Defaults::PAGES_COLUMN) || ''

		all_pages += ', ' unless all_pages.empty?
		all_pages += page

		parent_item.setText(Defaults::PAGES_COLUMN, all_pages)
	end

	def root_item
		tree_widget.invisibleRootItem
	end

end

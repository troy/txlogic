module Dom
  class Alert < Domino
    selector 'h2'

    def title
      node.text.sub /^Alert: /, ''
    end

    def self.find_by_title(value)
      detect {|node| node.title == value }
    end
  end
end

module Dom
  class Member < Domino
    selector  'table tbody tr'

    def email
      attribute('td:first').strip
    end

    def self.find_by_email(value)
      detect {|node| node.email == value }
    end
  end
end

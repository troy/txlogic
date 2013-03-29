class RuoteUtilities
  # "60s" => 60
  # "3h" => 10800
  def self.timeout_in_seconds(english_timeout)
    timeout_matches = english_timeout.match(/^(\d+)(\w)$/)

    # invalid or multiple units like 1w2d3m
    return unless timeout_matches && timeout_matches.length == 3 && timeout_matches[1].to_i > 1
    
    case timeout_matches[2].downcase
    when 's'
      return timeout_matches[1].to_i
    when 'm'
      return timeout_matches[1].to_i*60
    when 'h'
      return timeout_matches[1].to_i*60*60
    end
  end
end
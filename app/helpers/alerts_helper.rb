module AlertsHelper
  def email_alias_link(process_definition)
    email_alias = "alert-#{process_definition.launch_alias}@txlogic.mailgun.org"
    link_to 'Email alias', "mailto:#{email_alias}"
  end

  def http_alias_link(process_definition)
    link_to 'HTTP URL', launch_path(:id => process_definition.launch_alias)
  end
  
  def date_based_on_age(t)
    return unless t
    
    exact_time = t.strftime('%B %e, %l:%m %p %Z')
    relative_time = time_ago_in_words(t).sub('about ', '') + ' ago'
    
    if t > 1.day.ago
      content_tag(:span, relative_time, :title => exact_time)
    else
      content_tag(:span, exact_time, :title => relative_time)
    end
  end

  def format_recipient(recipient, short_format = true)
    if recipient =~ /@/ && short_format
      recipient.split('@').first
    elsif recipient =~ /^\+1/
      PhoneNumber.new(recipient).to_us_number('-')
    else
      recipient
    end
  end
  
  def format_delivery_recipient(delivery, short_format = true)
    "#{format_recipient(delivery.recipient, short_format)} (#{delivery.formatted_delivery_method})"
  end
end

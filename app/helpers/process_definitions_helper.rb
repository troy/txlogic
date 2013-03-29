module ProcessDefinitionsHelper
  def default_markup
    """
process_definition do
  concurrence :timeout => '2m' do
    participant 'im alfonso',  :recipient => 'alfonso@example.com', :using => 'jabber'
    participant 'im sally', :recipient => 'sally79', :using => 'yahoo'
  end

  participant 'email ops', :recipient => 'ops@example.com', :timeout => '5m'

  concurrence :timeout => '5m' do
    participant 'sms alfonso', :recipient => '2065551234'
    participant 'call ops on-call phone', :recipient => '5125553210'
  end
  
  participant 'call developer', :recipient => '4155556789',
    :timeout => '2m', :if => '${hour} > 9 && ${hour} < 18'
  participant 'call ceo', :recipient => '2125554400', :if => '${weekday} && ${daytime}'
end
"""
  end
end
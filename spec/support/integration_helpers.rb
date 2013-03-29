module IntegrationHelpers
  def sign_in_with_email(email)
    visit '/users/sign_in'
    fill_in 'Email',    with: email
    fill_in 'Password', with: 'towel42'
    click_button 'Sign in'
  end

  def path_to(name, options={})
    case name
    when :home
      '/'
    when :sign_in
      '/users/sign_in'
    when :alert_delivery
      "/a/#{ options.fetch :slug }"
    when :members
      '/members'
    else
      raise "Can't find path to #{ name.inspect }. LOL @ U"
    end
  end
end

RSpec.configure do |config|
  config.include IntegrationHelpers, type: :request
end

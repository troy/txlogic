module ControllerSpecHelpers
  def controller
    subject
  end

  def call_action(action, params={})
    controller.stub!(params: params)
    controller.public_send(action)
  end

  def session
    @session ||= {}
  end

  def flash
    @flash ||= {}
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.include ControllerSpecHelpers, controller: true
  config.before :each, controller: true do
    controller.stub! session: session, flash: flash
  end
end

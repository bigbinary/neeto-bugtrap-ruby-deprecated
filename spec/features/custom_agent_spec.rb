# frozen_string_literal: true

feature 'Creating a custom agent' do
  let(:crash_cmd) { "ruby #{FIXTURES_PATH.join('ruby_custom.rb')}" }

  it 'reports the exception to NeetoBugtrap' do
    expect(run_command(crash_cmd)).not_to be_successfully_executed
    assert_notification('error' => { 'class' => 'CustomNeetoBugtrapException', 'message' => 'Test message' })
  end
end

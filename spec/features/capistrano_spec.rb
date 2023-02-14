# frozen_string_literal: true

feature 'capistrano task' do
  before do
    FileUtils.cp(FIXTURES_PATH.join('Capfile'), current_dir)
  end

  it 'outputs the neetobugtrap task' do
    expect(run_command('bundle exec cap -T')).to be_successfully_executed
    expect(all_output).to match(/neetobugtrap:deploy/i)
  end
end

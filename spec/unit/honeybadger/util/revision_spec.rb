require 'neeto-bugtrap-ruby/util/revision'

describe NeetoBugtrapRuby::Util::Revision do
  after do
    ENV.delete('HEROKU_SLUG_COMMIT')
  end

  it "detects capistrano revision" do
    root = FIXTURES_PATH.to_s
    expect(NeetoBugtrapRuby::Util::Revision.detect(root)).to eq('rspec testing')
  end

  it "detects git revision" do
    expect(NeetoBugtrapRuby::Util::Revision.detect).to eq(`git rev-parse HEAD`.strip)
  end

  it "detects heroku revision" do
    ENV['HEROKU_SLUG_COMMIT'] = 'heroku revision'
    expect(NeetoBugtrapRuby::Util::Revision.detect).to eq('heroku revision')
  end

  it "returns nil when detected value is a blank string" do
    allow(NeetoBugtrapRuby::Util::Revision).to receive(:from_git).and_return(" ")
    expect(NeetoBugtrapRuby::Util::Revision.detect).to eq(nil)
  end

  it "returns nil when detected value is nil" do
    allow(NeetoBugtrapRuby::Util::Revision).to receive(:from_git).and_return(nil)
    expect(NeetoBugtrapRuby::Util::Revision.detect).to eq(nil)
  end
end

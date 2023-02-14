# frozen_string_literal: true

require_relative '../rails_helper'

RAILS_ERROR_SOURCE_SUPPORTED = defined?(::Rails::VERSION) && ::Rails::VERSION::STRING >= '7.1'

describe 'Rails error subscriber integration', if: defined?(::ActiveSupport::ErrorReporter) do
  load_rails_hooks(self)

  it 'reports exceptions' do
    NeetoBugtrap.flush do
      Rails.error.handle(severity: :warning, context: { key: 'value' }) do
        raise 'Oh no'
      end
    end

    expect(NeetoBugtrap::Backend::Test.notifications[:notices].size).to eq(1)
    notice = NeetoBugtrap::Backend::Test.notifications[:notices].first
    expect(notice.error_class).to eq('RuntimeError')
    expect(notice.context).to eq({ key: 'value' })
    expect(notice.tags).to eq(['severity:warning', 'handled:true'])
  end

  it 'does not report exceptions again if they have already been handled by the subscriber' do
    expect do
      NeetoBugtrap.flush do
        Rails.error.record(context: { key: 'value' }) { raise 'Oh no' }
      rescue StandardError => e
        NeetoBugtrap.notify(e)
        raise
      end
    end.to raise_error(RuntimeError, 'Oh no')

    expect(NeetoBugtrap::Backend::Test.notifications[:notices].size).to eq(1)
    notice = NeetoBugtrap::Backend::Test.notifications[:notices].first
    expect(notice.error_class).to eq('RuntimeError')
    expect(notice.context).to eq({ key: 'value' })
    expect(notice.tags).to eq(['severity:error', 'handled:false'])
  end

  it 'reports exceptions with source', if: RAILS_ERROR_SOURCE_SUPPORTED do
    NeetoBugtrap.flush do
      Rails.error.handle(severity: :warning, context: { key: 'value' }, source: 'task') do
        raise 'Oh no'
      end
    end

    expect(NeetoBugtrap::Backend::Test.notifications[:notices].size).to eq(1)
    notice = NeetoBugtrap::Backend::Test.notifications[:notices].first
    expect(notice.error_class).to eq('RuntimeError')
    expect(notice.context).to eq({ key: 'value' })
    expect(notice.tags).to eq(['severity:warning', 'handled:true', 'source:task'])
  end

  it "doesn't report errors from ignored sources", if: RAILS_ERROR_SOURCE_SUPPORTED do
    NeetoBugtrap.configure do |config|
      config.rails.subscriber_ignore_sources += [/ignored/]
    end

    NeetoBugtrap.flush do
      Rails.error.handle(severity: :warning, context: { key: 'value' }, source: 'ignored_source') do
        raise 'Oh no'
      end
    end

    expect(NeetoBugtrap::Backend::Test.notifications[:notices]).to be_empty
  end
end

# frozen_string_literal: true

require 'neeto-bugtrap-ruby/util/sql'

describe NeetoBugtrap::Util::SQL do
  describe '#obfuscate' do
    it 'works with non UTF-8 strings' do
      expect do
        described_class.obfuscate(
          "SELECT AES_DECRYPT('\x83ݔj\\\xE3Lb\u0001\\\xEC\u0010&\u000F[\\\xE6`q', 'key')",
          'sqlite3'
        )
      end.to_not raise_error
    end
  end
end

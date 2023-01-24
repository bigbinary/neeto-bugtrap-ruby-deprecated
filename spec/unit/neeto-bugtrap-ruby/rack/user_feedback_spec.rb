require 'neeto-bugtrap-ruby/rack/user_feedback'
require 'neeto-bugtrap-ruby/config'

describe NeetoBugtrap::Rack::UserFeedback do
  let(:agent) { NeetoBugtrap::Agent.new }
  let(:config) { agent.config }
  let(:main_app) do
    lambda do |env|
      env['neetobugtrap.error_id'] = neetobugtrap_id if defined?(neetobugtrap_id)
      [200, {}, ["<!-- NEETOBUGTRAP FEEDBACK -->"]]
    end
  end
  let(:informer_app) { NeetoBugtrap::Rack::UserFeedback.new(main_app, agent) }
  let(:result) { informer_app.call({}) }

  context "there is a neetobugtrap id" do
    let(:neetobugtrap_id) { 1 }

    it "modifies output" do
      rendered_length = informer_app.render_form(1).size
      expect(result[2][0]).to match(/neetobugtrap_feedback_token/)
      expect(result[1]["Content-Length"].to_i).to eq rendered_length
    end

    context "a project root is configured" do
      let(:tmp_dir) { TMP_DIR }
      let(:template_dir) { File.join(tmp_dir, 'lib', 'neetobugtrap', 'templates') }
      let(:template_file) { File.join(template_dir, 'feedback_form.erb') }

      before do
        FileUtils.mkdir_p(template_dir)
        FileUtils.rm_f(template_file)
        config[:root] = tmp_dir
      end

      context "custom template is implemented" do
        before do
          File.open(template_file, 'w') { |f| f.write 'custom feedback form' }
        end

        it "renders with custom template" do
          expect(result[2][0]).to match(/custom feedback form/)
        end
      end
    end
  end

  context "there is no neetobugtrap id" do
    it "does not modify the output" do
      expect(result[2][0]).to eq '<!-- NEETOBUGTRAP FEEDBACK -->'
    end
  end
end

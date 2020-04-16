RSpec.describe CoronavirusFormMailer, type: :mailer do
  describe "#thank_you" do
    let(:mail) { CoronavirusFormMailer.with(params).thank_you(to_address) }
    let(:to_address) { "user@example.org" }
    let(:params) { { name: "Harry Potter" } }

    it "renders the headers" do
      expect(mail.subject).to eq("You offered coronavirus support from your business")
      expect(mail.to).to eq([to_address])
      expect(mail.from).to eq(["test@example.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Dear #{params.dig(:name)}")
    end
  end
end

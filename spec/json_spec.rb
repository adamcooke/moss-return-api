require 'moss_return_api/json'

describe MOSSReturnAPI::JSON do

  context "valid json" do
    subject do
      json = File.read(File.expand_path('../../examples/valid.json', __FILE__))
      MOSSReturnAPI::JSON.new(json)
    end

    it "should be valid JSON" do
      expect(subject.valid_json?).to eq(true)
    end

    it "should be valid data" do
      expect(subject.valid_data?).to eq(true)
    end

    it "should create a return" do
      rtn = subject.to_return
      expect(rtn.class).to eq(HMRCMOSS::Return)
      expect(rtn.period).to eq('Q1/2015')
      expect(rtn.supplies_from_uk.size).to eq(2)
      expect(rtn.supplies_from_outside_uk.size).to eq(1)
    end

    it "should create a return with appropriate UK supply lines" do
      line = subject.to_return.supplies_from_uk.first
      expect(line.country).to eq('FR')
      expect(line.rate_type).to eq('standard')
      expect(line.rate).to eq('20.00')
      expect(line.total_sales).to eq('2000.00')
      expect(line.vat_due).to eq('10.00')
    end
  end

  context "invalid json (missing period)" do
    subject do
      json = File.read(File.expand_path('../../examples/missing_period.json', __FILE__))
      MOSSReturnAPI::JSON.new(json)
    end

    it "should be valid JSON" do
      expect(subject.valid_json?).to eq(true)
    end

    it "should not be valid MOSS" do
      expect(subject.valid_data?).to eq(false)
      expect(subject.validate).to include('missing-period')
    end
  end

  context "invalid json (missing lines)" do
    subject do
      json = File.read(File.expand_path('../../examples/no_lines.json', __FILE__))
      MOSSReturnAPI::JSON.new(json)
    end

    it "should be valid JSON" do
      expect(subject.valid_json?).to eq(true)
    end

    it "should not be valid MOSS" do
      expect(subject.valid_data?).to eq(false)
      expect(subject.validate).to include('no-lines')
    end
  end

  context "invalid json (invalid lines)" do
    subject do
      json = File.read(File.expand_path('../../examples/invalid_lines.json', __FILE__))
      MOSSReturnAPI::JSON.new(json)
    end

    it "should be valid JSON" do
      expect(subject.valid_json?).to eq(true)
    end

    it "should not be valid MOSS" do
      expect(subject.valid_data?).to eq(false)
      expect(subject.validate).to include('invalid-lines-uk')
      expect(subject.validate).to include('invalid-lines-non_uk')
    end
  end

end

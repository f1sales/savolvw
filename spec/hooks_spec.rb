require 'ostruct'
require 'byebug'

RSpec.describe F1SalesCustom::Hooks::Lead do
  context 'when product cotains PCD' do
    let(:source) do
      source = OpenStruct.new
      source.name = 'Facebook - Savol Volkswagen'
      source
    end

    let(:product) do
      product = OpenStruct.new
      product.name = 'PcD - Outubro21'

      product
    end

    let(:lead) do
      lead = OpenStruct.new
      lead.source = source
      lead.product = product

      lead
    end

    it 'returns source name' do
      expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen - PcD - Outubro21')
    end
  end
end

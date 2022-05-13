require 'ostruct'
require 'byebug'

RSpec.describe F1SalesCustom::Hooks::Lead do
  context 'when product cotains PCD' do
    let(:source) do
      source = OpenStruct.new
      source.name = 'Facebook - Savol Volkswagen'
      source
    end

    let(:lead) do
      lead = OpenStruct.new
      lead.source = source
      lead.product = product

      lead
    end

    context 'when product contains PcD' do
      let(:product) do
        product = OpenStruct.new
        product.name = 'PcD'

        product
      end

      it 'returns source name' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen - PCD')
      end
    end

    context 'when product contains Frotista' do
      let(:product) do
        product = OpenStruct.new
        product.name = 'Frotista'

        product
      end

      it 'returns source name' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen - Frotista')
      end
    end

    context 'when product contains Frotista' do
      let(:product) do
        product = OpenStruct.new
        product.name = 'RE9 T-Cross Sense Vídeo - Maio22 (Facebook)'

        product
      end

      it 'returns source name' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen - RE9')
      end
    end
  end
end

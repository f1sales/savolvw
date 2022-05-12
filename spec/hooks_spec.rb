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

    context 'when product contains Pós-venda' do
      let(:product) do
        product = OpenStruct.new
        product.name = 'Pós-venda: Pneu - Maio22 (Instagram)'

        product
      end

      it 'returns source name' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen - Pós Vendas')
      end
    end

    context 'when product is common' do
      let(:product) do
        product = OpenStruct.new
        product.name = 'Pneu - Maio22 (Instagram)'

        product
      end

      it 'returns source name' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen')
      end
    end
  end
end

require 'ostruct'

RSpec.describe F1SalesCustom::Hooks::Lead do
  context 'when product cotains information' do
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

    let(:product) do
      product = OpenStruct.new
      product.name = 'Pneu - Maio22 (Instagram)'

      product
    end

    context 'when product is common' do
      it 'returns source name' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen')
      end
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
      
    context 'when product contains RE9' do
      let(:product) do
        product = OpenStruct.new
        product.name = 'RE9 T-Cross Sense Vídeo - Maio22 (Facebook)'

        product
      end
      
      it 'return source name with RE9' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen - RE9')
      end
    end
  end

  context 'when leads come from Landing Page' do
    let(:lead) do
      lead = OpenStruct.new
      lead.source = source
      lead.description = 'Campanha Kinto - SBC - Yaris'

      lead
    end

    let(:source) do
      source = OpenStruct.new
      source.name = 'Facebook'

      source
    end

    it 'when lead come to SBC' do
      expect(described_class.switch_source(lead)).to eq('Facebook - SBC')
    end

    context 'when leads come to Praia Grande' do
      before { lead.description = 'Campanha Kinto - Praia Grande - Yaris' }

      it 'when come to Praia Grande' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Praia Grande')
      end
    end

    context 'when leads come to Santo André' do
      before { lead.description = 'Campanha Kinto - Santo André - Yaris' }

      it 'when come to Santo André' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Santo André')
      end
    end
  end

  context 'when leads come from RD Station' do
    let(:lead) do
      lead = OpenStruct.new
      lead.source = source
      lead.message = 'SA'

      lead
    end

    let(:source) do
      source = OpenStruct.new
      source.name = 'RD Station'

      source
    end

    it 'Lead go to Santo Amaro' do
      expect(described_class.switch_source(lead)).to eq('RD Station - Santo André')
    end

    context 'when leads has PG in the message' do
      before { lead.message = 'PG' }

      it 'goes to Praia Grande' do
        expect(described_class.switch_source(lead)).to eq('RD Station - Praia Grande')
      end
    end

    context 'when leads has SBC in the message' do
      before { lead.message = 'SBC' }
      
      it 'goes to SBC' do
        expect(described_class.switch_source(lead)).to eq('RD Station - SBC')
      end
    end

    context 'when leads message come empty' do
      before { lead.message = '' }
      
      it 'return source name' do
        expect(described_class.switch_source(lead)).to eq('RD Station')
      end
    end
  end
end

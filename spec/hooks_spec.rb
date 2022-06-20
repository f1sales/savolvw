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
      before do
        product.name = 'PcD'
      end

      it 'returns source name' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen - PCD')
      end
    end

    context 'when product contains Frotista' do
      before do
        product.name = 'Frotista'
      end

      it 'returns source name' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen - Frotista')
      end
    end

    context 'when product contains Pós-venda' do
      before do
        product.name = 'Pós-venda: Pneu - Maio22 (Instagram)'
      end
      
      it 'returns source name' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen - Pós Vendas')
      end
    end
      
    context 'when product contains RE9' do
      before do
        product.name = 'RE9 T-Cross Sense Vídeo - Maio22 (Facebook)'
      end
      
      it 'return source name with RE9' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen - RE9')
      end
    end

    context 'when product contains KINTO' do
      before do
        product.name = 'KINTO'
      end

      it 'return source name with KINTO' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen - KINTO')
      end
    end

    context 'when product contains FLUA' do
      before do
        product.name = 'FLUA'
      end

      it 'return source name with FLUA' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen - FLUA')
      end
    end

    context 'when product contains Frota' do
      before do
        product.name = 'Frota - Vídeo'
      end

      it 'return source name with FLUA' do
        expect(described_class.switch_source(lead)).to eq('Facebook - Savol Volkswagen - Frota')
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

    context 'when leads has SA in the message' do
      context 'when store id is savolpraia' do
        before do
          stub_const('ENV', 'STORE_ID' => 'savoltoyotapraia')
        end

        it 'returns nil' do
          expect(described_class.switch_source(lead)).to be_nil
        end
      end

      context 'when store id is savoltoyota' do
        before do
          stub_const('ENV', 'STORE_ID' => 'savoltoyota')
        end
        
        it 'goes to SBC' do
          expect(described_class.switch_source(lead)).to eq('RD Station - Santo André')
        end
      end
    end

    context 'when leads has PG in the message' do
      context 'when current store is savoltoyotapraia' do
        before do 
          lead.message = 'PG'
          stub_const('ENV', 'STORE_ID' => 'savoltoyotapraia')
        end

        it 'goes to Praia Grande' do
          expect(described_class.switch_source(lead)).to eq('RD Station - Praia Grande')
        end
      end

      context "when is not savol toyota praia " do
        before do 
          lead.message = 'PG'
          stub_const('ENV', 'STORE_ID' => 'savoltoyota')
        end

        it 'returns nil' do
          expect(described_class.switch_source(lead)).to be_nil
        end
      end
    end

    context 'when leads has SBC in the message' do
      context 'when store id is savolpraia' do
        before do 
          lead.message = 'SBC'
          stub_const('ENV', 'STORE_ID' => 'savoltoyotapraia')
        end

        it 'returns nil' do
          expect(described_class.switch_source(lead)).to be_nil
        end
      end

      context 'when store id is savoltoyota' do
      
        before do 
          lead.message = 'SBC'
          stub_const('ENV', 'STORE_ID' => 'savoltoyota')
        end
        
        it 'goes to SBC' do
          expect(described_class.switch_source(lead)).to eq('RD Station - SBC')
        end
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

require 'ostruct'
require 'byebug'

RSpec.describe F1SalesCustom::Hooks::Lead do
  context 'when source is from Facebook' do
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

    let(:switch_source) { described_class.switch_source(lead) }

    context 'when product is common' do
      it 'returns source name' do
        expect(switch_source).to eq('Facebook - Savol Volkswagen')
      end
    end

    context 'when product contains PcD' do
      before { product.name = 'PcD' }

      it 'returns source name' do
        expect(switch_source).to eq('Facebook - Savol Volkswagen - PCD')
      end
    end

    context 'when product contains Frotista' do
      before { product.name = 'Frotista' }

      it 'returns source name' do
        expect(switch_source).to eq('Facebook - Savol Volkswagen - Frotista')
      end
    end

    context 'when product contains Pós-venda' do
      before { product.name = 'Pós-venda: Pneu - Maio22 (Instagram)' }

      it 'returns source name' do
        expect(switch_source).to eq('Facebook - Savol Volkswagen - Pós Vendas')
      end
    end

    context 'when product contains RE9' do
      before { product.name = 'RE9 T-Cross Sense Vídeo - Maio22 (Facebook)' }

      it 'return source name with RE9' do
        expect(switch_source).to eq('Facebook - Savol Volkswagen - RE9')
      end
    end

    context 'when product contains KINTO' do
      before { product.name = 'KINTO' }

      it 'return source name with KINTO' do
        expect(switch_source).to eq('Facebook - Savol Volkswagen - KINTO')
      end
    end

    context 'when product contains FLUA' do
      before { product.name = 'FLUA' }

      it 'return source name with FLUA' do
        expect(switch_source).to eq('Facebook - Savol Volkswagen - FLUA')
      end
    end

    context 'when product contains Frota' do
      before { product.name = 'Frota - Vídeo' }

      it 'return source name with FLUA' do
        expect(switch_source).to eq('Facebook - Savol Volkswagen - Frota')
      end
    end

    context 'when product contains saveiro - cnpj' do
      before { product.name = 'Saveiro - CNPJ' }

      it 'return source name with FLUA' do
        expect(switch_source).to eq('Facebook - Savol Volkswagen - Frota')
      end
    end

    context 'when product contains t-cross - cnpj' do
      before { product.name = 'T-Cross - CNPJ' }

      it 'return source name with FLUA' do
        expect(switch_source).to eq('Facebook - Savol Volkswagen - Frota')
      end
    end

    context 'when product contains taos - cnpj' do
      before { product.name = 'Taos - CNPJ' }

      it 'return source name with FLUA' do
        expect(switch_source).to eq('Facebook - Savol Volkswagen - Frota')
      end
    end

    context 'when product contains saveiro robust - cnpj' do
      before { product.name = 'Saveiro Robust - CNPJ' }

      it 'return source name with FLUA' do
        expect(switch_source).to eq('Facebook - Savol Volkswagen - Frota')
      end
    end

    context 'when product contains nivus - taxista' do
      before { product.name = 'Nivus - Taxista' }

      it 'return source name with FLUA' do
        expect(switch_source).to eq('Facebook - Savol Volkswagen - Frota')
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

    let(:switch_source) { described_class.switch_source(lead) }

    it 'when lead come to SBC' do
      expect(switch_source).to eq('Facebook - SBC')
    end

    context 'when leads come to Praia Grande' do
      before { lead.description = 'Campanha Kinto - Praia Grande - Yaris' }

      it 'when come to Praia Grande' do
        expect(switch_source).to eq('Facebook - Praia Grande')
      end
    end

    context 'when leads come to Santo André' do
      before { lead.description = 'Campanha Kinto - Santo André - Yaris' }

      it 'when come to Santo André' do
        expect(switch_source).to eq('Facebook - Santo André')
      end
    end
  end

  context 'when leads come from RD Station' do
    let(:lead) do
      lead = OpenStruct.new
      lead.source = source
      lead.message = 'Tags: . Loja: SA. Produto: branding. Origem: google. Campanha: savol-sa'

      lead
    end

    let(:source) do
      source = OpenStruct.new
      source.name = 'RD Station'

      source
    end

    let(:switch_source) { described_class.switch_source(lead) }

    context 'when leads has SA in the message' do
      context 'when store id is savolpraia' do
        before do
          stub_const('ENV', 'STORE_ID' => 'savoltoyotapraia')
        end

        it 'returns nil' do
          expect(switch_source).to be_nil
        end
      end

      context 'when store id is savoltoyota' do
        before do
          stub_const('ENV', 'STORE_ID' => 'savoltoyota')
        end

        it 'goes to Santo André' do
          expect(switch_source).to eq('RD Station - Santo André - Google')
        end
      end
    end

    context 'when leads has PG in the message' do
      before { lead.message = 'Tags: . Loja: PG. Origem: facebook. Campanha: savol-pg. Produto: feed-grs-junina' }

      context 'when current store is savoltoyotapraia' do
        before do
          stub_const('ENV', 'STORE_ID' => 'savoltoyotapraia')
        end

        it 'goes to Praia Grande' do
          expect(switch_source).to eq('RD Station - Praia Grande - Facebook')
        end
      end

      context 'when is not savol toyota praia' do
        before do
          stub_const('ENV', 'STORE_ID' => 'savoltoyota')
        end

        it 'returns nil' do
          expect(switch_source).to be_nil
        end
      end
    end

    context 'when leads has SBC in the message' do
      before { lead.message = 'Tags: . Loja: SBC. Campanha: savol-sbc. Produto: feed-grs-junina. Origem: instagram' }

      context 'when store id is savolpraia' do
        before do
          stub_const('ENV', 'STORE_ID' => 'savoltoyotapraia')
        end

        it 'returns nil' do
          expect(switch_source).to be_nil
        end
      end

      context 'when store id is savoltoyota' do
        before do
          stub_const('ENV', 'STORE_ID' => 'savoltoyota')
        end

        it 'goes to SBC' do
          expect(switch_source).to eq('RD Station - SBC - Instagram')
        end

        context 'when message does not have origin in source' do
          before { lead.message = 'Tags: . Loja: SBC. Campanha: savol-sbc. Produto: feed-grs-junina. Origem: ' }

          it 'source doesnt have origin' do
            expect(switch_source).to eq('RD Station - SBC')
          end
        end
      end
    end

    context 'when leads message come empty' do
      before { lead.message = '' }

      it 'return source name' do
        expect(switch_source).to eq('RD Station')
      end
    end

    context 'when leads come with Oferta desejada: in message. PG' do
      before do
        lead.message = 'Tags: . Oferta desejada: Compra de pneus. Loja: PG'
        stub_const('ENV', 'STORE_ID' => 'savoltoyotapraia')
      end

      it 'return POS VENDA in source' do
        expect(switch_source).to eq('RD Station - Praia Grande - Pós Vendas')
      end
    end

    context 'when leads come with Oferta desejada: in message. SBC' do
      before do
        lead.message = 'Tags: . Oferta desejada: Compra de pneus. Loja: SBC'
        stub_const('ENV', 'STORE_ID' => 'savoltoyota')
      end

      it 'return POS VENDA in source' do
        expect(switch_source).to eq('RD Station - SBC - Pós Vendas')
      end
    end

    context 'when leads come with Oferta desejada: in message. SA' do
      before do
        lead.message = 'Tags: . Oferta desejada: Compra de pneus. Loja: SA'
        stub_const('ENV', 'STORE_ID' => 'savoltoyota')
      end

      it 'return POS VENDA in source' do
        expect(switch_source).to eq('RD Station - Santo André - Pós Vendas')
      end
    end
  end
end

require 'ostruct'
require 'f1sales_custom/parser'
require 'f1sales_custom/source'

RSpec.describe F1SalesCustom::Email::Parser do
  context 'when is from website to SBC' do
    let(:email) do
      email = OpenStruct.new
      email.to = [email: 'website@savolkia.f1sales.org']
      email.subject = 'Oferta / Estoque - Proposta'
      email.body = "!@\#{\n\"CidadeRevenda\":\"Savol Kia (São Bernardo do Campo)\",\n\"Veículo\":\"Sportage \",\n\"Placa\":\"OLL8751\",\n\"Preço\":\"R$ 69.900,00\",\n\"Nome\": \"Guilherme\",\n\"E-mail\": \"guilima@me.com\",\n\"Telefone\": 11998108688,\n\"Descricao\": \"Olá tenho Kia Cerato 2017 e tenho interesse na troca.\"\n}!@#"

      email
    end

    let(:parsed_email) { described_class.new(email).parse }

    it 'contains lead website a source name' do
      expect(parsed_email[:source][:name]).to eq(F1SalesCustom::Email::Source.all[0][:name])
    end

    it 'contains name' do
      expect(parsed_email[:customer][:name]).to eq('Guilherme')
    end

    it 'contains email' do
      expect(parsed_email[:customer][:email]).to eq('guilima@me.com')
    end

    it 'contains phone' do
      expect(parsed_email[:customer][:phone]).to eq('11998108688')
    end

    it 'contains message' do
      expect(parsed_email[:message]).to eq('Olá tenho Kia Cerato 2017 e tenho interesse na troca.')
    end

    it 'contains product' do
      expect(parsed_email[:product][:name]).to eq('Sportage OLL8751')
    end

    it 'contains description' do
      expect(parsed_email[:description]).to eq('Preço R$ 69.900,00')
    end
  end

  context 'when is from website to SavolVW - 0 Km' do
    let(:email) do
      email = OpenStruct.new
      email.to = [email: 'website@savolvw.f1sales.org']
      email.subject = '0KM Tiguan Allspace'
      email.body = "Veículo: *Tiguan Allspace*\n\nNome: Lead Teste 2\nE-mail: lead2@teste.com\nCPF: 987.987.663-62\nTelefone: (11) 973829173\nMensagem: Segundo lead teste"

      email
    end

    let(:parsed_email) { described_class.new(email).parse }

    it 'contains lead website a source name' do
      expect(parsed_email[:source][:name]).to eq(F1SalesCustom::Email::Source.all[1][:name])
    end

    it 'contains name' do
      expect(parsed_email[:customer][:name]).to eq('Lead Teste 2')
    end

    it 'contains email' do
      expect(parsed_email[:customer][:email]).to eq('lead2@teste.com')
    end

    it 'contains phone' do
      expect(parsed_email[:customer][:phone]).to eq('11973829173')
    end

    it 'contains message' do
      expect(parsed_email[:message]).to eq('Segundo lead teste')
    end

    it 'contains product' do
      expect(parsed_email[:product][:name]).to eq('Tiguan Allspace')
    end

    it 'contains description' do
      expect(parsed_email[:description]).to eq('')
    end
  end

  context 'when is from website to SavolVW - 0 Km' do
    let(:email) do
      email = OpenStruct.new
      email.to = [email: 'website@savolvw.f1sales.org']
      email.subject = '0KM Tiguan Allspace'
      email.body = "Veículo: Gol Nome: Teste Testonildo\nCPF: 306.872.790-11\nTelefone: 11987005148\nE-mail: teste@teste.com.br\nContatos adicionados: website@savolvw.f1sales.net,\nfabio.teixeira@savol.com.br, Thiago.palomaro@savol.com.br\nVeículo: Gol\nMensagem: Apenas um teste\n\n---\n\nDate: 6 de setembro de 2022\nTime: 11:00\nPage URL: https://savol.com.br/veiculos-0km/gol/\nUser Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36\n(KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36\nRemote IP: 177.9.4.141"

      email
    end

    let(:parsed_email) { described_class.new(email).parse }

    it 'contains lead website a source name' do
      expect(parsed_email[:source][:name]).to eq(F1SalesCustom::Email::Source.all[1][:name])
    end

    it 'contains name' do
      expect(parsed_email[:customer][:name]).to eq('Teste Testonildo')
    end

    it 'contains email' do
      expect(parsed_email[:customer][:email]).to eq('teste@teste.com.br')
    end

    it 'contains phone' do
      expect(parsed_email[:customer][:phone]).to eq('11987005148')
    end

    it 'contains message' do
      expect(parsed_email[:message]).to eq('Apenas um teste')
    end

    it 'contains product' do
      expect(parsed_email[:product][:name]).to eq('Gol')
    end

    it 'contains description' do
      expect(parsed_email[:description]).to eq('')
    end
  end

  context 'when is from website to SavolVW - pre owned' do
    let(:email) do
      email = OpenStruct.new
      email.to = [email: 'teste@lojateste.f1sales.net']
      email.subject = 'Notificação de contato sobre oferta'
      email.body = "Dados do cliente:\nNome: Cynthia \nTelefone: 43996611476 \nE-mail: cynthia@teste.com \nMensagem: TESTE F1 \nemail2: marcelo.santos@savol.com.br, fabiana.oliveira@savol.com.br, website@savolvw.f1sales.net \n\n--- \n\nDate: 12 de setembro de 2022 \nTime: 17:20 \nPage URL: https://savol.com.br/seminovos/volkswagen-spacecross-2/ \nUser Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36 "

      email
    end

    let(:parsed_email) { described_class.new(email).parse }

    it 'contains name' do
      expect(parsed_email[:customer][:name]).to eq('Cynthia')
    end

    it 'contains email' do
      expect(parsed_email[:customer][:email]).to eq('cynthia@teste.com')
    end

    it 'contains phone' do
      expect(parsed_email[:customer][:phone]).to eq('43996611476')
    end

    it 'contains source name' do
      expect(parsed_email[:source][:name]).to eq('Website')
    end

    it 'contains description' do
      expect(parsed_email[:description]).to eq('')
    end

    it 'contains product name' do
      expect(parsed_email[:product][:name]).to eq('')
    end
  end

  context 'when lead come from a Landing Page' do
    context 'when is to SBC' do
      let(:email) do
        email = OpenStruct.new
        email.to = [email: 'teste@lojateste.f1sales.net']
        email.subject = 'Notificação de contato sobre oferta'
        email.body = "INFORMAÇÕES DE CONTATO\n\n\n* Campanha:* Campanha Kinto - SBC - Yaris\n* Origem: * Facebook\n\n\n* Nome:* Teste F1 – nathanael\n* E-mail: * ads@ange360.com\n* Telefone: * +5511982582021\n* Modelo: * Strada Endurance\n\n\n\n\nATENÇÃO: Não responda este e-mail. Trata-se de uma mensagem informativa e\nautomática.\n\nAtenciosamente,\n<http://www.ange360.com.br>\n\nNada nesta mensagem tem a intenção de ser uma assinatura eletrônica a menos\nque uma declaração específica do contrário seja incluída.\nConfidencialidade: Esta mensagem é destinada somente à pessoa endereçada.\nPode conter material confidencial e/ou privilegiado. Qualquer revisão,\ntransmissão ou outro uso ou ação tomada por confiança é proibida e pode ser\nilegal. Se você recebeu esta mensagem por engano, entre em contato com o\nremetente e apague-a de seu computador."

        email
      end

      let(:parsed_email) { described_class.new(email).parse }

      it 'contains name' do
        expect(parsed_email[:customer][:name]).to eq('Teste F1 – nathanael')
      end

      it 'contains email' do
        expect(parsed_email[:customer][:email]).to eq('ads@ange360.com')
      end

      it 'contains phone' do
        expect(parsed_email[:customer][:phone]).to eq('5511982582021')
      end

      it 'contains source name' do
        expect(parsed_email[:source][:name]).to eq('Facebook')
      end

      it 'contains description' do
        expect(parsed_email[:description]).to eq('Campanha Kinto - SBC - Yaris')
      end

      it 'contains product name' do
        expect(parsed_email[:product][:name]).to eq('Strada Endurance')
      end
    end

    context 'when is to Praia Grande' do
      let(:email) do
        email = OpenStruct.new
        email.to = [email: 'teste@lojateste.f1sales.net']
        email.subject = 'Notificação de contato sobre oferta'
        email.body = "INFORMAÇÕES DE CONTATO\n\n\n\n*Campanha:*\n\nSavol Toyota - Praia Grande - Corolla Cross\n\n*Origem: *\n\nGoogle\n\n\n\n*Nome:*\n\nDonatello Splinter\n\n*E-mail: *\n\ndonatelo.splinter@live.com\n\n*Telefone: *\n\n+5516922301191\n\n\n\nATENÇÃO: Não responda este e-mail. Trata-se de uma mensagem informativa e\nautomática.\n\nAtenciosamente,\n[image: Imagem removida pelo remetente.] <http://www.ange360.com.br/>\n\nNada nesta mensagem tem a intenção de ser uma assinatura eletrônica a menos\nque uma declaração específica do contrário seja incluída.\nConfidencialidade: Esta mensagem é destinada somente à pessoa endereçada.\nPode conter material confidencial e/ou privilegiado. Qualquer revisão,\ntransmissão ou outro uso ou ação tomada por confiança é proibida e pode ser\nilegal. Se você recebeu esta mensagem por engano, entre em contato com o\nremetente e apague-a de seu computador."

        email
      end

      let(:parsed_email) { described_class.new(email).parse }

      it 'contains name' do
        expect(parsed_email[:customer][:name]).to eq('Donatello Splinter')
      end

      it 'contains email' do
        expect(parsed_email[:customer][:email]).to eq('donatelo.splinter@live.com')
      end

      it 'contains phone' do
        expect(parsed_email[:customer][:phone]).to eq('5516922301191')
      end

      it 'contains source name' do
        expect(parsed_email[:source][:name]).to eq('Google')
      end

      it 'contains description' do
        expect(parsed_email[:description]).to eq('Savol Toyota - Praia Grande - Corolla Cross')
      end

      it 'contains product name' do
        expect(parsed_email[:product][:name]).to eq('Corolla Cross')
      end
    end
  end
end

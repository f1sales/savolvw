require 'savolvw/version'
require 'f1sales_custom/parser'
require 'f1sales_custom/source'
require 'f1sales_custom/hooks'
require 'f1sales_helpers'
require 'json'

module Savolvw
  class Error < StandardError; end

  class F1SalesCustom::Email::Source
    def self.all
      [
        {
          email_id: 'website',
          name: 'Website'
        },
        {
          email_id: 'website',
          name: 'Website - Novos'
        }
      ]
    end
  end

  class F1SalesCustom::Email::Parser
    def parse
      parsed_email = JSON.parse(@email.body.gsub('!@#', '')) rescue nil

      if parsed_email.nil?
        parsed_email = @email.body.colons_to_hash(/(Telefone|Nome|Mensagem|E-mail|CPF|Campanha|Origem|ATENÇÃO).*?:/, false)
        source_name = parsed_email['origem'] || F1SalesCustom::Email::Source.all[1][:name]

        {
          source: {
            name: source_name
          },
          customer: {
            name: parsed_email['nome'],
            phone: parsed_email['telefone'].gsub(/[^0-9]/, ''),
            email: parsed_email['email']
          },
          product: {
            name: @email.subject
          },
          message: parsed_email['mensagem'],
          description: parsed_email['campanha']
        }
      else

        {
          source: {
            name: F1SalesCustom::Email::Source.all[0][:name]
          },
          customer: {
            name: parsed_email['Nome'],
            phone: parsed_email['Telefone'].to_s,
            email: parsed_email['E-mail']
          },
          product: { name: "#{parsed_email['Veículo'].strip} #{parsed_email['Placa']}" },
          message: parsed_email['Descricao'],
          description: "Preço #{parsed_email['Preço']}"
        }
      end
    end
  end

  class F1SalesCustom::Hooks::Lead
    def self.switch_source(lead)
      product_name = lead.product&.name || ''
      source_name = lead.source&.name || ''
      product_name_downcase = product_name.downcase
      description = lead.description&.downcase || ''
      message = lead.message&.downcase || ''

      if source_name.downcase.include?('rd station')
        origin = message.colons_to_hash(/(tags|loja|origem|produto|campanha).*?:/, false)['origem']
        origin_clean = origin&.gsub('.', '')&.capitalize
        origin_end = origin_clean&.empty? ? '' : " - #{origin_clean}"

        if message.include?('loja: sa')
          return if ENV['STORE_ID'] != 'savoltoyota'

          "#{source_name} - Santo André" + origin_end
        elsif message.include?('loja: pg')
          return if ENV['STORE_ID'] != 'savoltoyotapraia'

          "#{source_name} - Praia Grande" + origin_end
        elsif message.include?('loja: sbc')
          return if ENV['STORE_ID'] != 'savoltoyota'

          "#{source_name} - SBC" + origin_end
        else
          source_name
        end
      elsif product_name_downcase.include?('pcd')
        "#{source_name} - PCD"
      elsif product_name_downcase.include?('frotista')
        "#{source_name} - Frotista"
      elsif product_name_downcase.include?('pós-venda')
        "#{source_name} - Pós Vendas"
      elsif product_name_downcase.include?('re9')
        "#{source_name} - RE9"
      elsif product_name_downcase.include?('kinto')
        "#{source_name} - KINTO"
      elsif product_name_downcase.include?('flua')
        "#{source_name} - FLUA"
      elsif description.include?('sbc')
        "#{source_name} - SBC"
      elsif description.include?('praia grande')
        "#{source_name} - Praia Grande"
      elsif description.include?('santo andré')
        "#{source_name} - Santo André"
      elsif product_name_downcase.include?('frota')
        "#{source_name} - Frota"
      else
        source_name
      end
    end
  end
end

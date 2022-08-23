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
        parsed_email = @email.body.colons_to_hash(/(Telefone|Nome|Modelo|Mensagem|E-mail|CPF|Campanha|Origem|Veículo|ATENÇÃO).*?:/, false)
        @source_name = parsed_email['origem'] || F1SalesCustom::Email::Source.all[1][:name]

        {
          source: {
            name: @source_name
          },
          customer: {
            name: parsed_email['nome'],
            phone: parsed_email['telefone'].gsub(/[^0-9]/, ''),
            email: parsed_email['email']
          },
          product: {
            name: parsed_email['modelo'] || parsed_email['veculo']
          },
          message: parsed_email['mensagem'],
          description: parsed_email['campanha'] || ''
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
    class << self
      def switch_source(lead)
        @lead = lead
        @source_name = lead.source&.name || ''
        add_team_to_source
      end

      def product_name_down
        (@lead.product&.name || '').downcase
      end

      def description
        @lead.description&.downcase || ''
      end

      def message
        @lead.message&.downcase || ''
      end

      def add_team_to_source
        source_name_down = @source_name.downcase
        if source_name_down.include?('rd station')
          rd_station_origin
        elsif product_name_down['pcd']
          "#{@source_name} - PCD"
        elsif product_name_down['frotista']
          "#{@source_name} - Frotista"
        elsif product_name_down['pós-venda']
          "#{@source_name} - Pós Vendas"
        elsif product_name_down['re9']
          "#{@source_name} - RE9"
        elsif product_name_down['kinto']
          "#{@source_name} - KINTO"
        elsif product_name_down['flua']
          "#{@source_name} - FLUA"
        elsif description['sbc']
          "#{@source_name} - SBC"
        elsif description['praia grande']
          "#{@source_name} - Praia Grande"
        elsif description['santo andré']
          "#{@source_name} - Santo André"
        elsif source_name_down['facebook']
          frota_team
        else
          @source_name
        end
      end

      def rd_station_origin
        origin = message.colons_to_hash(/(tags|loja|origem|produto|campanha).*?:/, false)['origem']
        origin_clean = origin&.gsub('.', '')&.capitalize || ''
        @origin_end = origin_clean&.empty? ? '' : " - #{origin_clean}"
        @origin_end += ' - Pós Vendas' if message['oferta desejada:']
        choose_the_store
      end

      def choose_the_store
        if message.include?('loja: sa')
          return if ENV['STORE_ID'] != 'savoltoyota'

          "#{@source_name} - Santo André" + @origin_end
        elsif message.include?('loja: pg')
          return if ENV['STORE_ID'] != 'savoltoyotapraia'

          "#{@source_name} - Praia Grande" + @origin_end
        elsif message.include?('loja: sbc')
          return if ENV['STORE_ID'] != 'savoltoyota'

          "#{@source_name} - SBC" + @origin_end
        else
          @source_name
        end
      end

      def frota_team
        if array_product_name.detect { |prod| product_name_down.include?(prod) }
          "#{@source_name} - Frota"
        else
          @source_name
        end
      end

      def array_product_name
        ['frota', 'saveiro - cnpj', 't-cross - cnpj', 'taos - cnpj', 'saveiro robust - cnpj', 'nivus - taxista']
      end
    end
  end
end

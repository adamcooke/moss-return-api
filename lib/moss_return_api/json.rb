require 'json'
require 'hmrc_moss'

module MOSSReturnAPI
  class JSON

    def initialize(json)
      @json = json
    end

    def source_data
      ::JSON.parse(@json)
    rescue
      nil
    end

    def valid_json?
      source_data.is_a?(Hash)
    end

    def valid_data?
      validate.empty?
    end

    def validate
      Array.new.tap do |errors|
        unless source_data['period'].is_a?(String)
          errors << 'missing-period'
        end

        unless source_data['uk'].is_a?(Array) || source_data['non_uk'].is_a?(Array)
          errors << 'no-lines'
        end

        ['uk', 'non_uk'].each do |type|
          if source_data[type].is_a?(Array)
            unless source_data[type].all? { |s| s.is_a?(Hash) }
              errors << "invalid-lines-#{type}"
            end
          elsif source_data[type]
            errors << "invalid-lines-#{type}"
          end
        end
      end
    end

    def to_return
      r = HMRCMOSS::Return.new(source_data['period'])

      if source_data['uk'].is_a?(Array)
        source_data['uk'].each do |source_line|
          r.supplies_from_uk << HMRCMOSS::UKSupply.new(source_line['country'], symbolize_keys(source_line))
        end
      end

      if source_data['non_uk'].is_a?(Array)
        source_data['non_uk'].each do |source_line|
          r.supplies_from_outside_uk << HMRCMOSS::NonUKSupply.new(source_line['vat_number'], source_line['country'], symbolize_keys(source_line))
        end
      end
      r
    end

    private

    def symbolize_keys(hash)
      hash.inject({}) do |hash, (key, value)|
        hash[key.to_sym] = value.to_s
        hash
      end
    end

  end
end

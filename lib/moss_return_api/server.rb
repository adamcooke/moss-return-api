require 'tempfile'
require 'json'
require 'moss_return_api/json'
require 'rack/request'


module MOSSReturnAPI
  class Server

    def call(env)
      case env['PATH_INFO']
      when /\A\/\z/
        [200, {'Content-Type' => 'text/html', 'Content-Length' => welcome_html.bytesize.to_s}, [welcome_html]]

      when /\A\/generate\z/
        rack = Rack::Request.new(env)
        json = MOSSReturnAPI::JSON.new(rack.params['json'])
        unless json.valid_json?
          return [400, {'Content-Type' => 'application/json'}, [{:error => {:code => 'invalid-json', :message => "Invalid JSON data provided."}}.to_json]]
        end

        errors = json.validate
        unless errors.empty?
          return [400, {'Content-Type' => 'application/json'}, [{:error => {:code => 'invalid-data', :message => "Some of the data provided in your JSON was invalid.", :validation_errors => errors}}.to_json]]
        end

        rtn = json.to_return
        tempfile = Tempfile.new('return')
        rtn.ods_file.save(tempfile.path)
        headers = {}
        headers['Content-Type'] = 'application/vnd.oasis.opendocument.spreadsheet'
        headers['Content-Disposition'] = 'attachment; filename=MOSSReturn.ods'
        [200, headers, [File.read(tempfile.path)]]

      else
        [404, {}, ["Page not found."]]
      end
    rescue => e
      [500, {}, ["Internal Server Error"]]
    end

    private

    def welcome_html
      @welcome_html ||= File.read(File.expand_path('../../../public/index.html', __FILE__))
    end

  end
end

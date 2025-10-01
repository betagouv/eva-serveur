module StaticRecord
  module TestHelpers
    def stub_static_record_data_loading(data, chemin_data: '/path/to/test_file.yml')
      allow(Dir).to receive(:glob).and_return([ chemin_data ])
      allow(YAML).to receive(:load_file).and_return(data)
    end
  end
end

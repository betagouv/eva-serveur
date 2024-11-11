# frozen_string_literal: true

class GoogleDriveStorage
  class Error < StandardError; end
  GOOGLE_DRIVE_ACCOUNT_CONFIG = {
    'type' => 'service_account',
    'project_id' => ENV.fetch('GOOGLE_PROJECT_ID', nil),
    'private_key_id' => ENV.fetch('GOOGLE_PRIVATE_KEY_ID', nil),
    ## Penser à encoder en Base64 la variable 'GOOGLE_PRIVATE_KEY'
    ## et à retirer les retours à la ligne "\n" de la clé
    'private_key' => Base64.decode64(ENV.fetch('GOOGLE_PRIVATE_KEY', '')),
    'client_email' => ENV.fetch('GOOGLE_CLIENT_EMAIL', '').strip,
    'client_id' => ENV.fetch('GOOGLE_CLIENT_ID', nil),
    'auth_uri' => 'https://accounts.google.com/o/oauth2/auth',
    'token_uri' => 'https://oauth2.googleapis.com/token',
    'auth_provider_x509_cert_url' => 'https://www.googleapis.com/oauth2/v1/certs',
    'client_x509_cert_url' => ENV.fetch('GOOGLE_CLIENT_X509_CERT_URL', nil),
    'universe_domain' => 'googleapis.com'
  }.freeze

  def self.recupere_session
    Tempfile.create(['google_drive_service_account', '.json']) do |file|
      file.write(GOOGLE_DRIVE_ACCOUNT_CONFIG.to_json)
      file.rewind
      GoogleDrive::Session.from_service_account_key(file.path)
    end
  end

  def self.existe_dossier?(dossier_id)
    session = recupere_session
    begin
      @dossier = session.collection_by_id(dossier_id)
    rescue Google::Apis::ClientError => e
      raise Error, "Le dossier avec l'id '#{dossier_id}' n'est pas accessible : #{e.message}"
    end
  end

  def self.recupere_fichier(dossier_id, nom_fichier)
    unless existe_dossier?(dossier_id)
      raise "Le dossier avec l'id '#{dossier_id}' n'est pas accessible"
    end

    file = @dossier.files.find { |f| f.name == nom_fichier }
    raise "Fichier '#{nom_fichier}' n'existe pas dans le dossier '#{dossier_id}'" unless file

    file
  end
end

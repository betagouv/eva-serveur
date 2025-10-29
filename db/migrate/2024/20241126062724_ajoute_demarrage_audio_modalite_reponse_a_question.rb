class AjouteDemarrageAudioModaliteReponseAQuestion < ActiveRecord::Migration[7.2]
  def change
    add_column :questions, :demarrage_audio_modalite_reponse, :boolean, default: false
  end
end

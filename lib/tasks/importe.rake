# frozen_string_literal: true

require 'importeur_commentaires'
require 'importeur_telephone'

namespace :importe do
  desc 'Importe les commentaires Airtable'
  task commentaires_airtable: :environment do
    eva_bot = Compte.find_by email: Eva::EMAIL_SUPPORT
    if eva_bot.blank?
      RakeLogger.logger.error("eva Bot n'existe pas")
      exit
    end
    CSV.parse($stdin, headers: true, header_converters: :symbol).each do |row|
      ImporteurCommentaires.importe row.to_hash, eva_bot
    end
  end

  desc 'Importe les numéros de téléphone des conseillers connus'
  task telephones: :environment do
    CSV.parse($stdin, headers: true, header_converters: :symbol).each do |row|
      ImporteurTelephone.importe row.to_hash
    end
  end

  desc 'Importe les SIRETs des structures des conseillers connus'
  task siret: :environment do
    nb_ligne = 0
    nb_importe = 0
    CSV.parse($stdin, headers: true, header_converters: :symbol).each do |row|
      nb_ligne += 1
      ligne = row.to_hash
      compte = Compte.find_by id_inclusion_connect: ligne[:id_inclusion_connect]
      next if compte.blank? || compte.structure.blank? || compte.structure.siret.present?

      RakeLogger.logger.info "Importe : #{ligne[:id_inclusion_connect]},#{ligne[:siret]}"
      structure = compte.structure
      structure.update!(siret: ligne[:siret])
      nb_importe += 1
    end
    RakeLogger.logger.info "Importés : #{nb_importe} / #{nb_ligne}"
  end

  choix = [
    %w[2c178015-a7c1-4ff8-a344-8553a61e754a bienvenue_pas_facile],
    %w[e9ac38e1-41d6-4248-bb17-ffdef2416868 bienvenue_plutot_pas_facile],
    %w[cfe0e28f-3dd1-4d93-9e72-cb7084b2d1b1 bienvenue_ni_facile],
    %w[475d3d22-00ac-4fe6-8e25-5a05a800b6d2 bienvenue_pas_du_tout_facile],
    %w[a82e9c77-a814-49c5-8d54-9f2cd5964b3e bienvenue_plutot_facile],
    %w[4b2008b0-da7a-4f6e-afb8-c792efd50eb8 bienvenue_facile],
    %w[efb53dfe-75cd-4bb9-8a14-34e701bbc98c bienvenue_tres_facile],
    %w[38d84eda-6f36-4515-b549-97081ba9823c bienvenue_pas_du_tout_a_l_aise],
    %w[796194c6-edcd-4d1a-a49f-1c446480af24 bienvenue_pas_a_l_aise],
    %w[20376366-61f7-45d3-bf4d-ccde3645f84a bienvenue_plutot_pas_a_l_aise],
    %w[84c97b58-335d-477c-b56d-663848574b57 bienvenue_ni_a_l_aise],
    %w[7a342994-9562-45eb-b24b-d19c1b4bbe5a bienvenue_plutot_a_l_aise],
    %w[3625b826-148e-4788-a90d-7d90ac5dc1be bienvenue_a_l_aise],
    %w[b9c25115-5b97-4463-9b57-9faa3405b97b bienvenue_tres_a_l_aise],
    %w[bb39d545-462d-4db3-b482-5ee1b979054b bienvenue_pas_du_tout_daccord],
    %w[2fa0b877-5e53-46a2-b444-b27e34aca6f5 bienvenue_ni_daccord],
    %w[31c494ec-6751-433d-8127-b629aa3ae864 bienvenue_pas_daccord],
    %w[f35b9302-f193-41b7-ba5a-73dffa570852 bienvenue_plutot_pas_daccord],
    %w[6475b56b-fb28-49d6-acbe-6f6c88d4b47f bienvenue_plutot_daccord],
    %w[47dcb0dc-28e3-4fbd-8a37-35c3bd48117b bienvenue_daccord],
    %w[dc97920d-f221-4a5c-9626-11a68bb3af07 bienvenue_tout_a_fait_daccord],
    %w[3b071823-11e6-4bfb-874d-4a858f9c745e bienvenue_pas_du_tout_facile],
    %w[5bba9d5a-5107-4aeb-93f5-3fe5945b46da bienvenue_pas_facile],
    %w[c4efc2f4-ac24-44c4-b38d-2188474db62f bienvenue_plutot_pas_facile],
    %w[fe72b1e8-1ce8-45dd-8d62-ee6a7c10cf88 bienvenue_ni_facile],
    %w[5582e21a-ec67-4f04-98be-779d0c5246a4 bienvenue_plutot_facile],
    %w[1ca031c8-ddc2-457e-bfd8-6bd5256bcf09 bienvenue_facile],
    %w[f7131d3e-1f56-4d30-9a1b-7554de9063aa bienvenue_tres_facile],
    %w[c502e933-afec-4904-81de-f0128530d00a bienvenue_pas_du_tout_a_l_aise],
    %w[b708cc89-f349-4049-a809-df24d0b1dc67 bienvenue_pas_a_l_aise],
    %w[fd45caa5-f6ae-4230-9ba5-c8cea70aabff bienvenue_plutot_pas_a_l_aise],
    %w[09622e84-88b8-4cdd-9009-91b6adea5c86 bienvenue_ni_a_l_aise],
    %w[b9ed7fe5-1e47-4f8a-8607-3ad7c9c99973 bienvenue_plutot_a_l_aise],
    %w[c73ef29b-bb92-49d5-9860-ec4807f37a2e bienvenue_tres_a_l_aise],
    %w[0c3f8ad9-78a4-4699-a6df-de5b2abe4c82 bienvenue_a_l_aise],
    %w[5ad21f1a-7ec1-4905-a7c2-f9ca8f35a1e7 bienvenue_pas_du_tout_facile],
    %w[72526d43-50b7-4f03-9878-41391c6b80ac bienvenue_pas_facile],
    %w[31f04422-4b91-4e19-ad41-5cb1ab91f3fe bienvenue_plutot_pas_facile],
    %w[eddcf02b-ab49-4c55-873f-4312f42f4419 bienvenue_ni_facile],
    %w[24add0b3-1f7b-4ffb-983f-0606a8426e14 bienvenue_plutot_facile],
    %w[acf2d639-6706-4321-898e-8936de5eee74 bienvenue_facile],
    %w[d56a24b7-a331-490b-b14c-37c2cf688926 bienvenue_tres_facile],
    %w[f251866b-47e6-4f9d-a8ac-79b5b86cf88b bienvenue_pas_du_tout_daccord],
    %w[ac93073f-b2fb-4694-a365-450253f6d865 bienvenue_pas_daccord],
    %w[f2732489-6bec-4b44-bb51-fec92271a49f bienvenue_plutot_pas_daccord],
    %w[6c9d20ac-89e2-4c61-9ccf-05bb5ce08a25 bienvenue_ni_daccord],
    %w[d0dd7505-a0a5-46f6-906e-f33b644b080b bienvenue_plutot_daccord],
    %w[a550d79b-ad4b-497f-960f-8cd89e8afaad bienvenue_daccord],
    %w[839a72cf-a3b6-4382-9e66-86280787e7c9 bienvenue_tout_a_fait_daccord],
    %w[47fee14f-94d7-4e41-93e6-ad3e7228a108 bienvenue_8_reponse_1],
    %w[e1d6afdf-fcd7-4efc-8273-66ee7c9ac800 bienvenue_8_reponse_2],
    %w[a7d47094-9cd3-4ad0-b934-f5eb27587b2d bienvenue_8_reponse_3],
    %w[ee60e813-f3ae-4a95-acb3-ef2bb7622797 bienvenue_8_reponse_4],
    %w[2fbe00c7-a32d-43a6-9db5-2aa0c103e6f7 bienvenue_oui],
    %w[a612fd4c-e9d9-4e9c-a510-f5f6261e7e5c bienvenue_non],
    %w[cbf0719e-5226-49b1-a638-5cf5216940af bienvenue_oui],
    %w[a7fda24c-13b6-44f4-9f44-caa27992c455 bienvenue_non],
    %w[7dc92c46-5275-49da-86d5-608d3a5dbfab bienvenue_oui],
    %w[2aa099de-0b6f-4405-bde3-5aa26b4b40f8 bienvenue_non],
    %w[25fdbad4-9cd7-4213-aceb-165795090f2b bienvenue_oui],
    %w[f6970bc6-c967-4dee-9a0c-eb785858bafc bienvenue_non],
    %w[bb53613a-56ea-42f9-ad48-37ebbcfab372 bienvenue_oui],
    %w[507c02d4-ace3-471a-80cd-dc99efdeac19 bienvenue_non],
    %w[8933945b-4fa1-444c-8df8-409b2af0c132 bienvenue_oui],
    %w[a083a8f3-f58e-4ed0-84e0-95da0eb6866b bienvenue_non],
    %w[564ef5d8-9426-4356-9bd1-5a27394ac0d3 bienvenue_oui],
    %w[7608e3a1-eb6b-48b3-90e5-1737f5d7d956 bienvenue_non],
    %w[971a5089-e81b-4c49-aae0-60c323e1f243 bienvenue_16_reponse_1],
    %w[86f18103-3380-4cde-8c8c-0895a6fdc108 bienvenue_16_reponse_2],
    %w[84b007b5-f8fd-4e15-b517-4fb764237af9 bienvenue_non]
  ]

  desc 'ajoute les nom_technique des choix'
  task nom_technique_choix: :environment do
    choix.each do |id_nom_technique|
      print('.')
      Choix.find(id_nom_technique[0]).update(nom_technique: id_nom_technique[1])
    end
  end
end

FactoryBot.define do
  factory :source_aide do
    titre { 'titre' }
    categorie { :prise_en_main }
    description { 'description' }
    url { 'https://mon.domaine.net' }
    type_document { 'pdf' }
  end
end

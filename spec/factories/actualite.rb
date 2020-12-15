# frozen_string_literal: true

FactoryBot.define do
  factory :actualite do
    titre { 'contenu' }
    categorie { 'blog' }
    contenu { 'contenu' }
  end
end

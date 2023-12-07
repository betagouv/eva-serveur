# frozen_string_literal: true

require 'rails_helper'

describe PasswordValidator do
  describe '#validate' do
    it 'quand le mot de passe contient bien des majuscule, minuscule, chiffre et symbol' do
      compte = Compte.new(password: 'aA345678912$', role: :superadmin)
      described_class.new.validate(compte)
      expect(compte.errors.include?(:password)).to be false
    end

    it 'quand le mot de passe ne contient pas de majuscule' do
      compte = Compte.new(password: 'aa345678912$', role: :superadmin)
      described_class.new.validate(compte)
      expect(compte.errors.include?(:password)).to be true
    end

    it 'quand le mot de passe ne contient pas de minuscule' do
      compte = Compte.new(password: 'AA345678912$', role: :superadmin)
      described_class.new.validate(compte)
      expect(compte.errors.include?(:password)).to be true
    end

    it 'quand le mot de passe ne contient pas de chiffre' do
      compte = Compte.new(password: 'aAAAAAAAAAA$', role: :superadmin)
      described_class.new.validate(compte)
      expect(compte.errors.include?(:password)).to be true
    end

    it 'quand le mot de passe ne contient pas de symbol' do
      compte = Compte.new(password: 'aA3456789120', role: :superadmin)
      described_class.new.validate(compte)
      expect(compte.errors.include?(:password)).to be true
    end

    it 'quand le mot de passe ne contient pas assez de caracters' do
      compte = Compte.new(password: 'aA34567891$', role: :superadmin)
      described_class.new.validate(compte)
      expect(compte.errors.include?(:password)).to be true
    end

    it 'ne fait aucune vérificaton pour les comptes non anlci' do
      %i[conseiller admin compte_generique].each do |role|
        compte = Compte.new(password: '123456', role: role)
        described_class.new.validate(compte)
        expect(compte.errors.include?(:password)).to be false
      end
    end

    it 'vérifie les comptes anlci' do
      Compte::ANLCI_ROLES.each do |role|
        compte = Compte.new(password: '123456', role: role)
        described_class.new.validate(compte)
        expect(compte.errors.include?(:password)).to be true
      end
    end

    it 'ne valide rien si le mot de passe est vide' do
      compte = Compte.new(password: '', role: :superadmin)
      described_class.new.validate(compte)
      expect(compte.errors.include?(:password)).to be false
    end
  end
end

# frozen_string_literal: true

require 'capybara/rspec'
require_relative '../app/decorators/evenement_maintenance'
require_relative '../app/decorators/evenement_securite'
require_relative '../app/decorators/evenement_livraison'
require_relative '../app/decorators/evenement_objets_trouves'
require_relative '../app/decorators/evenement_evacob'

RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.before do
    allow(Truemail).to receive(:valid?).and_return(true)
    allow(RestClient).to receive(:get).and_raise(RestClient::NotFound.new)
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  DECORATORS = {
    maintenance: EvenementMaintenance,
    securite: EvenementSecurite,
    livraison: EvenementLivraison,
    objets_trouves: EvenementObjetsTrouves,
    evacob: EvenementEvacob
  }.freeze

  def se_connecter_comme_superadmin
    connecte create(:compte_superadmin, email: 'superadmin@exemple.fr', password: 'Password08$$$$')
  end

  def connecte(compte)
    connecte_email email: compte.email, password: compte.password
    compte
  end

  def connecte_email(email:, password: nil)
    visit new_compte_session_path
    fill_in :compte_email, with: email
    fill_in :compte_password, with: password
    click_on 'Se connecter'
  end

  def evenements_decores(evenements, scope)
    evenements.map { |e| DECORATORS[scope].new e }
  end
end

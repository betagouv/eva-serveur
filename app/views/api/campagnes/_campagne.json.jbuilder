json.libelle campagne.libelle
json.code campagne.code
json.situations campagne.situations_configurations,
                partial: "api/situations_configurations/situation_configuration",
                as: :situation_configuration
json.opco_financeur campagne.opco_financeur,
                    partial: "api/opcos/opco",
                    as: :opco

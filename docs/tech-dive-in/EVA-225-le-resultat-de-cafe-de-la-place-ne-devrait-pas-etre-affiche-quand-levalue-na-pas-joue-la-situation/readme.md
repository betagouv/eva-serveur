<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le résultat de café de la place ne devrait pas être affiché quand l'évalué n'a pas joué la situation

> [EVA-225](https://captive-team.atlassian.net/browse/EVA-225)

## Backend

Le problème vient de cette méthode
```ruby
  def avec_positionnement?
    configuration_inclus?(&:positionnement?)
  end
```
qu'on utilise pour afficher ou non le bloc littératie

- Créer une nouvelle méthode et l'utiliser dans `restituation_globale.arb`
```ruby
  def avec_litteratie?
    configuration_inclus?(&:litteratie?)
  end
```

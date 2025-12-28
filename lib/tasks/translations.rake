namespace :translations do
  NON_BREAKING_SPACE = "\u00A0"
  PUNCTUATION_CHARS = %w[? ! :].freeze
  LOCALES_DIR = Rails.root.join("config", "locales")

  # Caractères à ignorer dans certains contextes
  URL_PROTOCOLS = %w[http https].freeze
  WINDOWS_DRIVE_PATTERN = /\A[A-Z]:\\/i

  def find_yaml_files
    Dir.glob(LOCALES_DIR.join("**", "*.yml"))
  end

  def parse_yaml_file(file_path)
    YAML.load_file(file_path, aliases: true)
  rescue Psych::SyntaxError => e
    puts "⚠️  Erreur de syntaxe YAML dans #{file_path}: #{e.message}"
    nil
  rescue Psych::AliasesNotEnabled => e
    # Fallback pour les versions de Psych qui ne supportent pas aliases: true
    YAML.load_file(file_path)
  rescue StandardError => e
    puts "⚠️  Erreur lors du chargement de #{file_path}: #{e.message}"
    nil
  end

  def find_line_range(file_path, search_value, key_path)
    return nil unless File.exist?(file_path) || search_value.nil? || search_value.empty?

    lines = File.readlines(file_path)
    
    # Chercher la clé dans le fichier pour trouver où commence la valeur
    key_parts = key_path.split(".")
    last_key = key_parts.last
    
    start_line = nil
    end_line = nil
    
    # Chercher la ligne qui contient la clé suivie de : ou : |
    lines.each_with_index do |line, index|
      if line.match?(/^\s*#{Regexp.escape(last_key)}:\s*\|?\s*$/) || 
         line.match?(/^\s*#{Regexp.escape(last_key)}:\s*\|/)
        start_line = index + 1
        
        # Si c'est une valeur multiligne (avec |), trouver la fin
        if line.include?("|")
          # Chercher la prochaine ligne qui n'est pas indentée ou qui est au même niveau
          base_indent = line.match(/^(\s*)/)[1].length
          (index + 1...lines.length).each do |next_index|
            next_line = lines[next_index]
            # Si la ligne est vide, continuer
            next if next_line.strip.empty?
            # Si la ligne a moins ou égal d'indentation que la clé, c'est la fin
            next_indent = next_line.match(/^(\s*)/)[1].length
            if next_indent <= base_indent
              end_line = next_index
              break
            end
          end
          # Si on n'a pas trouvé de fin, prendre la dernière ligne du fichier
          end_line ||= lines.length
        else
          # Valeur sur une seule ligne
          end_line = index + 1
        end
        break
      end
    end
    
    # Si on n'a pas trouvé avec la clé, chercher par le contenu
    if start_line.nil?
      partial = search_value[0..50] if search_value.length > 50
      partial ||= search_value
      
      lines.each_with_index do |line, index|
        if line.include?(partial)
          start_line = index + 1
          # Essayer de trouver si c'est multiligne
          if index > 0 && lines[index - 1].match?(/:\s*\|/)
            # C'est une valeur multiligne, trouver la fin
            base_indent = lines[index - 1].match(/^(\s*)/)[1].length
            (index...lines.length).each do |next_index|
              next_line = lines[next_index]
              next if next_line.strip.empty?
              next_indent = next_line.match(/^(\s*)/)[1].length
              if next_indent <= base_indent && next_index > index
                end_line = next_index
                break
              end
            end
            end_line ||= lines.length
          else
            end_line = index + 1
          end
          break
        end
      end
    end
    
    return nil unless start_line
    
    if end_line && end_line != start_line
      { start: start_line, end: end_line }
    else
      { start: start_line, end: start_line }
    end
  end

  def extract_string_values(hash, prefix = "", file_path = nil)
    values = []
    hash.each do |key, value|
      current_key = prefix.empty? ? key.to_s : "#{prefix}.#{key}"
      case value
      when Hash
        values.concat(extract_string_values(value, current_key, file_path))
      when String
        line_range = find_line_range(file_path, value, current_key) if file_path
        values << { key: current_key, value: value, file: nil, line_range: line_range }
      when Array
        value.each_with_index do |item, index|
          if item.is_a?(String)
            line_range = find_line_range(file_path, item, "#{current_key}[#{index}]") if file_path
            values << { key: "#{current_key}[#{index}]", value: item, file: nil, line_range: line_range }
          elsif item.is_a?(Hash)
            values.concat(extract_string_values(item, "#{current_key}[#{index}]", file_path))
          end
        end
      end
    end
    values
  end

  def should_skip_check?(text, char_index)
    char = text[char_index]
    return false unless PUNCTUATION_CHARS.include?(char)

    # Vérifier si c'est dans une URL (http://, https://)
    before_char = text[0...char_index]
    if char == ":" && before_char.match?(/\b(#{URL_PROTOCOLS.join('|')})\z/i)
      return true
    end

    # Vérifier si c'est un chemin Windows (C:\)
    if char == ":" && before_char.match?(WINDOWS_DRIVE_PATTERN)
      return true
    end

    # Vérifier si c'est dans un bloc de code markdown (entre backticks)
    before_text = text[0...char_index]
    backticks_before = before_text.scan(/`/).length
    after_text = text[char_index + 1..]
    backticks_after = after_text.scan(/`/).length
    if backticks_before.odd? || backticks_after.odd?
      return true
    end

    # Vérifier si c'est dans un lien markdown [texte](url)
    # On cherche si on est entre [ et ] ou entre ( et )
    bracket_depth = 0
    paren_depth = 0
    text[0...char_index].each_char do |c|
      bracket_depth += 1 if c == "["
      bracket_depth -= 1 if c == "]"
      paren_depth += 1 if c == "("
      paren_depth -= 1 if c == ")"
    end
    if bracket_depth > 0 || paren_depth > 0
      return true
    end

    false
  end

  def check_non_breaking_spaces(text, key, file_path, line_range = nil)
    errors = []
    return errors if text.nil? || text.empty?

    # Vérifier les caractères de ponctuation ?, ! et :
    PUNCTUATION_CHARS.each do |char|
      # Chercher tous les caractères de ponctuation
      text.each_char.with_index do |c, index|
        next unless c == char
        next if should_skip_check?(text, index)

        # Vérifier le caractère avant
        if index > 0
          char_before = text[index - 1]
          # Si c'est un espace normal, c'est une erreur
          if char_before == " "
            errors << {
              key: key,
              file: file_path,
              char: char,
              position: index,
              context: extract_context(text, index),
              line_range: line_range,
              text: text
            }
          # Si c'est déjà un espace insécable, c'est OK
          elsif char_before == NON_BREAKING_SPACE
            # OK, rien à faire
          # Si c'est directement collé (pas d'espace), c'est aussi une erreur
          elsif char_before.match?(/\S/)
            errors << {
              key: key,
              file: file_path,
              char: char,
              position: index,
              context: extract_context(text, index),
              message: "caractère manquant avant #{char}",
              line_range: line_range,
              text: text
            }
          end
        else
          # Le caractère est au début, pas d'espace avant (normal)
          # Mais on peut quand même signaler si c'est problématique
        end
      end
    end

    # Vérifier les guillemets français « et »
    text.each_char.with_index do |c, index|
      # Vérifier après « (guillemet ouvrant)
      if c == "«"
        if index < text.length - 1
          char_after = text[index + 1]
          # Il doit y avoir un espace insécable après «
          if char_after == " "
            errors << {
              key: key,
              file: file_path,
              char: "«",
              position: index,
              context: extract_context(text, index),
              message: "espace insécable requis après «",
              line_range: line_range,
              text: text
            }
          elsif char_after != NON_BREAKING_SPACE && char_after.match?(/\S/)
            errors << {
              key: key,
              file: file_path,
              char: "«",
              position: index,
              context: extract_context(text, index),
              message: "espace insécable requis après «",
              line_range: line_range,
              text: text
            }
          end
        end
      end

      # Vérifier avant » (guillemet fermant)
      if c == "»"
        if index > 0
          char_before = text[index - 1]
          # Il doit y avoir un espace insécable avant »
          if char_before == " "
            errors << {
              key: key,
              file: file_path,
              char: "»",
              position: index,
              context: extract_context(text, index),
              message: "espace insécable requis avant »",
              line_range: line_range,
              text: text
            }
          elsif char_before != NON_BREAKING_SPACE && char_before.match?(/\S/)
            errors << {
              key: key,
              file: file_path,
              char: "»",
              position: index,
              context: extract_context(text, index),
              message: "espace insécable requis avant »",
              line_range: line_range,
              text: text
            }
          end
        end
      end
    end

    errors
  end

  def extract_context(text, position, context_size = 20)
    start_pos = [0, position - context_size].max
    end_pos = [text.length, position + context_size + 1].min
    context = text[start_pos...end_pos]
    marker_pos = position - start_pos
    "#{context[0...marker_pos]}▶#{context[marker_pos]}◀#{context[marker_pos + 1..]}"
  end

  desc "Vérifie que les caractères ?, ! et : sont précédés d'un espace insécable, et que les guillemets « et » ont des espaces insécables autour dans les traductions"
  task lint: :environment do
    puts "🔍 Vérification des espaces insécables dans les traductions..."
    puts ""

    all_errors = []
    yaml_files = find_yaml_files

    yaml_files.each do |file_path|
      file_path_obj = Pathname.new(file_path)
      relative_path = file_path_obj.relative_path_from(Rails.root)
      yaml_content = parse_yaml_file(file_path)
      next unless yaml_content

      # Extraire toutes les valeurs string
      string_values = extract_string_values(yaml_content, "", file_path)
      string_values.each { |v| v[:file] = relative_path }

      # Vérifier chaque valeur
      string_values.each do |item|
        errors = check_non_breaking_spaces(item[:value], item[:key], item[:file], item[:line_range])
        all_errors.concat(errors)
      end
    end

    if all_errors.empty?
      puts "✅ Aucune erreur trouvée ! Toutes les traductions respectent les règles typographiques."
      exit 0
    else
      puts "❌ #{all_errors.length} erreur(s) trouvée(s) :"
      puts ""
      all_errors.each do |error|
        # Formater la localisation du fichier
        if error[:line_range]
          if error[:line_range][:start] == error[:line_range][:end]
            file_location = "#{error[:file]}:#{error[:line_range][:start]}"
          else
            file_location = "#{error[:file]} (#{error[:line_range][:start]}-#{error[:line_range][:end]})"
          end
        else
          file_location = error[:file]
        end
        
        # Extraire un extrait de la phrase autour de l'erreur
        text = error[:text] || ""
        position = error[:position] || 0
        
        # Trouver le début de la phrase (chercher en arrière jusqu'à un point, !, ? ou début)
        start_pos = position
        (position - 1).downto(0) do |i|
          if text[i].match?(/[.!?]/) && i < position - 10
            start_pos = i + 1
            break
          elsif i == 0
            start_pos = 0
            break
          end
        end
        
        # Trouver la fin de la phrase (chercher en avant jusqu'à un point, !, ? ou fin)
        end_pos = position
        (position...text.length).each do |i|
          if text[i].match?(/[.!?]/)
            end_pos = i + 1
            break
          elsif i == text.length - 1
            end_pos = text.length
            break
          end
        end
        
        # Extraire la phrase complète
        full_phrase = text[start_pos...end_pos].strip
        
        # Calculer la distance de l'erreur par rapport à la fin de la phrase
        distance_from_end = end_pos - position
        
        # Si la phrase est trop longue, la tronquer intelligemment
        if full_phrase.length > 120
          # Si l'erreur est dans les 40 derniers caractères, montrer la fin complète (au moins 80 caractères)
          if distance_from_end <= 40
            excerpt = "..." + full_phrase[-[80, full_phrase.length].min..]
          # Si l'erreur est dans les 30 premiers caractères, montrer le début
          elsif position - start_pos <= 30
            excerpt = full_phrase[0..100] + "..."
          # Sinon, centrer sur l'erreur
          else
            error_rel_pos = position - start_pos
            start_excerpt = [0, error_rel_pos - 50].max
            excerpt = "..." + full_phrase[start_excerpt..start_excerpt + 100] + "..."
          end
        else
          # La phrase est assez courte, on la montre en entier
          excerpt = full_phrase
        end
        
        # Nettoyer l'extrait (retirer les retours à la ligne, espaces multiples et balises HTML)
        excerpt = excerpt.gsub(/<[^>]+>/, " ") # Retirer les balises HTML
        excerpt = excerpt.gsub(/\s+/, " ").gsub(/\n/, " ").strip
        
        puts "  🔴 #{file_location}"
        puts "     #{excerpt}"
        puts ""
      end
      puts "💡 Pour corriger, remplacez les espaces normaux par des espaces insécables (\\u00A0)"
      puts "   avant les caractères ?, ! et :, et autour des guillemets « et » dans les fichiers de traduction."
      puts ""
      puts "   Ou exécutez : bundle exec rake translations:lint:fix"
      exit 1
    end
  end

  def fix_text(text)
    fixed = text.dup

    # Corriger les espaces avant ?, ! et :
    PUNCTUATION_CHARS.each do |char|
      # Remplacer " ?" par " \u00A0?" (espace normal + char par espace insécable + char)
      fixed.gsub!(/ (#{Regexp.escape(char)})/, "#{NON_BREAKING_SPACE}\\1")
      
      # Remplacer les cas où il n'y a pas d'espace mais qu'il devrait y en avoir un
      # On parcourt à l'envers pour ne pas décaler les indices
      (fixed.length - 1).downto(0) do |index|
        next unless fixed[index] == char
        next if should_skip_check?(fixed, index)
        
        if index > 0
          char_before = fixed[index - 1]
          # Si c'est un caractère non-espace et pas déjà un espace insécable
          if char_before != NON_BREAKING_SPACE && char_before != " " && char_before.match?(/\S/)
            # Ajouter un espace insécable avant
            fixed.insert(index, NON_BREAKING_SPACE)
          end
        end
      end
    end

    # Corriger les espaces après «
    fixed.gsub!(/« /, "«#{NON_BREAKING_SPACE}")
    # Ajouter un espace insécable après « s'il n'y en a pas
    fixed.gsub!(/«([^\s#{NON_BREAKING_SPACE}])/, "«#{NON_BREAKING_SPACE}\\1")

    # Corriger les espaces avant »
    fixed.gsub!(/ »/, "#{NON_BREAKING_SPACE}»")
    # Ajouter un espace insécable avant » s'il n'y en a pas
    fixed.gsub!(/([^\s#{NON_BREAKING_SPACE}])»/, "\\1#{NON_BREAKING_SPACE}»")

    fixed
  end

  def fix_file(file_path, errors_for_file)
    return false unless File.exist?(file_path)

    content = File.read(file_path)
    original_content = content.dup
    modified = false

    # Grouper les erreurs par texte unique à corriger
    unique_texts = errors_for_file.map { |e| e[:text] }.compact.uniq

    unique_texts.each do |original_text|
      next if original_text.nil? || original_text.empty?

      fixed_text = fix_text(original_text)

      # Remplacer dans le contenu si le texte a changé
      if fixed_text != original_text
        # Échapper les caractères spéciaux pour la recherche, mais gérer les guillemets YAML
        escaped_original = Regexp.escape(original_text)
        # Essayer plusieurs patterns de remplacement
        if content.include?(original_text)
          content.gsub!(original_text, fixed_text)
          modified = true
        elsif content.match?(/#{escaped_original}/)
          content.gsub!(/#{escaped_original}/, fixed_text)
          modified = true
        end
      end
    end

    # Écrire le fichier seulement s'il a changé
    if modified && content != original_content
      File.write(file_path, content)
      true
    else
      false
    end
  end

  desc "Corrige automatiquement les espaces insécables dans les traductions"
  task "lint:fix": :environment do
    puts "🔧 Correction automatique des espaces insécables dans les traductions..."
    puts ""

    all_errors = []
    yaml_files = find_yaml_files
    errors_by_file = {}

    yaml_files.each do |file_path|
      file_path_obj = Pathname.new(file_path)
      relative_path = file_path_obj.relative_path_from(Rails.root)
      yaml_content = parse_yaml_file(file_path)
      next unless yaml_content

      # Extraire toutes les valeurs string
      string_values = extract_string_values(yaml_content, "", file_path)
      string_values.each { |v| v[:file] = relative_path }

      # Vérifier chaque valeur
      string_values.each do |item|
        errors = check_non_breaking_spaces(item[:value], item[:key], item[:file], item[:line_range])
        errors.each do |error|
          error[:full_path] = file_path
          all_errors << error
          errors_by_file[file_path] ||= []
          errors_by_file[file_path] << error
        end
      end
    end

    if all_errors.empty?
      puts "✅ Aucune erreur trouvée ! Toutes les traductions respectent les règles typographiques."
      exit 0
    else
      puts "🔧 Correction de #{all_errors.length} erreur(s) dans #{errors_by_file.length} fichier(s)..."
      puts ""

      fixed_count = 0
      errors_by_file.each do |file_path, errors|
        if fix_file(file_path, errors)
          fixed_count += 1
          puts "  ✅ Corrigé : #{Pathname.new(file_path).relative_path_from(Rails.root)}"
        end
      end

      puts ""
      puts "✅ #{fixed_count} fichier(s) corrigé(s)."
      puts ""
      puts "💡 Vérifiez les modifications avec : bundle exec rake translations:lint"
    end
  end
end


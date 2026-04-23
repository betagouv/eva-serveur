# frozen_string_literal: true

module Linters
  # Vérifie l'absence du mot "OPCO" dans les fichiers de traduction YAML
  # Le mot "OPCO" doit être remplacé par "Opérateur de Compétences"
  class LocaleOpco
    Violation = Struct.new(:file, :key_path, :message, :snippet, keyword_init: true)

    def initialize(locales_dir: nil)
      @locales_dir = locales_dir || Rails.root.join("config/locales")
    end

    def check
      violations = []
      Dir.glob(@locales_dir.join("**/*.yml")).each do |path|
        violations.concat(check_file(path))
      end
      violations
    end

    def check_file(path)
      violations = []
      data = YAML.load_file(path, aliases: true)
      return violations unless data.is_a?(Hash)

      collect_violations(data, path.to_s, [], violations)
      violations
    end

    def self.run(locales_dir: nil)
      new(locales_dir: locales_dir).tap do |linter|
        violations = linter.check
        linter.report(violations)
        exit(1) if violations.any?
      end
    end

    def report(violations, io: $stderr)
      return if violations.empty?

      report_header(violations.size, io)
      violations.each { |v| report_violation(v, io) }
    end

    def report_header(count, io)
      io.puts "Utilisation de OPCO : #{count} violation(s) trouvée(s)."
      io.puts "Le mot « OPCO » est interdit. Utiliser plutôt : « Opérateur de Compétences »"
      io.puts
    end

    def report_violation(v, io)
      io.puts "  #{v.file} (#{v.key_path.join('.')})"
      io.puts "    #{v.message}"
      io.puts "    Extrait : #{v.snippet.inspect}" if v.snippet
      io.puts
    end

    private

    def collect_violations(obj, file, key_path, violations)
      case obj
      when Hash
        obj.each do |key, value|
          collect_violations(value, file, key_path + [ key.to_s ], violations)
        end
      when Array
        obj.each_with_index do |item, index|
          collect_violations(item, file, key_path + [ "[#{index}]" ], violations)
        end
      when String
        check_string(obj, file, key_path, violations)
      end
    end

    def check_string(str, file, key_path, violations)
      # Cherche le mot "OPCO" (avec limites de mots pour éviter les faux positifs)
      str.scan(/\bOPCO\b/) do
        msg = "Le mot « OPCO » est interdit. Utiliser plutôt : « Opérateur de Compétences »"
        violations << Violation.new(
          file: file,
          key_path: key_path,
          message: msg,
          snippet: extract_snippet(str, Regexp.last_match.offset(0)[0], 30)
        )
      end
    end

    def extract_snippet(str, position, context = 30)
      start = [ 0, position - context ].max
      finish = [ str.length, position + context ].min
      snippet = str[start...finish]
      snippet = "…#{snippet}" if start.positive?
      snippet = "#{snippet}…" if finish < str.length
      snippet
    end
  end
end

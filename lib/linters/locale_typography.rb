# frozen_string_literal: true

module Linters
  # Verifie les regles typographiques francaises dans les fichiers de traduction YAML :
  # - espace insecable (U+00A0 ou U+202F) avant : ! ?
  # - espace insecable apres guillemet ouvrant et avant guillemet fermant
  class LocaleTypography
    NORMAL_SPACE = "\u0020"
    GUILMET_OPEN = "«"
    GUILMET_CLOSE = "»"

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
      io.puts "Typographie des locales : #{count} violation(s) trouvee(s)."
      io.puts "Utilisez des espaces insecables (U+00A0 ou U+202F) avant : ! ?, apres « et avant »."
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
      check_space_before_punctuation(str, file, key_path, violations)
      check_space_after_guilmet_open(str, file, key_path, violations)
      check_space_before_guilmet_close(str, file, key_path, violations)
    end

    # Espace normal avant : ! ?
    def check_space_before_punctuation(str, file, key_path, violations)
      str.scan(/#{Regexp.escape(NORMAL_SPACE)}([!?:])/) do
        punct = Regexp.last_match(1)
        msg = "Espace normal avant « #{punct} » ; utiliser un espace insecable (U+00A0 ou U+202F)."
        violations << Violation.new(
          file: file,
          key_path: key_path,
          message: msg,
          snippet: extract_snippet(str, Regexp.last_match.offset(0)[0], 20)
        )
      end
    end

    # Espace normal apres guillemet ouvrant
    def check_space_after_guilmet_open(str, file, key_path, violations)
      regex = /#{Regexp.escape(GUILMET_OPEN)}#{Regexp.escape(NORMAL_SPACE)}/
      str.scan(regex) do
        violations << Violation.new(
          file: file,
          key_path: key_path,
          message: "Espace normal apres « ; utiliser un espace insecable.",
          snippet: extract_snippet(str, Regexp.last_match.offset(0)[0], 25)
        )
      end
    end

    # Espace normal avant guillemet fermant
    def check_space_before_guilmet_close(str, file, key_path, violations)
      regex = /#{Regexp.escape(NORMAL_SPACE)}#{Regexp.escape(GUILMET_CLOSE)}/
      str.scan(regex) do
        violations << Violation.new(
          file: file,
          key_path: key_path,
          message: "Espace normal avant » ; utiliser un espace insecable.",
          snippet: extract_snippet(str, Regexp.last_match.offset(0)[0], 25)
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

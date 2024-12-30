# frozen_string_literal: true

module RuboCop
  module Cop
    module Custom
      class SvgImageAltTag < Base
        MSG = 'svg_tag_base64 et svg_attachment_base64 doivent avoir un attribut alt'

        def on_send(node)
          unless NodePattern.new('(send nil? :svg_tag_base64 ...)').match(node) ||
                 NodePattern.new('(send nil? :svg_attachment_base64 ...)').match(node)
            return
          end

          options = node.arguments.last
          return unless options&.hash_type?

          add_offense(node) unless options.pairs.any? { |pair| pair.key.value == :alt }
        end
      end
    end
  end
end

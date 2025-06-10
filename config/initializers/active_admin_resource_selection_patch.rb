# frozen_string_literal: true

require 'active_admin/batch_actions/views/selection_cells'

module ActiveAdmin
  module BatchActions
    module Views
      module ResourceSelectionCellPatch
        def build(resource)
          checkbox_id = "batch_action_item_#{resource.id}"

          input_html = tag.input(
            type: "checkbox",
            id: checkbox_id,
            name: "collection_selection[]",
            value: resource.id,
            class: "batch-actions-resource-selection",
            "aria-describedby": "#{checkbox_id}-messages"
          )

          label_html = content_tag(:label, '', class: 'fr-label', for: checkbox_id)
          
          wrapper_html = content_tag(
            :div,
            input_html + label_html,
            class: "fr-checkbox-group fr-checkbox-group--sm"
          )

          element_html = content_tag(:div, wrapper_html, class: "fr-fieldset__element checkbox-wrapper")

          text_node element_html
        end
      end

      module ResourceSelectionToggleCellPatch
        def build(_params = nil)
          checkbox_id = "collection_selection_toggle_all"

          input_html = tag.input(
            type: "checkbox",
            id: checkbox_id,
            class: "toggle_all",
            "aria-describedby": "#{checkbox_id}-messages"
          )

          label_html = content_tag(:label, '', class: 'fr-label', for: checkbox_id)

          wrapper_html = content_tag(
            :div,
            input_html + label_html,
            class: "fr-checkbox-group fr-checkbox-group--sm"
          )

          element_html = content_tag(:div, wrapper_html, class: "fr-fieldset__element")

          text_node element_html
        end
      end

      ResourceSelectionCell.prepend(ResourceSelectionCellPatch)
      ResourceSelectionToggleCell.prepend(ResourceSelectionToggleCellPatch)
    end
  end
end

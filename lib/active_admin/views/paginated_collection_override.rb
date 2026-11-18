# Les téléchargements sont proposés dans l'encart de gestion : on masque les liens sous le tableau
# sans toucher à download_links, qui autorise aussi les formats (export XLS, filtres AJAX en JSON).

module ActiveAdmin
  module Views
    module PaginatedCollectionOverride
      private

      def build_download_format_links(*); end
    end
  end
end

unless ActiveAdmin::Views::PaginatedCollection.ancestors
                                             .include?(ActiveAdmin::Views::PaginatedCollectionOverride)
  ActiveAdmin::Views::PaginatedCollection.prepend(ActiveAdmin::Views::PaginatedCollectionOverride)
end

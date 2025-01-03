module ImportExport
	class CreationSheetXls
		def initialize(titre, entetes, workbook)
			@titre = titre
			@entetes = entetes
			@workbook = workbook
		end

		def initialise_sheet
			@sheet = @workbook.create_worksheet(name: @titre)
			format_premiere_ligne = Spreadsheet::Format.new(weight: :bold)
			@sheet.row(0).default_format = format_premiere_ligne
			@entetes.each_with_index do |entete, colonne|
				@sheet[0, colonne] = entete[:titre]
				@sheet.column(colonne).width = entete[:taille]
			end

			@sheet 
		end
	end
end

module AssMaintainer
  module InfoBases
    module Support
      module TmpPath
        require 'tempfile'
        # Generates temporary path's string
        # @return [String]
        def tmp_path(ext)
          tf = Tempfile.new(ext)
          tf.unlink
          tf.to_path
        end
      end
    end
  end
end


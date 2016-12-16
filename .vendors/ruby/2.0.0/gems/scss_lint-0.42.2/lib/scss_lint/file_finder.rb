require 'find'

module SCSSLint
  # Finds all SCSS files that should be linted given a set of paths, globs, and
  # configuration.
  class FileFinder
    # List of extensions of files to include when only a directory is specified
    # as a path.
    VALID_EXTENSIONS = %w[.css .scss]

    # Create a {FileFinder}.
    #
    # @param config [SCSSLint::Config]
    def initialize(config)
      @config = config
    end

    # Find all files that match given the specified options.
    #
    # @param patterns [Array<String>] a list of file paths and glob patterns
    def find(patterns)
      # If no explicit patterns given, use patterns listed in config
      patterns = @config.scss_files if patterns.empty?

      matched_files = extract_files_from(patterns)
      if matched_files.empty?
        raise SCSSLint::Exceptions::NoFilesError,
              "No SCSS files matched by the patterns: #{patterns.join(' ')}"
      end

      matched_files.reject { |file| @config.excluded_file?(file) }
    end

  private

    # @param list [Array]
    def extract_files_from(list)
      files = []

      list.each do |file|
        if File.directory?(file)
          Find.find(file) do |f|
            files << f if scssish_file?(f)
          end
        else
          files << file # Otherwise include file as-is
        end
      end

      files.uniq
    end

    # @param file [String]
    # @return [true,false]
    def scssish_file?(file)
      return false unless FileTest.file?(file)

      VALID_EXTENSIONS.include?(File.extname(file))
    end
  end
end

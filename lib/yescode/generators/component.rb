# frozen_string_literal: true

module Yescode
  module Generators
    class Component
      include Yescode::Strings

      HELP_MESSAGE = <<~TXT
        Usage: yescode component [name]

        Create a new blank component

        Example:
          yescode component create_todo

        This will generate a component named CreateTodo in ./app/components/create_todo.rb and a template file
        in ./app/components/create_todo.html.erb.
      TXT

      def initialize(name)
        @name = name
      end

      def call
        if @name.nil?
          puts HELP_MESSAGE
          return
        end

        FileUtils.mkdir_p(dir)
        File.write(File.join(dir, "#{@name}.rb"), rb)
        File.write(File.join(dir, "#{@name}.html.erb"), erb)
      end

      def rb
        <<~RB
          class #{class_name} < YesComponent
            def get
            end

            def post
            end
          end
        RB
      end

      def erb
        <<~ERB
          <h1>#{class_name}</h1>
        ERB
      end

      private

      def class_name
        pascal_case(@name)
      end

      def dir
        File.join(".", "app", "components")
      end
    end
  end
end

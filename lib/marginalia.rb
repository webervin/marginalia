require 'marginalia/railtie'
require 'marginalia/comment'

module Marginalia
  mattr_accessor :application_name

  module ActiveRecordInstrumentation
    def self.included(instrumented_class)
      Marginalia::Comment.components = [:application, :controller, :action]
      instrumented_class.class_eval do
        if defined? :execute
          alias_method :execute_without_marginalia, :execute
          alias_method :execute, :execute_with_marginalia
        end
        if defined? :query
          alias_method :query_without_marginalia, :query
          alias_method :query, :query_with_marginalia
        end
        if defined? :exec_no_cache
          alias_method :exec_no_cache_without_marginalia, :exec_no_cache
          alias_method :exec_no_cache, :exec_no_cache_with_marginalia
        end
      end
    end

    def execute_with_marginalia(sql, name = nil)
      execute_without_marginalia(marginalize_sql(sql), name)
    end

    def query_with_marginalia(sql, name = nil)
      query_without_marginalia(marginalize_sql(sql), name = nil)
    end

    def exec_no_cache_with_marginalia(sql, binds)
      exec_no_cache_without_marginalia(marginalize_sql(sql), binds)
    end

    def marginalize_sql(sql)
      "/*#{Marginalia::Comment.to_s}*/\n#{sql}"
    end
  end

end

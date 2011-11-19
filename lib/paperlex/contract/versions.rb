module Paperlex
  class Contract < Base
    class Versions < Paperlex::Versions
      def base
        'contracts'
      end
    end
  end
end

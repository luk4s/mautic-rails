module Mautic
  class Tag < Model

    class Collection < Array
      attr_reader :model

      # @param [Mautic::Model] model
      def initialize(model, *several_variants)
        @model = model
        @tags_to_remove = []
        super(several_variants)
      end

      def <<(item)
        @model.changed = true
        item = Tag.new(@model, { tag: item }) if item.is_a?(String)
        super(item)
      end

      def remove(item)
        @model.changed = true
        item = detect { |t| t.name == item } if item.is_a?(String)
        @tags_to_remove << "-#{item}"
        delete item
      end

      def to_mautic
        map(&:name) + @tags_to_remove
      end
    end

    # alias for attribute :tag
    def name
      tag
    end

    def to_s
      name
    end

    def name=(name)
      self.tag = name
    end

  end
end
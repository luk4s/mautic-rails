module Mautic
  class Contact < Model

    around_create :ensure_stage, if: ->(contact) { contact.changes.has_key?(:stage_id) }
    around_update :ensure_stage, if: ->(contact) { contact.changes.has_key?(:stage_id) }

    alias_attribute :first_name, :firstname
    alias_attribute :last_name, :lastname

    def self.in(connection)
      Proxy.new(connection, endpoint, default_params: { search: '!is:anonymous' })
    end

    def name
      "#{firstname} #{lastname}"
    end

    # @param [Hash] hash
    # option hash [Integer] :id
    # option hash [String] :firstName
    # option hash [String] :lastName
    def owner=(hash)
      raise ArgumentError, "must be a hash !" unless hash.is_a?(Hash)

      @table[:owner] = hash["id"]
      @owner = hash
    end

    # @return [Hash]
    # @example {id: 12, firstName: "Joe", lastName: "Doe"}
    def owner
      @owner || {}
    end

    # Assign mautic User ID as owner - for example for update author of contact
    # @see https://developer.mautic.org/#edit-contact set owner
    # @param [Integer] int
    def owner_id=(int)
      @table[:owner] = int
    end

    def assign_attributes(source = nil)
      super

      if source
        self.owner = source['owner'] || {}
        self.stage = source['stage'] || {}
        tags = (source['tags'] || []).map { |t| Mautic::Tag.new(self, t) }.sort_by(&:name)
        self.attributes = {
          tags: Tag::Collection.new(self, *tags),
          doNotContact: source['doNotContact'] || [],
          owner: owner['id'],
          stage_id: stage&.id,
        }
      end
    end

    def to_mautic(data = @table)
      data.delete(:doNotContact)
      super(data)
    end

    def events
      @proxy_events ||= Proxy.new(connection, "contacts/#{id}/events", klass: "Mautic::Event")
    end

    # @!group Do Not Contact
    # @see https://developer.mautic.org/#add-do-not-contact

    def do_not_contact?
      doNotContact.present?
    end

    alias dnc? do_not_contact?

    # @return [Array[Hash]]
    def do_not_contact
      return unless do_not_contact?

      # Based on mautic docs => Contacts constants: Contacts::UNSUBSCRIBED (1), Contacts::BOUNCED (2), Contacts::MANUAL (3)
      reason_list = { 1 => :unsubscribed, 2 => :bounced, 3 => :manual }
      @do_not_contact ||= doNotContact.collect do |hsh|
        { reason_list[hsh["reason"]] => hsh["comments"] }
      end
    end

    def bounced?
      do_not_contact? && !!do_not_contact.detect { |dnc| dnc.key?(:bounced) }
    end

    def unsubscribed?
      do_not_contact? && !!do_not_contact.detect { |dnc| dnc.key?(:unsubscribed) }
    end

    def do_not_contact!(comments: '')
      begin
        json = @connection.request(:post, "api/contacts/#{id}/dnc/email/add", body: { comments: comments })
        self.attributes = { doNotContact: json[endpoint.singularize]["doNotContact"] }
        clear_changes
      rescue ValidationError => e
        self.errors = e.errors
      end

      errors.blank?
    end

    alias add_dnc do_not_contact!

    def remove_do_not_contact!
      begin
        json = @connection.request(:post, "api/contacts/#{id}/dnc/email/remove", body: {})
        self.attributes = { doNotContact: json[endpoint.singularize]["doNotContact"] }
        clear_changes
      rescue ValidationError => e
        self.errors = e.errors
      end

      self.errors.blank?
    end

    alias remove_dnc remove_do_not_contact!

    # !endgroup

    # @!group Campaigns

    # @return [Array<Mautic::Campaign>]
    def campaigns
      return @campaigns if @campaigns

      json = @connection.request(:get, "api/contacts/#{id}/campaigns")

      @campaigns = json["campaigns"].collect do |_campaign_id, campaign_attributes|
        Mautic::Campaign.new @connection, campaign_attributes
      end
    rescue RequestError => _e
      []
    end

    # !endgroup

    # @!group Stage

    # @return [Mautic::Stage, nil]
    def stage
      @stage
    end

    # @param [Mautic:::Stage,Hash, nil] hash
    def stage=(object_or_hash)
      @stage = case object_or_hash
               when Mautic::Stage
                 object_or_hash
               when Hash
                 Mautic::Stage.new(connection, object_or_hash)
               end
      @table[:stage_id] = @stage&.id
      @stage
    end

    # !endgroup

    private

    def clear_change
      super
      remove_instance_variable :@do_not_contact
    end

    # Add or Remove contact in stage after contact save
    def ensure_stage
      stage_id_change = changes[:stage_id]
      yield
      if stage_id_change
        self.stage = Mautic::Stage.in(connection).find(stage_id_change)
        stage.add_contact!(id)
        @table[:stage_id] = stage.id
      else
        stage.remove_contact!(id)
        @table.delete(:stage_id)
      end
      clear_changes
    end
  end
end

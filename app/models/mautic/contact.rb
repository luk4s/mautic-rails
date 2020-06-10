module Mautic
  class Contact < Model

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
        self.attributes = {
          tags: (source['tags'] || []).collect { |t| Mautic::Tag.new(@connection, t) }.sort_by(&:name),
          doNotContact: source['doNotContact'] || [],
          owner: owner['id'],
        }
      end
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

      self.errors.blank?
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

    private

    def clear_change
      super
      remove_instance_variable :@do_not_contact
    end
  end
end
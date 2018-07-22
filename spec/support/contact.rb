RSpec.shared_context "contact", shared_context: :metadata do

  let(:contacts) do
    {
      "total" => "1",
      "contacts" => { "47" =>
                        {
                          "id" => 47,
                          "isPublished" => true,
                          "dateAdded" => "2015-07-21T12:27:12-05:00",
                          "createdBy" => 1,
                          "createdByUser" => "Joe Smith",
                          "dateModified" => "2015-07-21T14:12:03-05:00",
                          "modifiedBy" => 1,
                          "modifiedByUser" => "Joe Smith",
                          "owner" => {
                            "id" => 1,
                            "username" => "joesmith",
                            "firstName" => "Joe",
                            "lastName" => "Smith"
                          },
                          "points" => 10,
                          "lastActive" => "2015-07-21T14:19:37-05:00",
                          "dateIdentified" => "2015-07-21T12:27:12-05:00",
                          "color" => "ab5959",
                          "ipAddresses" => {
                            "111.111.111.111" => {
                              "ipAddress" => "111.111.111.111",
                              "ipDetails" => {
                                "city" => "",
                                "region" => "",
                                "country" => "",
                                "latitude" => "",
                                "longitude" => "",
                                "isp" => "",
                                "organization" => "",
                                "timezone" => ""
                              }
                            }
                          },
                          "fields" => {
                            "core" => {
                              "title" => {
                                "id" => "1",
                                "label" => "Title",
                                "alias" => "title",
                                "type" => "lookup",
                                "group" => "core",
                                "value" => "Mr"
                              },
                              "firstname" => {
                                "id" => "2",
                                "label" => "First Name",
                                "alias" => "firstname",
                                "type" => "text",
                                "group" => "core",
                                "value" => "Jim"
                              }
                            },
                            "social" => {
                              "twitter" => {
                                "id" => "17",
                                "label" => "Twitter",
                                "alias" => "twitter",
                                "type" => "text",
                                "group" => "social",
                                "value" => "jimcontact"
                              }
                            },
                            "personal" => [],
                            "professional" => [],
                            "all" => {
                              "title" => "Mr",
                              "firstname" => "Jim",
                              "twitter" => "jimcontact"
                            }
                          }
                        }
      }
    }
  end
  let(:contact) do
    {
      "contact" =>
        {
          "id" => 47,
          "isPublished" => true,
          "dateAdded" => "2015-07-21T12:27:12-05:00",
          "createdBy" => 1,
          "createdByUser" => "Joe Smith",
          "dateModified" => "2015-07-21T14:12:03-05:00",
          "modifiedBy" => 1,
          "modifiedByUser" => "Joe Smith",
          "owner" => {
            "id" => 1,
            "username" => "joesmith",
            "firstName" => "Joe",
            "lastName" => "Smith"
          },
          "points" => 10,
          "lastActive" => "2015-07-21T14:19:37-05:00",
          "dateIdentified" => "2015-07-21T12:27:12-05:00",
          "color" => "ab5959",
          "ipAddresses" => {
            "111.111.111.111" => {
              "ipAddress" => "111.111.111.111",
              "ipDetails" => {
                "city" => "",
                "region" => "",
                "country" => "",
                "latitude" => "",
                "longitude" => "",
                "isp" => "",
                "organization" => "",
                "timezone" => ""
              }
            }
          },
          "tags"=>[
            {
              "id"=>1,
              "tag"=>"important"
            }
          ],
          "fields" => {
            "core" => {
              "title" => {
                "id" => "1",
                "label" => "Title",
                "alias" => "title",
                "type" => "lookup",
                "group" => "core",
                "value" => "Mr"
              },
              "firstname" => {
                "id" => "2",
                "label" => "First Name",
                "alias" => "firstname",
                "type" => "text",
                "group" => "core",
                "value" => "Jim"
              },
              "lastname" => {
                "id" => "3",
                "label" => "Last Name",
                "alias" => "lastname",
                "type" => "text",
                "group" => "core",
                "value" => "Joe"
              }
            },
            "social" => {
              "twitter" => {
                "id" => "17",
                "label" => "Twitter",
                "alias" => "twitter",
                "type" => "text",
                "group" => "social",
                "value" => "jimcontact"
              }
            },
            "personal" => [],
            "professional" => [],
            "all" => {
              "title" => "Mr",
              "firstname" => "Jim",
              "lastname" => "Joe",
              "twitter" => "jimcontact"
            }
          }
        }
    }
  end

end
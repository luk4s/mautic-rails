module Mautic
  RSpec.describe RequestError do
    include_context 'connection'

    context "500" do
      before do

      end

      it "without body" do
        stub_request(:get, "#{oauth2.url}/api/contacts/1")
          .and_return(
            status: 500,
            body: "",
            headers: { 'Content-Type' => 'text/html; charset=UTF-8' }
          )
        expect { oauth2.contacts.find 1 }.to raise_exception do |ex|
          expect(ex.message).to eq "#{oauth2.url}/api/contacts/1 => 500 "
        end
      end

      it "with HTML body" do
        html = <<HTML
<!DOCTYPE html>
<head>
</head>
<body>
500
</body>
HTML
        stub_request(:get, "#{oauth2.url}/api/contacts/1")
          .and_return(
            status: 500,
            body: html,
            headers: { 'Content-Type' => 'text/html; charset=UTF-8' }
          )
        expect { oauth2.contacts.find 1 }.to raise_exception do |ex|
          expect(ex.message).to eq "#{oauth2.url}/api/contacts/1 => 500 </body>"
        end
      end

      it "with HTML body mixed with json" do
        html = <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Site is offline</title>

    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <link rel="icon" type="image/x-icon" href="/media/images/favicon.ico"/>
    <link rel="stylesheet" href="/media/css/libraries.css"/>
    <link rel="stylesheet" href="/media/css/app.css"/>
</head>

<body>
<div class="container">
    <div class="row">
                <div class="col-sm-offset-3 col-sm-6">
            <div class="bg-white pa-lg text-center" style="margin-top:100px;">
                <i class="fa fa-warning fa-5x"></i>
                <h2>The site is currently offline due to encountering an error. If the problem persists, please contact the system administrator.</h2>
                                <h4 class="mt-15">System administrators, check server logs for errors.</h4>
                            </div>
        </div>
            </div>
    </div>
</body>
</html>
{"errors":[{"message":"Looks like I encountered an error (error #500). If I do it again, please report me to the system administrator!","code":500,"type":null}],"error":{"message":"Looks like I encountered an error (error #500). If I do it again, please report me to the system administrator! (`error` is deprecated as of 2.6.0 and will be removed in 3.0. Use the `errors` array instead.)","code":500}}
HTML
        stub_request(:get, "#{oauth2.url}/api/contacts/1")
          .and_return(
            status: 500,
            body: html,
            headers: { 'Content-Type' => 'text/html; charset=UTF-8' }
          )
        expect { oauth2.contacts.find 1 }.to raise_exception do |ex|
          expect(ex.message).to eq "#{oauth2.url}/api/contacts/1 => 500 Looks like I encountered an error (error #500). If I do it again, please report me to the system administrator!"
        end
      end
    end
  end
end
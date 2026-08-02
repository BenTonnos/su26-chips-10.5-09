require 'rspec/mocks'

World(RSpec::Mocks::ExampleMethods)

Before do
  RSpec::Mocks.setup

  fake_response = {
    'results' => [
      {
        'response' => {
          'results' => [
            {
              'fields' => {
                'congressional_districts' => [
                  {
                    'current_legislators' => [
                      {
                        'type' => 'representative',
                        'bio' => {
                          'first_name' => 'Francisco',
                          'last_name' => 'De La Riega',
                          'party' => 'Democrat'
                        }
                      }
                    ]
                  }
                ]
              }
            }
          ]
        }
      }
    ]
  }

  allow(Representative)
    .to receive(:geocodio_search)
    .and_return(fake_response)
end

After do
  RSpec::Mocks.teardown
end

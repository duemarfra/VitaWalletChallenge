class BtcPriceService
  require 'net/http'
  require 'json'
  require 'uri'

  def self.fetch_btc_prices
    url = URI.parse('https://api.coindesk.com/v1/bpi/currentprice.json')
    response = Net::HTTP.get(url)
    data = JSON.parse(response)

    {
      usd: data['bpi']['USD']['rate_float'],
      gbp: data['bpi']['GBP']['rate_float'],
      eur: data['bpi']['EUR']['rate_float']
    }
  rescue StandardError => e
    { error: "Error fetching BTC prices: #{e.message}" }
  end
end

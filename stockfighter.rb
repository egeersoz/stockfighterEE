require 'rubygems'
require 'httparty'
require 'json'
require 'yaml'


class Stockfighter

	def initialize(acct)
		@config = YAML.load_file('config/config.yml')
		@account = acct
	end


  # Place a new order.
  # price: Integer. Desired price without decimals (e.g. $100.23 is 10023)
  # direction: "buy" or "sell"
  # orderType: "limit", "market", "fill-or-kill" or "immediate-or-cancel"
  #
	def place_order(venue, stock, price, quantity, direction, orderType)
		new_order = {
			'account' => @account,
			'venue' => venue,
			'stock' => stock,
			'price' => price,
			'qty'   => quantity,
			'direction' => direction,
			'orderType' => orderType
		}
		order_response = HTTParty.post("#{@config["base_url"]}/venues/#{venue}/stocks/#{stock}/orders",
		                       :body => JSON.dump(new_order),
		                       :headers => {'X-Starfighter-Authorization' => @config["apikey"]}
		                       )
		puts order_response_body
	end

	def stocks_on_a_venue(venue)
		response = HTTParty.get("#{@config["base_url"]}/venues/#{venue}/stocks",
														:headers => {'X-Starfighter-Authorization' => @config["apikey"]}
														)
		puts response.parsed_response
	end


  # Best ask available for a given stock. Buying above this price should go through.
  #
	def best_ask(venue, stock)
		response = HTTParty.get("#{@config["base_url"]}/venues/#{venue}/stocks/#{stock}",
														:headers => {'X-Starfighter-Authorization' => @config["apikey"]}
														)
		orderbook = response.parsed_response
		puts orderbook["asks"][0]
	end


  # Best bid available for a given stock. Buying above this price should go through.
  #
	def best_bid(venue, stock)
		response = HTTParty.get("#{@config["base_url"]}/venues/#{venue}/stocks/#{stock}",
														:headers => {'X-Starfighter-Authorization' => @config["apikey"]}
														)
		orderbook = response.parsed_response
	  puts orderbook["bids"][0]
	end


  # Best ask available for a given stock. Buying above this price should go through.
  #
	def get_quote(venue, stock)
		quote = HTTParty.get("#{@config["base_url"]}/venues/#{venue}/stocks/#{stock}/quote",
												 :headers => {'X-Starfighter-Authorization' => @config["apikey"]}
												 )
	end

	def get_all_orders_in_stock(venue, stock)
		all_orders_in_stock = {
			'venue' => venue,
			'account' => account,
			'stock' => stock
		}
		all_orders_in_stock_response = HTTParty.get("#{@config["base_url"]}/venues/#{venue}/accounts/#{@account}/stocks/#{stock}/orders",
												                       :body => JSON.dump(all_orders_in_stock),
												                       :headers => {'X-Starfighter-Authorization' => @config["apikey"]}
												                       )
		puts all_orders_in_stock_response.body
	end

	def cancel_order(venue, stock, id)
		order_to_cancel = {
			'venue' => venue,
			'stock' => stock,
			'order' => id
		}
		order_to_cancel_response = HTTParty.delete("#{@config["base_url"]}/venues/#{venue}/stocks/#{stock}/orders/#{id}",
												                       :headers => {'X-Starfighter-Authorization' => $@config["apikey"]}
												                       )
		puts order_to_cancel_response.body
	end
end
moment = require 'moment'
jwt_simple = require 'jwt-simple'

# ---

class Wallet
	constructor: (@seller_id, @seller_secret, @request_exp_in_s=3600) ->
		# pass
		
	get_subscription_payload: (name, description, seller_data, price, currency='USD', frequency='monthly', start_in_d=0) ->
		time_of_issue = moment()
		
		payload =
			iss: @seller_id
			
			aud: 'Google'
			typ: 'google/payments/inapp/subscription/v1'
			
			exp: moment(time_of_issue).add(@request_exp_in_s, 'seconds').unix()
			iat: time_of_issue.unix()
			
			request:
				name: name
				description: description
				
				sellerData: seller_data
				
				recurrence:
					price: price
					currencyCode: currency
					frequency: frequency
					
		if start_in_d > 0
			payload.request.initialPayment =
				price: 0
				currencyCode: currency
				paymentType: 'free_trial'
				
			payload.request.recurrence.startTime = moment(time_of_issue).add(start_in_d, 'days').unix()
			
		return payload
		
	get_subscription_token: (args...) ->
		payload = @get_subscription_payload args...
		
		return jwt_simple.encode payload, @seller_secret
		
	validate_subscription_token: (token) ->
		try
			payload = jwt_simple.decode token, @seller_secret
		catch
			throw new Error 'cannot decode jwt'
			
		throw new Error 'iss parameter is invalid' if payload.iss? != 'Google'
		throw new Error 'aud parameter is invalid' if payload.aud? != @seller_id
		throw new Error 'orderId parameter is invalid' if not payload.orderId?
		throw new Error 'sellerData parameter is invalid' if not payload.sellerData?
		throw new Error 'typ parameter is invalid' if not payload.typ?
		
		return payload
		
	handle_subscription_request: (req, res, next) ->
		jwt = req.param 'jwt'
		
		return res.send 400, 'no jwt specified' if not jwt
		
		try
			payload = @validate_subscription jwt
		catch e
			return send 400, e.message
			
		next payload
		
# ---

exports.Wallet = Wallet

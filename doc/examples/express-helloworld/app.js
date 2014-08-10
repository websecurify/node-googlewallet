var express = require('express');
var googlewallet = require('googlewallet');

// --

var wallet = new googlewallet.Wallet('seller_id', 'seller_secret');

// ---

var app = express();

// ---

app.get('/path/to/payment/page', function (req, res, next) {
	var token = wallet.get_subscription_token('name', 'description', {}, 5.0);
	
	res.render('payment.jade', {token: token});
});

app.post('/path/to/callback/handler', function (req, res, next) {
	wallet.handle_subscription_request(req, res, next, function (action, orderId, data, next) {
		
	});
});

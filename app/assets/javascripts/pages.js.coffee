$(function() {
 
	// Depends on: jQuery, jQuery UI core & widgets (for the autocomplete method)
	// Assumes you're already including the FB JS SDK asynchronously...
  
  		window.fbAsyncInit = function() {
 
		FB.init({
			appId      	: '567808586566843', // App ID
			status     	: true, // check login status
			cookie     	: true, // enable cookies to allow the server to access the session
			oauth		: true,
			xfbml		: true
		});	
		
		FB.getLoginStatus(function (response) {
			
			if (response.authResponse) {	// if the user is authorized...
				var accessToken = response.authResponse.accessToken
				var tokenUrl = "https://graph.facebook.com/me/friends?access_token=" + accessToken + "&callback=?"
 
				// Place <input id="name" /> and <input id="fbuid" /> into HTML
 
				$("#name").autocomplete({
					source: function(request, add) {
						$this = $(this)
						// Call out to the Graph API for the friends list
						$.ajax({
							url: tokenUrl,
							dataType: "jsonp",
							success: function(results){
								// Filter the results and return a label/value object array  
								var formatted = [];
								for(var i = 0; i< results.data.length; i++) {
									if (results.data[i].name.toLowerCase().indexOf($('#name').val().toLowerCase()) >= 0)
									formatted.push({
										label: results.data[i].name,
										value: results.data[i].id
									})
								}
								add(formatted);
							}
						});
					},
					select: function(event, ui) {
						// Fill in the input fields
						$('#name').val(ui.item.label)
						$('#fbuid').val(ui.item.value)
						// Prevent the value from being inserted in "#name"
						return false;
					},
					minLength: 2
				});
			}
		});
	};
});
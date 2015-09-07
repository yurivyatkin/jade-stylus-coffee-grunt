myFunction = () ->
	alert 'Hello! I am an alert box!'

# The following is required to resolve the scope problem:
window["myFunction"] = myFunction
# ... otherwise myFunction will not be defined for the browser
# See http://stackoverflow.com/questions/10458891/calling-functions-defined-with-coffee-script

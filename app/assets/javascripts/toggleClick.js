$.fn.toggleClick=function(){
	var functions=arguments, iteration=0;
	return this.click(function(){
    // console.log(this)
    // console.log(arguments)
		functions[iteration].apply(this,arguments);
		iteration= (iteration+1) %functions.length;
	})
}

$.fn.toggleClick=function(){
	var functions=arguments, iteration=0;
	return this.click(function(){
    // console.log(this)
    // console.log(arguments)
		functions[iteration].apply(this,arguments);
		iteration= (iteration+1) %functions.length;
	})
}

// $.fn.clicktoggle = function(a, b) {
//     return this.each(function() {
//         var clicked = false;
//         $(this).bind("click", function() {
//             if (clicked) {
//                 clicked = false;
//                 return b.apply(this, arguments);
//             }
//             clicked = true;
//             return a.apply(this, arguments);
//         });
//     });
// };

// function odd() {
//     alert("odd");
// }
// 
// function even() {
//     alert("even");
// }

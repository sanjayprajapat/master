({
    sliderInit : function(component, event, helper) {
        var num = "#slider"+component.get("v.temperature");
        var $slider = $(num);
        $slider.noUiSlider({
            start: [300000, 1500000],
            connect: true,
            step: 50000,
            range: {
                'min': 300000,
                'max': 1500000
            }
        });
    },
    
    showVal : function(component, event, helper){
        const minTempVal = component.get("v.minTempVal");
        //console.log('temperature-->'+component.get("v.temperature"));
    	//var climateVal = component.get("v.temperature");
        var slideVal = event.target.value;
        console.log('slideVal-->'+slideVal);
        
        var sliderDivBgColor = component.find("sliderDiv").getElement();
        //var sliderDivBgColor = document.getElementById("myRange");

        
        sliderDivBgColor.style.width = (slideVal - minTempVal) * 6.25 +'%' ;
        //console.log('width-->'+(slideVal - minTempVal) * 6.25);
        console.log('sliderDivBgColor width--->'+ sliderDivBgColor.style.width);
        if (slideVal >= 16 && slideVal < 21) {
            console.log('in if');
            //leafWindowDiv.style.background= leafBackgroundImage + 'linear-gradient(-90deg,rgba(8, 217, 141,0.7),rgba( 0, 148, 229,0.7))'; 
            //leafWindowDiv.style.backgroundSize = '105% 105%';
            sliderDivBgColor.style.background= 'linear-gradient(-90deg,rgba(8, 217, 141,0.7),rgba(120, 212, 240, 0.7))';
        }
        if (slideVal >= 21 && slideVal < 27) {
            console.log('in if');
            //leafWindowDiv.style.background= leafBackgroundImage + 'linear-gradient(-90deg,rgba(8, 217, 141,0.7),rgba( 0, 148, 229,0.7))'; 
            //leafWindowDiv.style.backgroundSize = '105% 105%';
            sliderDivBgColor.style.background='linear-gradient(-90deg,rgba(252, 254, 75, 0.7),rgba( 8, 217, 141, 0.7))'; 
        }
        
        if (slideVal >= 27 && slideVal < 32) {
            console.log('in if');
            //leafWindowDiv.style.background= leafBackgroundImage + 'linear-gradient(-90deg,rgba(8, 217, 141,0.7),rgba( 0, 148, 229,0.7))'; 
            //leafWindowDiv.style.backgroundSize = '105% 105%';
            sliderDivBgColor.style.background= 'linear-gradient(-90deg,rgba( 248, 98, 73, 0.7),rgba(252, 254, 75, 0.7))'; 
        }
        
        //const leafWindowDiv = component.find()
        
	},
    
})
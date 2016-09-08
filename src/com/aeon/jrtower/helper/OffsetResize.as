package com.aeon.jrtower.helper {
	/**
	 * @author md760
	 */
 //Import the needed classes for this object
    import flash.display.Sprite;
    import flash.display.DisplayObject;
    import flash.events.Event;
     
 
    //Creating a new class extending the Sprite class
    public class OffsetResize extends Sprite{
         
        //Create the static constants for maximum and minimum
        //We will use this for the offsetType property
        public static const MAX:String="max";
        public static const MIN:String="min";
 
        //The kind of the resize -- whether the image is bigger or smaller than the stage
        private var _offsetType:String;
         
        //The constructor function
        public function OffsetResize($child:DisplayObject,$offsetType:String="max"):void{
 
            //The offsetType; if no value is set the "max" value will be automatically assumed
            _offsetType=$offsetType;
 
            //Add the child here, any kind of DisplayObject
            addChild($child);
 
            //Check if this object is on stage. if so, call the init() function
            if(stage) init();
 
            //If it's not on stage it will listen for when it's added to the stage and then call the init() function
            else addEventListener(Event.ADDED_TO_STAGE,init);
 
            //This will check when this object is removed from the stage and call the end() function
            addEventListener(Event.REMOVED_FROM_STAGE,end);
        }
         
 
        //The init() function (called when the object is in the stage)
        //The Event=null parameter is because we used the init() without any parameter in the constructor
        // and because it's also used as an event listener (ADDED_TO_STAGE)
        private function init(e:Event=null):void{
 
            //Detect when the stage is resized and call the stageResize() function
            stage.addEventListener(Event.RESIZE,stageResize);
 
            //Call the stageResize() function now, too
            stageResize();
        }
         
        //The stageResize() function will be called every time the stage is resized
        //The e:Event=null parameter is because we have called the stageResize() function without a parameter
        private function stageResize(e:Event=null):void{
 
            //Calculate the width ratio by dividing the stage's width by the object's width
            var px:Number=stage.stageWidth/width;
 
            //Calculate the height ratio by dividing the stage's height by the object's height
            var py:Number=stage.stageHeight/height;
 
            /*
                This is the ternary operator; in one line it checks if _offsetType is "max".
                If so, it sets the variable div as the maximum value between the width's ratio and the height's ratio.
                If not, it sets the variable div as the minimum value between the width's ratio and the height's ratio.
                So, this line is responsible for whether the image is bigger or smaller than the stage.
            */
            var div:Number=_offsetType=="max" ? Math.max(px,py) : Math.min(px,py);
 
            //These two lines resize this object according to the division ratio.
            //If we use scaleX or scaleY here it wont work as we need it to.
            width*=div;
            height*=div;
 
            //These two lines are responsible for centering this object on the stage.
            x=(stage.stageWidth/2)-(width/2);
            y=(stage.stageHeight/2)-(height/2);
			trace("resize x: "+x +", y: "+y);
			trace("width : "+width +", height: "+height);
			
        }
         
        //This function is called when this object is removed from stage, as we don't need the stageResize() function any more
        private function end(e:Event):void{
            //Remove the RESIZE listener from the stage
            stage.removeEventListener(Event.RESIZE,stageResize);
        }
         
        /*
            Here we create the offsetType parameter, so we can change how the object
            resizes dynamically
        */
        public function set offsetType(type:String):void{
            _offsetType=type;
 
            //After changing the type we call stageResize function again to update
            if(stage) stageResize();
        }
         
        //Just for if we want to know what the offsetType is
        public function get offsetType():String{ return _offsetType; }
    }
}
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;
using Toybox.Application;
using Toybox.ActivityMonitor;
//using Toybox.Communications;






class EssentialView extends WatchUi.WatchFace {

		var scrHeight = null; // screeen stuff
		var scrRadius = null;
		//var scrCenterpoint = null;
		var i;  // counter for loops;
		
		
		var colBLACK       = 0x00000; // colors
		var colACCENT      = 0xFFFF00;
		var colTIME        = 0xFFFF00;
		//var colGRAY        = 0x555555;
		var colGRAY        = 0xAAAAAA;
		var colWHITE       = 0xFFFFFF;
		var colTRANSPARENT = Graphics.COLOR_TRANSPARENT;
		
		var dayOfWeekArr = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
		var monthOfYear  = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
							"Aug", "sep", "Oct", "Nov", "Dec"];
		
		var battCircleThickness = 7;
		var stepBarThickness = 6;
		var arcYPoint;
		var XSFont;
		var SFont;
		var BFont;
		var MFont;
		
		var drwSteps = 0;
		var timeStr1;
		var timeStr2;
		
		var steps;
		var goal;
		var needsRedraw;
		var HR = false;
		var fullRedraw = false;
		
		var time;
		var percentage;
		var complicationIcon;
		
		
		var battPercent = null;
		var oldBattPercent = 0;
		var dateString = 0;
		var oldDayOfWeek = null;
		var goalDrawn = false;
		
		var activityInfo = null;
		
		function initialize(){
			WatchFace.initialize();		
		}
		
		function onLayout(dc){
			if (ActivityMonitor.getInfo() has :floorsClimbed) { // and the setting is enabled. 	
				complicationIcon = WatchUi.loadResource(Rez.Drawables.StairsIcon);
            } else if (ActivityMonitor.getInfo() has :HSDf){ //heart rate field
				complicationIcon = WatchUi.loadResource(Rez.Drawables.HeartRate);
				HR = true;
            } else{
				complicationIcon = WatchUi.loadResource(Rez.Drawables.inherit);
			}
			
		
			XSFont= WatchUi.loadResource(Rez.Fonts.XTinyFont);
			SFont = WatchUi.loadResource(Rez.Fonts.smallFont);
			BFont = WatchUi.loadResource(Rez.Fonts.mediumFont);
			MFont = WatchUi.loadResource(Rez.Fonts.massiveFont);
		
			
			scrHeight = dc.getHeight();
			scrRadius = scrHeight / 2;
		
		
			
			arcYPoint = scrRadius - 20;
			
			dc.setColor(colBLACK, colTRANSPARENT);
			dc.fillCircle(scrRadius, scrRadius, scrRadius - battCircleThickness);
			
			
			
			dc.setColor(colGRAY, colTRANSPARENT);
			for(i = 0; i < stepBarThickness; i++){
				dc.drawArc(scrRadius, scrRadius, arcYPoint - i, 0, 210 + i / 4, 330 - i / 3.8);
			}
			
			
	
	
		}
		function onShow(){
				needsRedraw=true;
		}
		
		function onEnterSleep(){
				fullRedraw = false;
		}
		function onExitSleep(){
				fullRedraw = true;
		}
		
		function onUpdate(dc){
			time = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			if(time.day_of_week != oldDayOfWeek){
				onLayout(dc);
				
				drawDateString(dc);
			
				goalDrawn = false;
				needsRedraw= false;
			}
			
			if(fullRedraw==true){
				//dc.setColor(colBLACK, colBLACK);
				//dc.fillCirlce(scrRadius, scrRadius, scrRadius);
				drawDateString(dc);
				goalDrawn = false;
				drawBattComplication(dc);		
			}
			
			dc.setColor(colBLACK, colTRANSPARENT);
	
			dc.drawText(scrRadius + 4, scrRadius - 45, MFont, timeStr1, 0);
			dc.drawText(scrRadius + 8, scrRadius - 35, BFont, timeStr2, 2);
			time = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			dc.clearClip();
			
			//drawStepComplication(dc);
			drawComplication(dc);
		    
			
			
			battPercent = Sys.getSystemStats().battery;
	
			if((battPercent - oldBattPercent) > 0.4 || goalDrawn == false ){
				
				drawBattComplication(dc);
			}
			drawTimeString(dc);		
			
		}
	
		
		function drawBattComplication(dc){
			dc.clearClip();
			dc.setColor(colBLACK, colBLACK);
			dc.drawText(scrRadius, 10, 0, (oldBattPercent + 0.5).toNumber().toString() + "%", 1 );
			dc.setColor(colGRAY, colTRANSPARENT);
			dc.drawText(scrRadius, 10, 0, ((battPercent + 0.5).toNumber().toString() + "%"), 1 );
		
			dc.setColor(colBLACK, colTRANSPARENT);
			for(i = 0; i < battCircleThickness; i++){
				dc.drawArc(scrRadius, scrRadius, scrRadius - i, 0, 90, ((battPercent * 0.01) * 360) + 90);
			}
			dc.setColor(colACCENT, colTRANSPARENT);
			for(i = 0; i < battCircleThickness; i++){
				dc.drawArc(scrRadius, scrRadius, scrRadius - i, 0, 90, ((battPercent * 0.01) * 360) + 90);
				
			}
			
			oldBattPercent = battPercent;
		}
		
		function drawStepComplication(dc){
			dc.setColor(colBLACK, colTRANSPARENT);
			//dc.fillRectangle(90, arcYPoint + 65, 60, 18);
			dc.drawText(scrRadius, arcYPoint + 65, 0, steps, 1 );
			dc.drawText(scrRadius, 190, SFont, percentage + "%", 1);
			dc.setColor(colGRAY, colTRANSPARENT);
			dc.drawText(scrRadius, arcYPoint + 65, 0, ActivityMonitor.getInfo().steps, 1);
			
			activityInfo = ActivityMonitor.getInfo();
			steps = activityInfo.steps;
			goal = activityInfo.stepGoal;
			
			if (goalDrawn == false){
					dc.setColor(colGRAY, colTRANSPARENT);
					dc.drawText(202, 155, SFont, goal, 1);
					goalDrawn = true;
			}
			
			
			dc.setColor(colACCENT, colBLACK);
			
			if(steps > goal){
				 drwSteps = goal;
			} else {
					drwSteps = steps;
			}
			var math = 211 + (((drwSteps.toFloat()) / (goal.toFloat())) * 120);
			//Sys.println(math);
			for(i = 0; i < stepBarThickness; i++){
				dc.drawArc(scrRadius, scrRadius, arcYPoint - i, 0, 210 + i / 4, 
				(math > 300 ? (math - i / 3.8) : (math + 1) ) );
			}
			percentage = (((drwSteps.toFloat()) / (goal.toFloat())) * 100).toNumber().toString() ;
			dc.setColor(colGRAY, colTRANSPARENT);
			dc.drawText(scrRadius, 190, SFont, percentage + "%", 1);
			
			//steps = null;
			goal = null;
			activityInfo;
			//percentage = null;
		}
		
		function drawDateString(dc){
			time = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			oldDayOfWeek = time.day_of_week;
			dc.setColor(colACCENT, colTRANSPARENT);
			dc.drawText(scrRadius + (scrHeight / 30), scrRadius + 2, SFont, dayOfWeekArr[time.day_of_week], 2);
			dc.drawText(scrRadius + 24 + (scrHeight / 30), scrRadius + 2, SFont, time.day, 2);
			dc.drawText(scrRadius + (scrHeight / 30), scrRadius + 14, SFont, monthOfYear[time.month], 2);
			
		}
		
		function drawTimeString(dc){
			dc.setColor(colBLACK, colTRANSPARENT);
			time = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

			 timeStr1 = Lang.format("$1$", [time.hour]);
			 timeStr2 = Lang.format("$1$", [time.min(%02d)]);
		
		
				
			dc.setColor(colTIME, colTRANSPARENT);
			dc.drawText(scrRadius + 4, scrRadius - 45, MFont, timeStr1, 0);
			dc.drawText(scrRadius + 8, scrRadius - 35, BFont, timeStr2, 2);
	
		}
		
	
		
		function drawComplication(dc){
			
			dc.setColor(colBLACK, colTRANSPARENT);
			dc.fillRectangle(110, 51, 8, 10);
			dc.setColor(colGRAY, colTRANSPARENT);
			dc.drawBitmap(scrRadius - 15, 45, complicationIcon);
			dc.setColor(colWHITE, colTRANSPARENT);
			var tmp 
			if(HR == false){
				tmp = (activityInfo.floorsClimbed == null ?  0 :  activityInfo.floorsClimbed)
			} else if(HR == true){
				tmp = AcitivityMonitor.Heart
			}
			dc.drawText(scrRadius, 53, XSFont, , 1);	
			tmp = null;	
		}

}

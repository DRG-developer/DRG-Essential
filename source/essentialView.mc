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
		
		
		var colBLACK  = 0x000000;
		var colACCENT = 0xFFFF00; 
		var colTIME   = 0xFFFF00; 
		var colGRAY   = 0xAAAAAA;
		var colWHITE  = 0xFFFFFF;      
		
		var colTRANSPARENT = Graphics.COLOR_TRANSPARENT;
		
		var dayOfWeekArr = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
		var monthOfYear  = ["", "Jan", "Feb", "March", "April", "May", "June", "July",
							"Aug", "sep", "Oct", "Nov", "Dec"];
		
		var battCircleThickness = 7;
		var stepBarThickness = 6;
		var arcYPoint;
		var XSFont;
		var SFont;
		var BFont;
		var MFont;
		
		var stepY;
		var stepPerY; //stepPercentY
		var stepGoalX = 0;
		var venuY = 0;
		var venuY2 = 0;
		
		var restoreFromResume = 5;
		var BS_solv = 0;
		
		var drwSteps = 0;
		var timeStr1;
		var timeStr2;
		var production = true;
		
		var steps;
		var drwBatt = true;
		var goal;
		var needsRedraw;
		var datafield = 1; //-1 = none, 0 = stairs, 1= HR
		var fullRedraw = false;
		var alwaysRedrawBG = 0;
		
		var app = Application.getApp();
		var time;
		var percentage;
		var complicationIcon;
		
		var hiddenV = false;
		var battPercent = null;
		var oldBattPercent = 0;
		var dateString = 0;
		var oldDayOfWeek = null;
		var goalDrawn = false;
		
		var activityInfo = null;
		
		function initialize(){
			WatchFace.initialize();	
			getSett();	
		}
		

		
		function onLayout(dc){
			
			
			if (datafield == 0) { // stairs climbed
				complicationIcon = WatchUi.loadResource(Rez.Drawables.StairsIcon);
				
            } else if (datafield == 1){ //heart rate field
				complicationIcon = WatchUi.loadResource(Rez.Drawables.HeartRate);
			
            } else{
				complicationIcon = WatchUi.loadResource(Rez.Drawables.inherit);
			}
			
		
			XSFont= WatchUi.loadResource(Rez.Fonts.XTinyFont);
			SFont = WatchUi.loadResource(Rez.Fonts.smallFont);
			BFont = WatchUi.loadResource(Rez.Fonts.mediumFont);
			MFont = WatchUi.loadResource(Rez.Fonts.massiveFont);
		
		
			scrHeight = dc.getHeight();
			scrRadius = scrHeight / 2;
			
			if (scrHeight >= 390){
				MFont  = 17;
				BFont  = 15;
				venuY  = -40;
				venuY2 = -15;
				//SFont  = 0;
				battCircleThickness = 10;
				stepBarThickness = 8;
			}
			
			stepY       = scrRadius * 0.54;
			stepPerY    = scrRadius * 0.58;
			stepGoalX   = scrRadius * 0.66;	
		
			
			arcYPoint = scrRadius - 20;
			
			dc.setColor(colBLACK, colTRANSPARENT);
			dc.fillCircle(scrRadius, scrRadius, scrRadius);
			
			
			
			dc.setColor(colGRAY, colTRANSPARENT);
			for(i = 0; i < stepBarThickness; i++){
				dc.drawArc(scrRadius, scrRadius + venuY2, arcYPoint - i, 0, 210 + i / 4, 330 - i / 3.8);
			}
	
		}
		function getSett(){
			if(production == false){ return;}
			colGRAY       = switchCol(app.getProperty("colGray"));
			colACCENT     = switchCol(app.getProperty("colAccent"));
			colTIME       = switchCol(app.getProperty("colTime"));
			colBLACK      = switchCol(app.getProperty("colBg"));
			colWHITE      = 0xFFFFFF;
			colBLACK      = 0x000000;
			alwaysRedrawBG  = app.getProperty("redrawFullScr");
			datafield     = app.getProperty("DataField");
	
		}
		function switchCol(x){
			
			
			if(x == 0){
				return 0xFFFF00;
			} else if( x == 1){
				return 0xFFFF55;
			}
			else if( x == 2){
				return 0xAAAAAA;
			}
			else if( x == 3){
				return 0x555555;
			}
			else if( x == 4){
				return 0xFFFFFF;
			}
			else if( x == 5){
				return 0x000000;
			}
		}
		function onShow(){
				restoreFromResume = 0;
				WatchUi.requestUpdate();
			
		}
		
		function onHide(){
			hiddenV = true;
		
		}
			
		function onEnterSleep(){
				fullRedraw = false;
		}
		function onExitSleep(){
				fullRedraw = true;
				
		}
		
		function onUpdate(dc){
			dc.clearClip();
			dc.setColor(colBLACK, colBLACK);
			if(alwaysRedrawBG == 1){dc.fillCircle(scrRadius, scrRadius, scrRadius);}
			time = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			battPercent = Sys.getSystemStats().battery;
	
			if(hiddenV == true || fullRedraw == true || time.day_of_week != oldDayOfWeek || alwaysRedrawBG == 1){
				BS_solv ++;
				drwBatt = true;
				if(BS_solv >= 2){
					hiddenV = false;
					BS_solv = 0;
				}
				
				dc.setColor(colBLACK, colBLACK);
				dc.fillCircle(scrRadius, scrRadius, scrRadius);
				drawDateString(dc);
				goalDrawn = false;
				dc.setColor(colGRAY, colTRANSPARENT);
				for(i = 0; i < stepBarThickness; i++){
					dc.drawArc(scrRadius, scrRadius + venuY2, arcYPoint - i, 0, 210 + i / 4, 330 - i / 3.8);
				}
				
			}
				dc.setColor(colBLACK, colTRANSPARENT);
			
			
	
			dc.drawText(scrRadius + 4, scrRadius - 45 + venuY, MFont, timeStr1, 0);
			dc.drawText(scrRadius + 8, scrRadius - 35 + venuY, BFont, timeStr2, 2);
			time = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
	
			
			drawStepComplication(dc);
			drawComplication(dc);
		    
	
			

	
			if((battPercent - oldBattPercent) > 0.4 || goalDrawn == false || fullRedraw == true || drwBatt == true || alwaysRedrawBG == 1){
				drawDateString(dc);
				drawBattComplication(dc);
				drwBatt = false;
			}
			drawTimeString(dc);		
			
		}
		
		function onPartialUpdate(dc){
			if(restoreFromResume < 4){
				restoreFromResume ++;
				dc.setClip(0, 45, 40, 165);
				dc.setColor(colBLACK, colTRANSPARENT);
				dc.fillPolygon([[33, 52], [28, 91], [15, 124], [23, 168], [40, 198], [16, 212],  [0, 117], [15, 33] ]);
				drawBattComplication(dc);
				dc.clearClip();
			}
		}
	
		
		function drawBattComplication(dc){
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
			dc.drawText(scrRadius, arcYPoint + stepY, 0, steps, 1 );
			dc.drawText(scrRadius, scrRadius + stepPerY, SFont, percentage + "%", 1);
			dc.setColor(colGRAY, colTRANSPARENT);
			dc.drawText(scrRadius, arcYPoint + stepY, 0, ActivityMonitor.getInfo().steps, 1);
		
			activityInfo = ActivityMonitor.getInfo();
			steps = activityInfo.steps;
			goal = activityInfo.stepGoal;
			
			if (goalDrawn == false){
					dc.setColor(colGRAY, colTRANSPARENT);
					dc.drawText(scrRadius + stepGoalX, arcYPoint + stepY - 10 + venuY2, SFont, goal, 1);
					goalDrawn = true;
					
			}
			
			
			dc.setColor(colACCENT, colBLACK);
			
			if(steps > goal){
				 drwSteps = goal;
			} else {
					drwSteps = steps;
			}
			var math = 211 + (((drwSteps.toFloat()) / (goal.toFloat())) * 120);
			for(i = 0; i < stepBarThickness; i++){
				dc.drawArc(scrRadius, scrRadius + venuY2, arcYPoint - i, 0, 210 + i / 4, 
				(math > 300 ? (math - i / 3.8) : (math + 1) ) );
			}
			percentage = (((drwSteps.toFloat()) / (goal.toFloat())) * 100).toNumber().toString() ;
			dc.setColor(colGRAY, colTRANSPARENT);
			dc.drawText(scrRadius, scrRadius + stepPerY, SFont, percentage + "%", 1);
			
			//steps = null;
			goal = null;
			activityInfo;
			//percentage = null;
		}
		
		function drawDateString(dc){
			time = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			oldDayOfWeek = time.day_of_week;
			dc.setColor(colACCENT, colBLACK);
			dc.drawText(scrRadius + (scrHeight / 30), scrRadius + 2, SFont, dayOfWeekArr[time.day_of_week] + " " + time.day, 2);
			dc.drawText(scrRadius + (scrHeight / 30), scrRadius + 14, SFont, monthOfYear[time.month], 2);
			
		}
		
		function drawTimeString(dc){
			dc.setColor(colBLACK, colTRANSPARENT);
			time = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

			 timeStr1 = Lang.format("$1$", [time.hour]);
			 timeStr2 = Lang.format("$1$", [time.min.format("%02d")]);
		
		
				
			dc.setColor(colTIME, colTRANSPARENT);
			dc.drawText(scrRadius + 4, scrRadius - 45 + venuY, MFont, timeStr1, 0);
			dc.drawText(scrRadius + 8, scrRadius - 35 + venuY, BFont, timeStr2, 2);
	
		}
		
	
		
		function drawComplication(dc){
			
			
			if(datafield == -1) {
				return;
			}  
			
			dc.setColor(colWHITE, colTRANSPARENT);
			var sy = 53;
			var tmp = "0";
			if (datafield == 0){
				dc.setColor(colGRAY, colTRANSPARENT);
			    dc.drawBitmap(scrRadius - 10, 45, complicationIcon);
				tmp = (ActivityMonitor.getInfo().floorsClimbed == null ?  0 :  ActivityMonitor.getInfo().floorsClimbed);
				dc.setColor(colBLACK, colTRANSPARENT);
				dc.fillRectangle(110, 51, 8, 10);
			} else if(datafield == 1){
				sy = 48;
				dc.setColor(colGRAY, colTRANSPARENT);
			    dc.drawBitmap(scrRadius - 10, 45, complicationIcon);
				var hr =  ActivityMonitor.getHeartRateHistory(1, true).next();
			    tmp  = (hr.heartRate != ActivityMonitor.INVALID_HR_SAMPLE && hr.heartRate > 0) ? hr.heartRate : 0;
			    tmp = tmp.toString();
			}
		
			dc.setColor(colBLACK, colTRANSPARENT);
			dc.drawText(scrRadius, sy, XSFont, tmp , 1);	
			tmp = null;	
		}

}

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
		var colACCENT = 0x00AAFF; 
		var colTIME   = 0xFFFFFF; 
		var colGRAY   = 0xFFFFFF;
		var colWHITE  = 0xFFFFFF; 
		var colDATE   = 0x00AAFF;
		var colGOAL   = 0xFFFFFF;     
		var colTRANSPARENT = -1;
		
		/* DEPRECATED */
		var dayOfWeekArr = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
		var monthOfYear  = ["", "Jan", "Feb", "March", "April", "May", "June", "July",
							"Aug", "sep", "Oct", "Nov", "Dec"];
		/* CHANGE TO FORMAT MEDIUM*/
		
		
		var sy = 53;
		var battCircleThickness = 8;
		var stepBarThickness = 6;
		var arcYPoint;
		
		/* DEPRECATED */
		var XSFont;
		var SFont;
		var BFont;
		var MFont;
		/* CHANGE TO ONE FONT ARRAY */
		
		var DrawStepsPerc = true;
		var DrawStepsCount = true;
		var DrawStepsGoal = true;
		
		
		/* DEPRECATED*/
		var stepY;
		var stepPerY; //stepPercentY
		var stepGoalX = 0;
		var venuY = 0;
		var venuY2 = 0;
		var sx = 0;
		var bsop;
		var screenCanBurn = false;
		/* CHANGE TO JSONS OR SETTNGS, WHATEVER< JUST SMARTER*/
		
		var restoreFromResume = 5;
		/* DEPRECATED */
		var BS_solv = 0;
		var fontSizeTime, fontSizeDate;
		/* SHOULD BE REMOVED */
		
		var drwSteps = 0;
		
		/* POSSIBLY DEPRECATED*/
		var timeStr1;
		var timeStr2;
		/* USE ONE STRING WITH NEWLINE? */
		
		/* DEPRECATED */
		var production = true;
		/* will be removed */
		var tmpDraw;
		var drawZero;
		var steps;
		
		/* DEPRECATED */
		var venuSleep = false;
		var alwaysOn = false;
		/* BOTH MUST BE ON TO FUNCTION, SO JUST USE ONE VAR */
		
		/* POSSIBLY DEPRECATED*/
		var drwBatt = true;
		/* NOT YET KNOWN */
		
		var goal;
		/* DEPRECATED */
		var fullRedraw = false;
		var needsRedraw;
		var hiddenV = false;
		/* USE ONE VAR */
		var datafield = 1; //-1 = none, 0 = stairs, 1= HR
		
		var alwaysRedrawBG = 0;
		var twelveHClock;
		
		var app = Application.getApp();
		/* DEPRECATED */
		var time, timeHY, timeMY, dateYM, dateYD; //time hour and time date Y, month and day Y
		/* USE ARRAY OR DYNAMIC SETTTINGS */
		
		var percentage;
		var complicationIcon;
		
		
		var battPercent = null;
		var oldBattPercent = 0;
		/* DEPRECATED */
		var dateString = null;
		/* I DON'T SEE WHY THIS IS NECCESARY */
		
		var oldDayOfWeek = null;
		var goalDrawn = false;
		
		/* DEPRECATED */
		var activityInfo = null;
		/* BE LAZY AND USE GC INSTEAD ?*/
		
		function initialize(){
			WatchFace.initialize();	
			getSett();	
		}
		

		
		function onLayout(dc){
			
			
			if (datafield == 0) { // stairs climbed
				complicationIcon = WatchUi.loadResource(Rez.Drawables.StairsIcon);
				
            } else if (datafield == 1){ //heart rate field
				complicationIcon = WatchUi.loadResource(Rez.Drawables.HeartRate);
				sy = 48;
			
            } else{
				complicationIcon = WatchUi.loadResource(Rez.Drawables.inherit);
			}
			
			
			XSFont= WatchUi.loadResource(Rez.Fonts.XTinyFont);
			if (SFont == null){ SFont = WatchUi.loadResource(Rez.Fonts.SmallFont); }
			if (BFont == null){ BFont = WatchUi.loadResource(Rez.Fonts.MediumFont); }
			if (MFont == null){ MFont = WatchUi.loadResource(Rez.Fonts.MassiveFont); }
		
		
			scrHeight = dc.getHeight();
			scrRadius = scrHeight / 2;
			
			if (scrHeight >= 390){
				if (datafield == 0) { // stairs climbed
					complicationIcon = WatchUi.loadResource(Rez.Drawables.VenuStairs);
					sy = 60;
					sx = 12;
				} else if (datafield == 1){ //heart rate field
					complicationIcon = WatchUi.loadResource(Rez.Drawables.VenuRate);
					sx = 7;		
				}
				
				MFont  = 17;
				BFont  = 15;
				venuY  = -30;
				venuY2 = -12;
				dateYD =  -3;
				dateYM =  1;
				screenCanBurn = true;
				
			
				XSFont = WatchUi.loadResource(Rez.Fonts.XSmallFont);
				SFont  = WatchUi.loadResource(Rez.Fonts.XXXLSmallFont);
				battCircleThickness = 10;
				stepBarThickness = 8;
			}
			
			if (scrHeight >= 280){
				if (datafield == 0) { // stairs climbed
					complicationIcon = WatchUi.loadResource(Rez.Drawables.VenuStairs);
					sy = 60;
					sx = 12;
				} else if (datafield == 1){ //heart rate field
					complicationIcon = WatchUi.loadResource(Rez.Drawables.VenuRate);
					sx = 6;		
				}
				XSFont = WatchUi.loadResource(Rez.Fonts.XSmallFont);
			}
			
			stepY       = scrRadius * 0.54;
			stepPerY    = scrRadius * 0.58;
			stepGoalX   = scrRadius * 0.66;	
		
			
			arcYPoint = scrRadius - 20;
			
			dc.setColor(colBLACK, colTRANSPARENT);
			dc.fillCircle(scrRadius, scrRadius, scrRadius);
			
			
			
			dc.setColor(colGOAL, colTRANSPARENT);
			for(i = 0; i < stepBarThickness; i++){
				dc.drawArc(scrRadius, scrRadius + venuY2, arcYPoint - i, 0, 210 + i / 4, 330 - i / 3.8);
			}
	
		}
		
		
		
		function getSett(){
			colGRAY       = switchCol(app.getProperty("colGray"));
			colACCENT     = switchCol(app.getProperty("colAccent"));
			colTIME       = switchCol(app.getProperty("colTime"));
			colBLACK      = switchCol(app.getProperty("colBg"));
			colDATE       = switchCol(app.getProperty("colDate")); 
			colGOAL       = switchCol(app.getProperty("colGoal"));
			MFont         = switchCol2(app.getProperty("timeFont"), 0);
			BFont         = switchCol2(app.getProperty("timeFont"), 1);
			SFont         = switchCol2(app.getProperty("dateFont"), 2);
			drawZero      = app.getProperty("leadingHourZero");
			twelveHClock  = app.getProperty("twelveHClock");
			alwaysOn      = app.getProperty("venuAlwaysOn");
			switchCol3(app.getProperty("stepsConfig"));
			colWHITE      = 0xFFFFFF;
			//colBLACK      = 0x000000;
			alwaysRedrawBG  = app.getProperty("redrawFullScr");
			datafield     = app.getProperty("DataField");
		}
		
		function switchCol(x){
			
			switch(x) {
			case 0:
				return 0xFFFF55;
				break;		
			case 1:
				return 0xFFFF00;
				break;	
			case 2:
				return 0xAAAAAA;
				break;		
			case 3:
				return 0x555555;
				break; 			
			case 4:
				return 0xFFFFFF;
				break;			
			case 5:
				return 0x000000;
				break;		
			case 6:
				return 0xAA0000;
				break;	
			case 7:
				return 0xFF0000;
				break;	
			case 8:
				return 0x00AA00;
				break;	
			case 9:
				return 0x00FF00;			
			case 10:
				return 0x0000FF;
				break;			
			case 11:
				return 0x00AAFF;
				break;
			case 12:
				return 0xFF00FF;
				break;
			default:
				break;
		}
			
	}
		/* DEPRECATED */
		var venuOffset = [0, 0, 1];

function venuUpdate(dc){
				
	dc.drawText(scrRadius + venuOffset[0], scrRadius - 40 + venuOffset[1], 15, Sys.getClockTime().hour, 0);
	dc.drawText(scrRadius + venuOffset[0], scrRadius - 36 + venuOffset[1], 12, Sys.getClockTime().min.format("%02d"), 2);
	if(venuOffset[2] < 3){
		venuOffset[0] -= 8;
		venuOffset[1] -= 35;
		venuOffset[2] ++;
	} else if (venuOffset[2] < 7){
		venuOffset[0] += 8;
		venuOffset[1] += 35;
		venuOffset[2] ++;
	} else {
		venuOffset[0] -= 8;
		venuOffset[1] -= 35;
		venuOffset[2] = 0;	
	}	

			
}

/* move to seperate file*/
		
		
		function switchCol2(x, y){
				if(y == 0){
					if (x == 0){
						timeHY = 0;
						return WatchUi.loadResource(Rez.Fonts.MassiveFont);
					} else if (x == 1){
						timeHY = -5;
						return WatchUi.loadResource(Rez.Fonts.BiggerMassiveFont);
					} else if (x == 2){
						timeHY = -10;
						return WatchUi.loadResource(Rez.Fonts.XMassiveFont);
					} 
				} else if (y == 1){
					if (x == 0){
						timeMY = 0;
						return WatchUi.loadResource(Rez.Fonts.MediumFont);
					} else if (x == 1){
						timeMY = -5;
						return WatchUi.loadResource(Rez.Fonts.BiggerMediumFont);
					} else if (x == 2){
						timeMY = -8;
						return WatchUi.loadResource(Rez.Fonts.XMediumFont);
					}
				} else if (y == 2){
					if (x == 0){
						dateYD = 0;
						dateYM = 0;
						return WatchUi.loadResource(Rez.Fonts.SmallFont);
					} else if (x == 1){
						dateYD = 0;
						dateYM = 2;
						return WatchUi.loadResource(Rez.Fonts.BiggerSmallFont);
					} else if (x == 2){
						dateYD = 1;
						dateYM = 3;
						return WatchUi.loadResource(Rez.Fonts.XSmallFont); // logical naming scheme again... /sigh/ anyway, this means extra BIG small font.
					} else if (x == 3){
						dateYD = 1;
						dateYM = 4;
						return WatchUi.loadResource(Rez.Fonts.XLSmallFont); 
					}  else if (x == 4) {
						dateYD = 2;
						dateYM = 5;
						return WatchUi.loadResource(Rez.Fonts.XXLSmallFont); 
					} else if (x == 5) {
						dateYD = 3;
						dateYM = 7;
						return WatchUi.loadResource(Rez.Fonts.XXXLSmallFont); 
					}
				}
		}
		function switchCol3(x){
				switch (x){
				case 0:
					DrawStepsPerc = true;
					DrawStepsGoal = true;
					DrawStepsCount = true;
				case 1:
					DrawStepsPerc = false;
					DrawStepsGoal = true;
					DrawStepsCount = false;
				case 2:
					DrawStepsPerc = true;
					DrawStepsGoal = false;
					DrawStepsCount = false;
				case 3:
					DrawStepsPerc = false;
					DrawStepsGoal = false;
					DrawStepsCount = true;
				case 4:
					DrawStepsPerc = false;
					DrawStepsGoal = true;
					DrawStepsCount = true;
				case 5:
					DrawStepsPerc = true;
					DrawStepsGoal = true;
					DrawStepsCount = false;
				case 6:
					DrawStepsPerc = true;
					DrawStepsGoal = false;
					DrawStepsCount = true;
				case 7:
					DrawStepsPerc = false;
					DrawStepsGoal = false;
					DrawStepsCount = false;
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
				venuSleep = true;
				fullRedraw = false;
		}
		function onExitSleep(){
				venuSleep = false;
				fullRedraw = true;
				
		}
		
		

		
		
		function onUpdate(dc){
			if(venuSleep && screenCanBurn){
					dc.setColor(colGRAY, colBLACK);
					dc.clear();
					venuUpdate(dc);
					return;
			} 
			venuOffset = [0, 0, 1];
				//if (settingsChanged){ getSett();}
			dc.clearClip();
			dc.setColor(colBLACK, colBLACK);
			if(alwaysRedrawBG == 1){dc.fillCircle(scrRadius, scrRadius, scrRadius);}
			time = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			battPercent = Sys.getSystemStats().battery;
		
			if(hiddenV == true || fullRedraw == true ||tmpDraw == true || time.day_of_week != oldDayOfWeek || alwaysRedrawBG == 1){
					
				BS_solv ++;
				drwBatt = true;
				if(BS_solv >= 2){
					hiddenV = false;
					BS_solv = 0;
				}
					
				dc.setColor(colBLACK, colBLACK);
				dc.clear();
				drawDateString(dc);
				goalDrawn = false;
					
					
				dc.setColor(colGOAL, colTRANSPARENT);
				for(i = 0; i < stepBarThickness; i++){
					dc.drawArc(scrRadius, scrRadius + venuY2, arcYPoint - i, 0, 210 + i / 4, 330 - i / 3.8);
				}
				tmpDraw=false;
					
			}
				
				
			dc.setColor(colBLACK, colTRANSPARENT);
				
				
			dc.drawText(scrRadius + 4, scrRadius - 45 + venuY + timeHY, MFont, timeStr1, 0);
			dc.drawText(scrRadius + 8, scrRadius - 35 + venuY + timeMY, BFont, timeStr2, 2);
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
			if(screenCanBurn == true){
					dc.setColor(colGRAY, colBLACK);
					dc.clear();
					venuUpdate(dc);
					return;
			}
			if(restoreFromResume < 4){
				restoreFromResume ++;
				if(restoreFromResume == 4){
					tmpDraw = true;
					WatchUi.requestUpdate();
					dc.setClip(0, 45, 40, 165);
					dc.setColor(colBLACK, colTRANSPARENT);
					dc.fillPolygon([[33, 52], [28, 91], [15, 124], [23, 168], [40, 198], [16, 212],  [0, 117], [15, 33] ]);
					dc.clearClip();
				}
			}
		}
	
		
		function drawBattComplication(dc){
			dc.setColor(colBLACK, colBLACK);
			dc.drawText(scrRadius, 10, 0, (oldBattPercent + 0.5).toNumber().toString() + "%", 1 );
			dc.setColor(colGRAY, colTRANSPARENT);
			dc.drawText(scrRadius, 10, 0, ((battPercent + 0.5).toNumber().toString() + "%"), 1 );
			
			dc.setColor(colBLACK, colTRANSPARENT);
			for(i = -2; i < battCircleThickness; i++){
				dc.drawArc(scrRadius, scrRadius, scrRadius - i, 0, 90, ((battPercent * 0.01) * 360) + 90);
			}
			dc.setColor(colACCENT, colTRANSPARENT);
			for(i = -2; i < battCircleThickness; i++){
				dc.drawArc(scrRadius, scrRadius, scrRadius - i, 0, 90, ((battPercent * 0.01) * 360) + 90);
				
			}
			
			oldBattPercent = battPercent;
		}
		
		function drawStepComplication(dc){
		
			dc.setColor(colBLACK, colTRANSPARENT);
			dc.drawText(scrRadius, arcYPoint + stepY, 0, steps, 1 );
			dc.drawText(scrRadius, scrRadius + stepPerY, SFont, percentage + "%", 1);
			dc.setColor(colGRAY, colTRANSPARENT);
			if(DrawStepsCount == true){
				dc.drawText(scrRadius, arcYPoint + stepY, 0, ActivityMonitor.getInfo().steps, 1);
			}
		
			activityInfo = ActivityMonitor.getInfo();
			steps = activityInfo.steps;
			goal = activityInfo.stepGoal;
			
			if (goalDrawn == false && DrawStepsGoal == true){
					dc.setColor(colGRAY, colTRANSPARENT);
					dc.drawText(scrRadius + stepGoalX, arcYPoint + stepY - 13 + venuY2, SFont, goal, 1);
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
			if(DrawStepsPerc == true){
				dc.drawText(scrRadius, scrRadius + stepPerY, SFont, percentage + "%", 1);
			}
			
			//steps = null;
			goal = null;
			activityInfo;
			//percentage = null;
		}
		
		function drawDateString(dc){
			time = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			oldDayOfWeek = time.day_of_week;
			dc.setColor(colDATE, colBLACK);
			dc.drawText(scrRadius + (scrHeight / 30), scrRadius + 2 + dateYD, SFont, dayOfWeekArr[time.day_of_week] + " " + time.day, 2);
			dc.drawText(scrRadius + (scrHeight / 30), scrRadius + 14 + dateYM, SFont, monthOfYear[time.month], 2);
			
		}
		
		function drawTimeString(dc){
			dc.setColor(colBLACK, colTRANSPARENT);
			time = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

			 timeStr1 = time.hour.format((drawZero == 1 ? "%02d" : "%d" ));
			 timeStr2 = time.min.format("%02d");
			 
			 if(twelveHClock == 1 && timeStr1.toNumber() > 12 ) {
					timeStr1 =  (time.hour.toNumber() - 12).format((drawZero == 1 ? "%02d" : "%d" )).toString();
			 }
		
		
				
			dc.setColor(colTIME, colTRANSPARENT);
			dc.drawText(scrRadius + 4, scrRadius - 45 + venuY + timeHY, MFont, timeStr1, 0);
			dc.drawText(scrRadius + 8, scrRadius - 35 + venuY + timeMY, BFont, timeStr2, 2);
	
		}
		
	
		
		function drawComplication(dc){
			
			if(datafield == -1) {
				return;
			}  
			
			dc.setColor(colGRAY, colTRANSPARENT);
			
			var tmp = "-";
			if (datafield == 0){
				dc.setColor(colGRAY, colTRANSPARENT);
			    dc.drawBitmap(scrRadius - 10 -sx, 45 - venuY2, complicationIcon);
				tmp = (ActivityMonitor.getInfo().floorsClimbed == null ?  0 :  ActivityMonitor.getInfo().floorsClimbed);
				dc.setColor(colBLACK, colTRANSPARENT);
				dc.fillRectangle(110, 51, 8, 10);
			} else if(datafield == 1){
				
				dc.setColor(colGRAY, colTRANSPARENT);
			    dc.drawBitmap(scrRadius - 11 - sx, 45 - venuY2, complicationIcon);
				var hr =  ActivityMonitor.getHeartRateHistory(1, true).next();
			    tmp  = (hr.heartRate != ActivityMonitor.INVALID_HR_SAMPLE && hr.heartRate > 0) ? hr.heartRate : 0;
			    tmp = tmp.toString();
			}
		
			dc.setColor((datafield == 1 ? colBLACK : colGRAY), colTRANSPARENT);
			dc.drawText(scrRadius, sy - venuY2, XSFont, tmp , 1);	
			tmp = null;	
		}

}

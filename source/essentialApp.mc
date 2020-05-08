

using Toybox.Application;
using Toybox.Time;
using Toybox.WatchUi as Ui;

using Toybox.System as Sys;

// This is the primary entry point of the application.
class essentialWatch extends Application.AppBase
{
	var View;

    function initialize() {

        AppBase.initialize();
    }


    function onStart(state) {
		
    }



    function onStop(state) {
    }
    
    // This method runs each time the main application starts.
    function getInitialView() {
			View = new EssentialView();
				Ui.requestUpdate();
            return [View];
    }

	function onSettingsChanged(){
			View.getSett();
			View.tmpDraw = true;
			Ui.requestUpdate();
	}
}

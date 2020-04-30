

using Toybox.Application;
using Toybox.Time;

using Toybox.System as Sys;

// This is the primary entry point of the application.
class essentialWatch extends Application.AppBase
{


    function initialize() {

        AppBase.initialize();
    }


    function onStart(state) {
		
    }



    function onStop(state) {
    }
    
    // This method runs each time the main application starts.
    function getInitialView() {
            return [new EssentialView()];
    }

	function onSettingsChanged(){
			getSett();
	}
}

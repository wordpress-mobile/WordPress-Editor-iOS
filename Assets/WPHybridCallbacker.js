
// MARK: - Constructor

function WPHybridCallbacker() {
};

// MARK: - Callbacks

WPHybridCallbacker.prototype.callback = function(callbackScheme, callbackPath) {
    
    var url =  callbackScheme + ":";
    
    if (callbackPath) {
        url = url + callbackPath;
    }
    
    if (isUsingiOS) {
        this.callbackThroughIFrame(url);
    } else {
        console.log(url);
    }
};

/**
 *  @brief      Executes a callback by loading it into an IFrame.
 *  @details    The reason why we're using this instead of window.location is that window.location
 *              can sometimes fail silently when called multiple times in rapid succession.
 *              Found here:
 *              http://stackoverflow.com/questions/10010342/clicking-on-a-link-inside-a-webview-that-will-trigger-a-native-ios-screen-with/10080969#10080969
 *
 *  @param      url     The callback URL.
 */
WPHybridCallbacker.prototype.callbackThroughIFrame = function(url) {
    var iframe = document.createElement("IFRAME");
    iframe.setAttribute("src", url);
    
    // IMPORTANT: the IFrame was showing up as a black box below our text.  By setting its borders
    // to be 0px transparent we make sure it's not shown at all.
    //
    // REF BUG: https://github.com/wordpress-mobile/WordPress-iOS-Editor/issues/318
    //
    iframe.style.cssText = "border: 0px transparent;";
    
    document.documentElement.appendChild(iframe);
    iframe.parentNode.removeChild(iframe);
    iframe = null;
};
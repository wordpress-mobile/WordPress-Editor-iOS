/*!
 *
 * ZSSRichTextEditor v1.0
 * http://www.zedsaid.com
 *
 * Copyright 2013 Zed Said Studio
 *
 */


// If we are using iOS or desktop
var isUsingiOS = true;

// THe default callback parameter separator
var defaultCallbackSeparator = '~';

// The editor object
var ZSSEditor = {};

// These variables exist to reduce garbage (as in memory garbage) generation when typing real fast
// in the editor.
//
ZSSEditor.caretArguments = ['yOffset=' + 0, 'height=' + 0];
ZSSEditor.caretInfo = { y: 0, height: 0 };

// The current selection
ZSSEditor.currentSelection;

// The current editing image
ZSSEditor.currentEditingImage;

// The current editing link
ZSSEditor.currentEditingLink;

ZSSEditor.focusedField = null;

// The objects that are enabled
ZSSEditor.enabledItems = {};

ZSSEditor.editableFields = {};

ZSSEditor.lastTappedNode = null;

// The default paragraph separator
ZSSEditor.defaultParagraphSeparator = 'p';

/**
 * The initializer function that must be called onLoad
 */
ZSSEditor.init = function() {
    
    document.execCommand('insertBrOnReturn', false, false);
    document.execCommand('defaultParagraphSeparator', false, this.defaultParagraphSeparator);
    
    var editor = $('[contenteditable]').each(function() {
        var editableField = new ZSSField($(this));
        var editableFieldId = editableField.getNodeId();
                                             
        ZSSEditor.editableFields[editableFieldId] = editableField;
        ZSSEditor.callback("callback-new-field", "id=" + editableFieldId);
    });
    
	document.addEventListener("selectionchange", function(e) {
		ZSSEditor.currentEditingLink = null;
		// DRM: only do something here if the editor has focus.  The reason is that when the
		// selection changes due to the editor loosing focus, the focusout event will not be
		// sent if we try to load a callback here.
		//
		if (editor.is(":focus")) {
            ZSSEditor.selectionChangedCallback();
            ZSSEditor.sendEnabledStyles(e);
			var clicked = $(e.target);
			if (!clicked.hasClass('zs_active')) {
				$('img').removeClass('zs_active');
			}
		}
	}, false);

}; //end

// MARK: - Debugging logs

ZSSEditor.logMainElementSizes = function() {
    msg = 'Window [w:' + $(window).width() + '|h:' + $(window).height() + ']';
    this.log(msg);
    
    var msg = encodeURIComponent('Viewport [w:' + window.innerWidth + '|h:' + window.innerHeight + ']');
    this.log(msg);
    
    msg = encodeURIComponent('Body [w:' + $(document.body).width() + '|h:' + $(document.body).height() + ']');
    this.log(msg);
    
    msg = encodeURIComponent('HTML [w:' + $('html').width() + '|h:' + $('html').height() + ']');
    this.log(msg);
    
    msg = encodeURIComponent('Document [w:' + $(document).width() + '|h:' + $(document).height() + ']');
    this.log(msg);
};

// MARK: - Viewport Refreshing

ZSSEditor.refreshVisibleViewportSize = function() {
    $(document.body).css('min-height', window.innerHeight + 'px');
    $('#zss_field_content').css('min-height', (window.innerHeight - $('#zss_field_content').position().top) + 'px');
};

// MARK: - Fields

ZSSEditor.focusFirstEditableField = function() {
    $('div[contenteditable=true]:first').focus();
};

ZSSEditor.getField = function(fieldId) {
    
    var field = this.editableFields[fieldId];

    return field;
};

ZSSEditor.getFocusedField = function() {
    var currentField = $(this.closerParentNodeWithName('div'));
    var currentFieldId = currentField.attr('id');
    
    while (currentField
           && (!currentFieldId || this.editableFields[currentFieldId] == null)) {
        currentField = this.closerParentNodeStartingAtNode('div', currentField);
        currentFieldId = currentField.attr('id');
        
    }
    
    return this.editableFields[currentFieldId];
};

// MARK: - Logging

ZSSEditor.log = function(msg) {
	ZSSEditor.callback('callback-log', 'msg=' + msg);
};

// MARK: - Callbacks

ZSSEditor.domLoadedCallback = function() {
	
	ZSSEditor.callback("callback-dom-loaded");
};

ZSSEditor.selectionChangedCallback = function () {
    
    var joinedArguments = ZSSEditor.getJoinedFocusedFieldIdAndCaretArguments();
    
    ZSSEditor.callback('callback-selection-changed', joinedArguments);
    this.callback("callback-input", joinedArguments);
};

ZSSEditor.callback = function(callbackScheme, callbackPath) {
    
	var url =  callbackScheme + ":";
 
	if (callbackPath) {
		url = url + callbackPath;
	}
	
	if (isUsingiOS) {
        ZSSEditor.callbackThroughIFrame(url);
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
ZSSEditor.callbackThroughIFrame = function(url) {
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

ZSSEditor.stylesCallback = function(stylesArray) {

	var stylesString = '';
	
	if (stylesArray.length > 0) {
		stylesString = stylesArray.join(defaultCallbackSeparator);
	}

	ZSSEditor.callback("callback-selection-style", stylesString);
};

// MARK: - Selection

ZSSEditor.backupRange = function(){
	var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    
    ZSSEditor.currentSelection =
    {
        "startContainer": range.startContainer,
        "startOffset": range.startOffset,
        "endContainer": range.endContainer,
        "endOffset": range.endOffset
    };
};

ZSSEditor.restoreRange = function(){
    if (this.currentSelection) {
        var selection = window.getSelection();
        selection.removeAllRanges();
        
        var range = document.createRange();
        range.setStart(this.currentSelection.startContainer, this.currentSelection.startOffset);
        range.setEnd(this.currentSelection.endContainer, this.currentSelection.endOffset);
        selection.addRange(range);
    }
};

ZSSEditor.getSelectedText = function() {
	var selection = window.getSelection();
	
	return selection.toString();
};

ZSSEditor.getCaretArguments = function() {
    var caretInfo = this.getYCaretInfo();
    
    this.caretArguments[0] = 'yOffset=' + caretInfo.y;
    this.caretArguments[1] = 'height=' + caretInfo.height;
    
    return this.caretArguments;
};

ZSSEditor.getJoinedFocusedFieldIdAndCaretArguments = function() {
    
    var joinedArguments = ZSSEditor.getJoinedCaretArguments();
    var idArgument = "id=" + ZSSEditor.getFocusedField().getNodeId();
    
    joinedArguments = idArgument + defaultCallbackSeparator + joinedArguments;
    
    return joinedArguments;
};

ZSSEditor.getJoinedCaretArguments = function() {
    
    var caretArguments = this.getCaretArguments();
    var joinedArguments = this.caretArguments.join(defaultCallbackSeparator);
    
    return joinedArguments;
};

ZSSEditor.getYCaretInfo = function() {
    var y = 0, height = 0;
    var sel = window.getSelection();
    if (sel.rangeCount) {
        
        var range = sel.getRangeAt(0);
        var needsToWorkAroundNewlineBug = (range.startOffset == 0 || range.getClientRects().length == 0);
        
        // PROBLEM: iOS seems to have problems getting the offset for some empty nodes and return
        // 0 (zero) as the selection range top offset.
        //
        // WORKAROUND: To fix this problem we just get the node's offset instead.
        //
        if (needsToWorkAroundNewlineBug) {
            var closerParentNode = ZSSEditor.closerParentNode();
            var closerDiv = ZSSEditor.closerParentNodeWithName('div');
            
            var fontSize = $(closerParentNode).css('font-size');
            var lineHeight = Math.floor(parseInt(fontSize.replace('px','')) * 1.5);
            
            y = closerParentNode.offsetTop;
            height = lineHeight;
        } else {
            if (range.getClientRects) {
                var rects = range.getClientRects();
                if (rects.length > 0) {
                    // PROBLEM: some iOS versions differ in what is returned by getClientRects()
                    // Some versions return the offset from the page's top, some other return the
                    // offset from the visible viewport's top.
                    //
                    // WORKAROUND: see if the offset of the body's top is ever negative.  If it is
                    // then it means that the offset we have is relative to the body's top, and we
                    // should add the scroll offset.
                    //
                    var addsScrollOffset = document.body.getClientRects()[0].top < 0;
                    
                    if (addsScrollOffset) {
                        y = document.body.scrollTop;
                    }
                    
                    y += rects[0].top;
                    height = rects[0].height;
                }
            }
        }
    }
    
    this.caretInfo.y = y;
    this.caretInfo.height = height;
    
    return this.caretInfo;
};

// MARK: - Default paragraph separator

ZSSEditor.defaultParagraphSeparatorTag = function() {
    return '<' + this.defaultParagraphSeparator + '>';
};

// MARK: - Styles

ZSSEditor.setBold = function() {
	document.execCommand('bold', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setItalic = function() {
	document.execCommand('italic', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setSubscript = function() {
	document.execCommand('subscript', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setSuperscript = function() {
	document.execCommand('superscript', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setStrikeThrough = function() {
	var commandName = 'strikeThrough';
	var isDisablingStrikeThrough = ZSSEditor.isCommandEnabled(commandName);
	
	document.execCommand(commandName, false, null);
	
	// DRM: WebKit has a problem disabling strikeThrough when the tag <del> is used instead of
	// <strike>.  The code below serves as a way to fix this issue.
	//
	var mustHandleWebKitIssue = (isDisablingStrikeThrough
								 && ZSSEditor.isCommandEnabled(commandName));
	
	if (mustHandleWebKitIssue) {
		var troublesomeNodeNames = ['del'];
		
		var selection = window.getSelection();
		var range = selection.getRangeAt(0).cloneRange();
		
		var container = range.commonAncestorContainer;
		var nodeFound = false;
		var textNode = null;
		
		while (container && !nodeFound) {
			nodeFound = (container
						 && container.nodeType == document.ELEMENT_NODE
						 && troublesomeNodeNames.indexOf(container.nodeName.toLowerCase()) > -1);
			
			if (!nodeFound) {
				container = container.parentElement;
			}
		}
		
		if (container) {
			var newObject = $(container).replaceWith(container.innerHTML);
			
			var finalSelection = window.getSelection();
			var finalRange = selection.getRangeAt(0).cloneRange();
			
			finalRange.setEnd(finalRange.startContainer, finalRange.startOffset + 1);
			
			selection.removeAllRanges();
			selection.addRange(finalRange);
		}
	}
	
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setUnderline = function() {
	document.execCommand('underline', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setBlockquote = function() {
	var formatTag = "blockquote";
	var formatBlock = document.queryCommandValue('formatBlock');
	 
	if (formatBlock.length > 0 && formatBlock.toLowerCase() == formatTag) {
        document.execCommand('formatBlock', false, this.defaultParagraphSeparatorTag());
	} else {
		document.execCommand('formatBlock', false, '<' + formatTag + '>');
	}

	 ZSSEditor.sendEnabledStyles();
};

ZSSEditor.removeFormating = function() {
	document.execCommand('removeFormat', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setHorizontalRule = function() {
	document.execCommand('insertHorizontalRule', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setHeading = function(heading) {
	var formatTag = heading;
	var formatBlock = document.queryCommandValue('formatBlock');
	
	if (formatBlock.length > 0 && formatBlock.toLowerCase() == formatTag) {
		document.execCommand('formatBlock', false, this.defaultParagraphSeparatorTag());
	} else {
		document.execCommand('formatBlock', false, '<' + formatTag + '>');
	}
	
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setParagraph = function() {
	var formatTag = "p";
	var formatBlock = document.queryCommandValue('formatBlock');
	
	if (formatBlock.length > 0 && formatBlock.toLowerCase() == formatTag) {
		document.execCommand('formatBlock', false, this.defaultParagraphSeparatorTag());
	} else {
		document.execCommand('formatBlock', false, '<' + formatTag + '>');
	}
	
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.undo = function() {
	document.execCommand('undo', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.redo = function() {
	document.execCommand('redo', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setOrderedList = function() {
    document.execCommand('insertOrderedList', false, null);
    ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setUnorderedList = function() {
	document.execCommand('insertUnorderedList', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setJustifyCenter = function() {
	document.execCommand('justifyCenter', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setJustifyFull = function() {
	document.execCommand('justifyFull', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setJustifyLeft = function() {
	document.execCommand('justifyLeft', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setJustifyRight = function() {
	document.execCommand('justifyRight', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setIndent = function() {
	document.execCommand('indent', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setOutdent = function() {
	document.execCommand('outdent', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setTextColor = function(color) {
    ZSSEditor.restoreRange();
	document.execCommand("styleWithCSS", null, true);
	document.execCommand('foreColor', false, color);
	document.execCommand("styleWithCSS", null, false);
	ZSSEditor.sendEnabledStyles();
    // document.execCommand("removeFormat", false, "foreColor"); // Removes just foreColor
};

ZSSEditor.setBackgroundColor = function(color) {
	ZSSEditor.restoreRange();
	document.execCommand("styleWithCSS", null, true);
	document.execCommand('hiliteColor', false, color);
	document.execCommand("styleWithCSS", null, false);
	ZSSEditor.sendEnabledStyles();
};

// Needs addClass method

ZSSEditor.insertLink = function(url, title) {

    ZSSEditor.restoreRange();
	
    var sel = document.getSelection();
	if (sel.rangeCount) {

		var el = document.createElement("a");
		el.setAttribute("href", url);
		
		var range = sel.getRangeAt(0).cloneRange();
		range.surroundContents(el);
		el.innerHTML = title;
		sel.removeAllRanges();
		sel.addRange(range);
	}

	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.updateLink = function(url, title) {
	
    ZSSEditor.restoreRange();
	
    var currentLinkNode = ZSSEditor.lastTappedNode;
	
    if (currentLinkNode) {
		currentLinkNode.setAttribute("href", url);
		currentLinkNode.innerHTML = title;
    }
    ZSSEditor.sendEnabledStyles();
};

ZSSEditor.unlink = function() {
	
	var currentLinkNode = ZSSEditor.closerParentNodeWithName('a');
	
	if (currentLinkNode) {
		ZSSEditor.unwrapNode(currentLinkNode);
	}
	
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.updateImage = function(url, alt) {

    ZSSEditor.restoreRange();

    if (ZSSEditor.currentEditingImage) {
        var c = ZSSEditor.currentEditingImage;
        c.attr('src', url);
        c.attr('alt', alt);
    }
    ZSSEditor.sendEnabledStyles();

}; //end

ZSSEditor.unwrapNode = function(node) {
	var newObject = $(node).replaceWith(node.innerHTML);
};

ZSSEditor.quickLink = function() {
	
	var sel = document.getSelection();
	var link_url = "";
	var test = new String(sel);
	var mailregexp = new RegExp("^(.+)(\@)(.+)$", "gi");
	if (test.search(mailregexp) == -1) {
		checkhttplink = new RegExp("^http\:\/\/", "gi");
		if (test.search(checkhttplink) == -1) {
			checkanchorlink = new RegExp("^\#", "gi");
			if (test.search(checkanchorlink) == -1) {
				link_url = "http://" + sel;
			} else {
				link_url = sel;
			}
		} else {
			link_url = sel;
		}
	} else {
		checkmaillink = new RegExp("^mailto\:", "gi");
		if (test.search(checkmaillink) == -1) {
			link_url = "mailto:" + sel;
		} else {
			link_url = sel;
		}
	}

	var html_code = '<a href="' + link_url + '">' + sel + '</a>';
	ZSSEditor.insertHTML(html_code);
};

// MARK: - Images

/**
 *  @brief      Inserts a local image URL.  Useful for images that need to be uploaded.
 *  @details    By inserting a local image URL, we can make sure the image is shown to the user
 *              as soon as it's selected for uploading.  Once the image is successfully uploaded
 *              the application should call replaceLocalImageWithRemoteImage().
 *
 *  @param      imageNodeIndetifier     This is a unique ID provided by the caller.  It exists as
 *                                      a mechanism to update the image node with the remote URL
 *                                      when replaceLocalImageWithRemoteImage() is called.
 *  @param      localImageUrl           The URL of the local image to display.  Please keep in mind
 *                                      that a remote URL can be used here too, since this method
 *                                      does not check for that.  It would be a mistake.
 */
ZSSEditor.insertLocalImage = function(imageNodeIndentifier, localImageUrl) {
    var html = '<img id="' + imageNodeIndentifier + '" src="' + localImageUrl + '" alt="" />';
    
    this.insertHTML(html);
    this.sendEnabledStyles();
};

ZSSEditor.insertImage = function(url, alt) {
    var html = '<img src="'+url+'" alt="'+alt+'" />';
    
    this.insertHTML(html);
    this.sendEnabledStyles();
};

/**
 *  @brief      Replaces a local image URL with a remote image URL.  Useful for images that have
 *              just finished uploading.
 *  @details    The remote image can be available after a while, when uploading images.  This method
 *              allows for the remote URL to be loaded once the upload completes.
 *
 *  @param      imageNodeIndetifier     This is a unique ID provided by the caller.  It exists as
 *                                      a mechanism to update the image node with the remote URL
 *                                      when replaceLocalImageWithRemoteImage() is called.
 *  @param      remoteImageUrl          The URL of the remote image to display.
 */
ZSSEditor.replaceLocalImageWithRemoteImage = function(imageNodeIndentifier, remoteImageUrl) {
    
    var imageNode = $('#' + imageNodeIndentifier);
    
    if (imageNode) {
        var image = new Image;
        
        image.onload = function () {
            imageNode.attr('src', image.src);
            
            var joinedArguments = ZSSEditor.getJoinedFocusedFieldIdAndCaretArguments();
            ZSSEditor.callback("callback-input", joinedArguments);
        }
        
        image.onerror = function () {
            // Even on an error, we swap the image for the time being.  This is because private
            // blogs are currently failing to download images due to access privilege issues.
            //
            imageNode.attr('src', image.src);
            
            var joinedArguments = ZSSEditor.getJoinedFocusedFieldIdAndCaretArguments();
            ZSSEditor.callback("callback-input", joinedArguments);
        }
        
        image.src = remoteImageUrl;
    }
};

/**
 *  @brief      Changes the progress indicator for the image with the value set.
 *
 *  @details
 *
 *
 *  @param      imageNodeIdentifier     This is a unique ID provided by the caller.  It exists as
 *                                      a mechanism to update the image node with the remote URL
 *                                      when replaceLocalImageWithRemoteImage() is called.
 *  @param      progress          A value between 0 and 1 indicating the progress on the image.
 */
ZSSEditor.setProgressOnImage = function(imageNodeIdentifier, progress) {
    var element = document.getElementById(imageNodeIdentifier);
    if (!element){
        return;
    }
    if (progress >=1){
        element.style.opacity = 1;
    } else {
        element.style.opacity = 0.2 + (0.6*progress);
    }
    
    var progressElement = document.getElementById('progress-'+imageNodeIdentifier);
    if (!progressElement){
        progressElement = document.createElement("progress");
        progressElement.id = 'progress-'+ imageNodeIdentifier;
        progressElement.max = 100;
        progressElement.value = 0;
        progressElement.contentEditable = false;
        element.parentNode.insertBefore(progressElement, element);        
    }
    progressElement.value = 100 * progress;
    if (progress >=1){
        progressElement.parentNode.removeChild(progressElement);
    }
};

/**
 *  @brief      Marks the image as failed to upload
 *
 *  @details
 *
 *
 *  @param      imageNodeIdentifier     This is a unique ID provided by the caller.
 */
ZSSEditor.markImageAsFailed = function(imageNodeIdentifier) {
    var element = $('#'+imageNodeIdentifier);
    if (!element){
        return;
    }
    element.addClass('failed');
    
    var progressElement = $('#progress-'+imageNodeIdentifier);
    if (progressElement){
        progressElement.remove();
    }
};

// MARK: - Commands

ZSSEditor.insertHTML = function(html) {
	document.execCommand('insertHTML', false, html);
	this.sendEnabledStyles();
};

ZSSEditor.isCommandEnabled = function(commandName) {
	return document.queryCommandState(commandName);
};

ZSSEditor.sendEnabledStyles = function(e) {

	var items = [];
	
    var focusedField = this.getFocusedField();
    
    if (!focusedField.hasNoStyle) {
        // Find all relevant parent tags
        var parentTags = ZSSEditor.parentTags();
        
        for (var i = 0; i < parentTags.length; i++) {
            var currentNode = parentTags[i];
            
            if (currentNode.nodeName.toLowerCase() == 'a') {
                ZSSEditor.currentEditingLink = currentNode;
                
                var title = encodeURIComponent(currentNode.text);
                var href = encodeURIComponent(currentNode.href);
                
                items.push('link-title:' + title);
                items.push('link:' + href);
            }
        }
        
        if (ZSSEditor.isCommandEnabled('bold')) {
            items.push('bold');
        }
        if (ZSSEditor.isCommandEnabled('createLink')) {
            items.push('createLink');
        }
        if (ZSSEditor.isCommandEnabled('italic')) {
            items.push('italic');
        }
        if (ZSSEditor.isCommandEnabled('subscript')) {
            items.push('subscript');
        }
        if (ZSSEditor.isCommandEnabled('superscript')) {
            items.push('superscript');
        }
        if (ZSSEditor.isCommandEnabled('strikeThrough')) {
            items.push('strikeThrough');
        }
        if (ZSSEditor.isCommandEnabled('underline')) {
            var isUnderlined = false;
            
            // DRM: 'underline' gets highlighted if it's inside of a link... so we need a special test
            // in that case.
            if (!ZSSEditor.currentEditingLink) {
                items.push('underline');
            }
        }
        if (ZSSEditor.isCommandEnabled('insertOrderedList')) {
            items.push('orderedList');
        }
        if (ZSSEditor.isCommandEnabled('insertUnorderedList')) {
            items.push('unorderedList');
        }
        if (ZSSEditor.isCommandEnabled('justifyCenter')) {
            items.push('justifyCenter');
        }
        if (ZSSEditor.isCommandEnabled('justifyFull')) {
            items.push('justifyFull');
        }
        if (ZSSEditor.isCommandEnabled('justifyLeft')) {
            items.push('justifyLeft');
        }
        if (ZSSEditor.isCommandEnabled('justifyRight')) {
            items.push('justifyRight');
        }
        if (ZSSEditor.isCommandEnabled('insertHorizontalRule')) {
            items.push('horizontalRule');
        }
        var formatBlock = document.queryCommandValue('formatBlock');
        if (formatBlock.length > 0) {
            items.push(formatBlock);
        }
        
        // Use jQuery to figure out those that are not supported
        if (typeof(e) != "undefined") {
            
            // The target element
            var t = $(e.target);
            var nodeName = e.target.nodeName.toLowerCase();
            
            // Background Color
            try
            {
                var bgColor = t.css('backgroundColor');
                if (bgColor && bgColor.length != 0 && bgColor != 'rgba(0, 0, 0, 0)' && bgColor != 'rgb(0, 0, 0)' && bgColor != 'transparent') {
                    items.push('backgroundColor');
                }
            }
            catch(e)
            {
                // DRM: I had to add these stupid try-catch blocks to solve an issue with t.css throwing
                // exceptions for no reason.
            }
            
            // Text Color
            try
            {
                var textColor = t.css('color');
                if (textColor && textColor.length != 0 && textColor != 'rgba(0, 0, 0, 0)' && textColor != 'rgb(0, 0, 0)' && textColor != 'transparent') {
                    items.push('textColor');
                }
            }
            catch(e)
            {
                // DRM: I had to add these stupid try-catch blocks to solve an issue with t.css throwing
                // exceptions for no reason.
            }
            
            // Blockquote
            if (nodeName == 'blockquote') {
                items.push('indent');
            }
            // Image
            if (nodeName == 'img') {
                ZSSEditor.currentEditingImage = t;
                items.push('image:'+t.attr('src'));
                if (t.attr('alt') !== undefined) {
                    items.push('image-alt:'+t.attr('alt'));
                }
                
            } else {
                ZSSEditor.currentEditingImage = null;
            }
        }
    }
	
	ZSSEditor.stylesCallback(items);
};

// MARK: - Parent nodes & tags

ZSSEditor.closerParentNode = function() {
    
    var parentNode = null;
    var selection = window.getSelection();
    var range = selection.getRangeAt(0).cloneRange();
    
    var currentNode = range.commonAncestorContainer;
    
    while (currentNode) {
        if (currentNode.nodeType == document.ELEMENT_NODE) {
            parentNode = currentNode;
            
            break;
        }
        
        currentNode = currentNode.parentElement;
    }
    
    return parentNode;
};

ZSSEditor.closerParentNodeStartingAtNode = function(nodeName, startingNode) {
    
    nodeName = nodeName.toLowerCase();
    
    var parentNode = null;
    var currentNode = startingNode,parentElement;
    
    while (currentNode) {
        
        if (currentNode.nodeName == document.body.nodeName) {
            break;
        }
        
        if (currentNode.nodeName.toLowerCase() == nodeName
            && currentNode.nodeType == document.ELEMENT_NODE) {
            parentNode = currentNode;
            
            break;
        }
        
        currentNode = currentNode.parentElement;
    }
    
    return parentNode;
};

ZSSEditor.closerParentNodeWithName = function(nodeName) {
    
    nodeName = nodeName.toLowerCase();
    
    var parentNode = null;
    var selection = window.getSelection();
    var range = selection.getRangeAt(0).cloneRange();
    
    var currentNode = range.commonAncestorContainer;
    
    while (currentNode) {
        
        if (currentNode.nodeName == document.body.nodeName) {
            break;
        }
        
        if (currentNode.nodeName.toLowerCase() == nodeName
            && currentNode.nodeType == document.ELEMENT_NODE) {
            parentNode = currentNode;
            
            break;
        }
        
        currentNode = currentNode.parentElement;
    }
    
    return parentNode;
};

ZSSEditor.parentTags = function() {
    
    var parentTags = [];
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    
    var currentNode = range.commonAncestorContainer;
    while (currentNode) {
        
        if (currentNode.nodeName == document.body.nodeName) {
            break;
        }
        
        if (currentNode.nodeType == document.ELEMENT_NODE) {
            parentTags.push(currentNode);
        }
        
        currentNode = currentNode.parentElement;
    }
    
    return parentTags;
};

// MARK: - ZSSField Constructor

function ZSSField(wrappedObject) {
    this.multiline = false;
    this.wrappedObject = wrappedObject;
    this.bodyPlaceholderColor = '#000000';
    
    if (this.wrappedDomNode().hasAttribute('nostyle')) {
        this.hasNoStyle = true;
    }
    
    this.bindListeners();
};

ZSSField.prototype.bindListeners = function() {
    
    var thisObj = this;
    
    this.wrappedObject.bind('tap', function(e) { thisObj.handleTapEvent(e); });
    this.wrappedObject.bind('focus', function(e) { thisObj.handleFocusEvent(e); });
    this.wrappedObject.bind('blur', function(e) { thisObj.handleBlurEvent(e); });
    this.wrappedObject.bind('keydown', function(e) { thisObj.handleKeyDownEvent(e); });
    this.wrappedObject.bind('input', function(e) { thisObj.handleInputEvent(e); });
};

// MARK: - Emptying the field when it should be, well... empty (HTML madness)

/**
 *  @brief      Sometimes HTML leaves some <br> tags or &nbsp; when the user deletes all
 *              text from a contentEditable field.  This code makes sure no such 'garbage' survives.
 *  @details    If the node contains child image nodes, then the content is left untouched.
 */
ZSSField.prototype.emptyFieldIfNoContents = function() {

    var nbsp = '\xa0';
    var text = this.wrappedObject.text().replace(nbsp, '');
    
    if (text.length == 0) {
        
        var hasChildImages = (this.wrappedObject.find('img').length > 0);
        
        if (!hasChildImages) {
            this.wrappedObject.empty();
        }
    }
};

ZSSField.prototype.emptyFieldIfNoContentsAndRefreshPlaceholderColor = function() {
    this.emptyFieldIfNoContents();
    this.refreshPlaceholderColor();
};

// MARK: - Handle event listeners

ZSSField.prototype.handleBlurEvent = function(e) {
    ZSSEditor.focusedField = null;
    
    this.emptyFieldIfNoContentsAndRefreshPlaceholderColor();
    
    this.callback("callback-focus-out");
};

ZSSField.prototype.handleFocusEvent = function(e) {
    ZSSEditor.focusedField = this;
    
    // IMPORTANT: this is the only case where checking the current focus will not work.
    // We sidestep this issue by indicating that the field is about to gain focus.
    //
    this.refreshPlaceholderColorAboutToGainFocus(true);
    this.callback("callback-focus-in");
};

ZSSField.prototype.handleKeyDownEvent = function(e) {
    
    // IMPORTANT: without this code, we can have text written outside of paragraphs...
    //
    if (ZSSEditor.closerParentNode() == this.wrappedDomNode()) {
        document.execCommand('formatBlock', false, 'p');
    }
};

ZSSField.prototype.handleInputEvent = function(e) {
    
    // IMPORTANT: we want the placeholder to come up if there's no text, so we clear the field if
    // there's no real content in it.  It's important to do this here and not on keyDown or keyUp
    // as the field could become empty because of a cut or paste operation as well as a key press.
    // This event takes care of all cases.
    //
    this.emptyFieldIfNoContentsAndRefreshPlaceholderColor();
    
    var joinedArguments = ZSSEditor.getJoinedFocusedFieldIdAndCaretArguments();

    ZSSEditor.callback('callback-selection-changed', joinedArguments);
    this.callback("callback-input", joinedArguments);
};

ZSSField.prototype.handleTapEvent = function(e) {
    var targetNode = e.target;
    
    if (targetNode) {
        
        ZSSEditor.lastTappedNode = targetNode;
        
        if (targetNode.nodeName.toLowerCase() == 'a') {
            var arguments = ['url=' + encodeURIComponent(targetNode.href),
                             'title=' + encodeURIComponent(targetNode.innerHTML)];
            
            var joinedArguments = arguments.join(defaultCallbackSeparator);
            
            var thisObj = this;
            
            // WORKAROUND: force the event to become sort of "after-tap" through setTimeout()
            //
            setTimeout(function() { thisObj.callback('callback-link-tap', joinedArguments);}, 500);
        }
        if (targetNode.nodeName.toLowerCase() == 'img') {
            $('img').removeClass('zs_active');
            $(targetNode).addClass('zs_active');
            var arguments = ['id=' + encodeURIComponent(targetNode.id),
                             'title=' + encodeURIComponent(targetNode.src)];
            
            var joinedArguments = arguments.join(defaultCallbackSeparator);
            
            var thisObj = this;
            
            // WORKAROUND: force the event to become sort of "after-tap" through setTimeout()
            //
            setTimeout(function() { thisObj.callback('callback-image-tap', joinedArguments);}, 500);
        }
    }
};

// MARK: - Callback Execution

ZSSField.prototype.callback = function(callbackScheme, callbackPath) {
    
    var url = callbackScheme + ":";
    
    url = url + "id=" + this.getNodeId();

    if (callbackPath) {
        url = url + defaultCallbackSeparator + callbackPath;
    }
    
    if (isUsingiOS) {
        ZSSEditor.callbackThroughIFrame(url);
    } else {
        console.log(url);
    }
};

// MARK: - Focus

ZSSField.prototype.isFocused = function() {

    return this.wrappedObject.is(':focus');
};

ZSSField.prototype.focus = function() {
    
    if (!this.isFocused()) {
        this.wrappedObject.focus();
    }
};

ZSSField.prototype.blur = function() {
    if (this.isFocused()) {
        this.wrappedObject.blur();
    }
};

// MARK: - Multiline support

ZSSField.prototype.isMultiline = function() {
    return this.multiline;
};

ZSSField.prototype.setMultiline = function(multiline) {
    this.multiline = multiline;
};

// MARK: - NodeId

ZSSField.prototype.getNodeId = function() {
    return this.wrappedObject.attr('id');
};

// MARK: - Editing

ZSSField.prototype.enableEditing = function () {
    
    this.wrappedObject.attr('contenteditable', true);
    
    if (!ZSSEditor.focusedField) {
        ZSSEditor.focusFirstEditableField();
    }
};

ZSSField.prototype.disableEditing = function () {
    // IMPORTANT: we're blurring the field before making it non-editable since that ensures
    // that the iOS keyboard is dismissed through an animation, as opposed to being immediately
    // removed from the screen.
    //
    this.blur();
    
    this.wrappedObject.attr('contenteditable', false);
};

// MARK: - i18n

ZSSField.prototype.isRightToLeftTextEnabled = function() {
    var textDir = this.wrappedObject.attr('dir');
    var isRTL = (textDir != "undefined" && textDir == 'rtl');
    return isRTL;
};

ZSSField.prototype.enableRightToLeftText = function(isRTL) {
    var textDirectionString = isRTL ? "rtl" : "ltr";
    this.wrappedObject.attr('dir', textDirectionString);
    this.wrappedObject.css('direction', textDirectionString);
};

// MARK: - HTML contents

ZSSField.prototype.isEmpty = function() {
    var html = this.getHTML();
    var isEmpty = (html.length == 0 || html == "<br>");
    
    return isEmpty;
};

ZSSField.prototype.getHTML = function() {
    return this.wrappedObject.html();
};

ZSSField.prototype.strippedHTML = function() {
    return this.wrappedObject.text();
};

ZSSField.prototype.setHTML = function(html) {
    this.wrappedObject.html(html);
    this.refreshPlaceholderColor();
};

// MARK: - Placeholder

ZSSField.prototype.hasPlaceholderText = function() {
    return this.wrappedObject.attr('placeholderText') != null;
};

ZSSField.prototype.setPlaceholderText = function(placeholder) {
    
    this.wrappedObject.attr('placeholderText', placeholder);
};

ZSSField.prototype.setPlaceholderColor = function(color) {
    this.bodyPlaceholderColor = color;
    this.refreshPlaceholderColor();
};

ZSSField.prototype.refreshPlaceholderColor = function() {
     this.refreshPlaceholderColorForAttributes(this.hasPlaceholderText(),
                                               this.isFocused(),
                                               this.isEmpty());
};

ZSSField.prototype.refreshPlaceholderColorAboutToGainFocus = function(willGainFocus) {
    this.refreshPlaceholderColorForAttributes(this.hasPlaceholderText(),
                                              willGainFocus,
                                              this.isEmpty());
};

ZSSField.prototype.refreshPlaceholderColorForAttributes = function(hasPlaceholderText, isFocused, isEmpty) {
    
    var shouldColorText = hasPlaceholderText && isEmpty;
    
    if (shouldColorText) {
        if (isFocused) {
            this.wrappedObject.css('color', this.bodyPlaceholderColor);
        } else {
            this.wrappedObject.css('color', this.bodyPlaceholderColor);
        }
    } else {
        this.wrappedObject.css('color', '');
    }
    
};

// MARK: - Wrapped Object

ZSSField.prototype.wrappedDomNode = function() {
    return this.wrappedObject[0];
};

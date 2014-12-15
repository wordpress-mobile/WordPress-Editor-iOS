#import <UIKit/UIKit.h>

#import "ZSSTextView.h"

@class WPEditorView;
@class WPEditorField;
@class WPImageMeta;

@protocol WPEditorViewDelegate <UIWebViewDelegate>
@optional

/**
 *	@brief		Received when the editor text is changed.
 *
 *	@param		editorView		The editor view.
 */
- (void)editorTextDidChange:(WPEditorView*)editorView;

/**
 *	@brief		Received when the editor title is changed.
 *
 *	@param		editorView		The editor view.
 */
- (void)editorTitleDidChange:(WPEditorView*)editorView;

/**
 *	@brief		Received when the underlying web content's DOM is ready.
 *	@details	The content never completely loads while offline under some circumstances.
 *				This event offers an alternative to start working on the page's contents.
 *
 *	@param		editorView		The editor view.
 */
- (void)editorViewDidFinishLoadingDOM:(WPEditorView*)editorView;

/**
 *	@brief		Received when all of the web content is ready.
 *	@details	The content never completely loads while offline under some circumstances.
 *				This event offers an alternative to start working on the page's contents.
 *
 *	@param		editorView		The editor view.
 */
- (void)editorViewDidFinishLoading:(WPEditorView*)editorView;

/**
 *	@brief		Received when the editor creates one of it's fields.
 *  @details    The editor fields will be nil before this method is called.  This is because editor
 *              fields are created as part of the process of loading the HTML.
 *
 *	@param		editorView		The editor view.
 *	@param		field			The new field.
 */
- (void)editorView:(WPEditorView*)editorView
      fieldCreated:(WPEditorField*)field;

/**
 *	@brief		Received when the editor focus changes.
 *
 *	@param		editorView		The editor view.
 *	@param		field			The focused field.
 */
- (void)editorView:(WPEditorView*)editorView
	  fieldFocused:(WPEditorField*)field;

/**
 *	@brief		Received when the user taps on a link in the editor.
 *
 *	@param		editorView		The editor view.
 *	@param		url				The url that should be loaded.
 *	@param		title			The title of the link that was tapped.
 *
 *	@return		YES if the tap was handled by the receiver and default handler should be supressed,
 *				NO if it wasn't.
 */
- (BOOL)editorView:(WPEditorView*)editorView
		linkTapped:(NSURL*)url
			 title:(NSString*)title;

/**
 *	@brief		Received when the user taps on a image in the editor.
 *
 *	@param		editorView	The editor view.
 *	@param		imageId		The id of image of the image that was tapped.
 *	@param		url			The url of the image that was tapped.
 *
 *	@return		YES if the tap was handled by the receiver and default handler should be supressed,
 *				NO if it wasn't.
 */
- (BOOL)editorView:(WPEditorView*)editorView
        imageTapped:(NSString *)imageId
                url:(NSURL *)url;

- (BOOL)editorView:(WPEditorView*)editorView
       imageTapped:(NSString *)imageId
               url:(NSURL *)url
         imageMeta:(WPImageMeta *)imageMeta;

/**
 *	@brief		Received when the selection is changed.
 *	@details	Useful to know what styles surround the current selection.
 *
 *	@param		editorView		The editor view.
 *	@param		styles			The styles that surround the current selection.
 */
-        (void)editorView:(WPEditorView*)editorView
stylesForCurrentSelection:(NSArray*)styles;
@end

@interface WPEditorView : UIView

/**
 *	@brief		The editor's delegate.
 */
@property (nonatomic, weak, readwrite) id<WPEditorViewDelegate> delegate;

/**
 *	@brief		Stores the current edit mode state for this view.
 */
@property (nonatomic, assign, readonly, getter = isEditing) BOOL editing;

#pragma mark - Properties: Selection
@property (nonatomic, strong, readonly) NSString *selectedLinkTitle;
@property (nonatomic, strong, readonly) NSString *selectedLinkURL;

#pragma mark - Properties: Fields
@property (nonatomic, strong, readonly) WPEditorField* contentField;
@property (nonatomic, weak, readonly) WPEditorField* focusedField;
@property (nonatomic, strong, readonly) WPEditorField* titleField;
@property (nonatomic, strong, readonly) UITextField *sourceViewTitleField;

#pragma mark - Properties: Subviews
@property (nonatomic, strong, readonly) ZSSTextView *sourceView;

#pragma mark - URL normalization

- (NSString*)normalizeURL:(NSString*)url;

#pragma mark - Interaction

- (void)insertHTML:(NSString *)html;

/**
 *	@brief		Undo the last operation.
 */
- (void)undo;

/**
 *	@brief		Redo the last operation.
 */
- (void)redo;

#pragma mark - Selection


- (void)restoreSelection;

/**
 *	@brief		Saves the current text selection.
 *	@details	The selection is restored automatically by some insert operations when called.
 *				The only important step is to call this method before an insertion of a link or
 *				image.
 */
- (void)saveSelection;

/**
 *	@brief		Call this to retrieve the selected text.
 *
 *	@returns	The selected text.
 */
- (NSString*)selectedText;

- (void)setSelectedColor:(UIColor*)color
					 tag:(int)tag;

#pragma mark - Images

/**
 *  @brief      Inserts a local image URL.  Useful for images that need to be uploaded.
 *  @details    By inserting a local image URL, we can make sure the image is shown to the user
 *              as soon as it's selected for uploading.  Once the image is successfully uploaded
 *              the application should call replaceLocalImageWithRemoteImage().
 *
 *  @param      url         The URL of the local image to display.  Please keep in mind that a
 *                          remote URL can be used here too, since this method does not check for
 *                          that.  It would be a mistake.
 *  @param      uniqueId    This is a unique ID provided by the caller.  It exists as a mechanism
 *                          to update the image node with the remote URL when
 *                          replaceLocalImageWithRemoteImage() is called.
 */
- (void)insertLocalImage:(NSString*)url uniqueId:(NSString*)uniqueId;

- (void)insertImage:(NSString *)url alt:(NSString *)alt;

/**
 *  @brief      Replaces a local image URL with a remote image URL.  Useful for images that have
 *              just finished uploading.
 *  @details    The remote image can be available after a while, when uploading images.  This method
 *              allows for the remote URL to be loaded once the upload completes.
 *
 *  @param      url         The URL of the remote image to display.
 *  @param      uniqueId    This is a unique ID provided by the caller.  It exists as a mechanism
 *                          to update the image node with the remote URL
 *                          when replaceLocalImageWithRemoteImage() is called.
 */
- (void)replaceLocalImageWithRemoteImage:(NSString*)url uniqueId:(NSString*)uniqueId;

- (void)updateImage:(NSString *)url alt:(NSString *)alt;

- (void)updateCurrentImageMeta:(WPImageMeta *)imageMeta;

- (void)setProgress:(double) progress onImage:(NSString*)uniqueId;

- (void)markImageUploadFailed:(NSString*)uniqueId;

- (void)removeImage:(NSString*)uniqueId;
#pragma mark - Links

/**
 *	@brief		Inserts a link at the last saved selection.
 *
 *	@param		url		The url that will open when the link is clicked.  Cannot be nil.
 *	@param		title	The link title.  Cannot be nil.
 */
- (void)insertLink:(NSString *)url
			 title:(NSString*)title;

/**
 *	@brief		Call this method to know if the current selection is part of a link.
 *
 *	@return		YES if the current selection is part of a link.
 */
- (BOOL)isSelectionALink;

/**
 *	@brief		Updates the link at the last saved selection.
 *
 *	@param		url		The url that will open when the link is clicked.  Cannot be nil.
 *	@param		title	The link title.  Cannot be nil.
 */
- (void)updateLink:(NSString *)url
			 title:(NSString*)title;

- (void)quickLink;
- (void)removeLink;

#pragma mark - Editing

/**
 *	@brief		Ends editing and forces any subview to resign first responder.
 */
- (void)endEditing;

#pragma mark - Editor mode

- (BOOL)isInVisualMode;
- (void)showHTMLSource;
- (void)showVisualEditor;

#pragma mark - Editing lock

/**
 *	@brief		Disables editing.
 */
- (void)disableEditing;

/**
 *	@brief		Enables editing.
 */
- (void)enableEditing;

#pragma mark - Styles

- (void)alignLeft;
- (void)alignCenter;
- (void)alignRight;
- (void)alignFull;
- (void)setBold;
- (void)setBlockQuote;
- (void)setItalic;
- (void)setSubscript;
- (void)setUnderline;
- (void)setSuperscript;
- (void)setStrikethrough;
- (void)setUnorderedList;
- (void)setOrderedList;
- (void)setHR;
- (void)setIndent;
- (void)setOutdent;
- (void)heading1;
- (void)heading2;
- (void)heading3;
- (void)heading4;
- (void)heading5;
- (void)heading6;
- (void)removeFormat;

@end

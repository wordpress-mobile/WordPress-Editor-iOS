#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WPEditorField : NSObject

typedef void(^WPEditorFieldGetHTMLCompletionBlock)(NSString *html, NSError *error);
typedef void(^WPEditorFieldBooleanQueryCompletionBlock)(BOOL result, NSError *error);
typedef void(^WPEditorFieldVoidQueryCompletionBlock)(NSError *error);

/**
 *  @brief      inputAccessoryView      The input accessory view for the field.
 */
@property (nonatomic, strong, readwrite) UIView* inputAccessoryView;

/**
 *  @brief      nodeId      The ID of the HTML node this editor field wraps.
 */
@property (nonatomic, copy, readonly) NSString* nodeId;

#pragma mark - Initializers

/**
 *  @brief      Initializes the field with the specified HTML node id.
 *
 *  @param      nodeId      The id of the html node this object will wrap.  Cannot be nil.
 *  @param      webVieq     The web view to use for all javascript calls.  Cannot be nil.
 *
 *  @returns    The initialized object.
 */
- (instancetype)initWithId:(NSString*)nodeId
                   webView:(WKWebView*)webView;

#pragma mark - DOM status

/**
 *  @brief      Called by the owner of this field to signal the DOM has been loaded.
 */
- (void)handleDOMLoaded;

#pragma mark - Editing lock

/**
 *	@brief		Disables editing.
 */
- (void)disableEditing;

/**
 *	@brief		Enables editing.
 */
- (void)enableEditing;

#pragma mark - HTML

/**
 *  @brief      Retrieves the field's html contents.
 *
 *	@param		completionBlock		The block to execute once the HTML has been retrieved, or there
 *									has been an error.  Cannot be nil.
 */
- (void)html:(WPEditorFieldGetHTMLCompletionBlock)completionBlock;

/**
 *  @brief      Retrieves the field's html sans HTML tags.
 *
 *	@param		completionBlock		The block to execute once the HTML has been retrieved, or there
 *									has been an error.  Cannot be nil.
 */
- (void)strippedHtml:(WPEditorFieldGetHTMLCompletionBlock)completionBlock;

/**
 *  @brief      Sets the field's plain text contents. The param string is
 *              not interpreted as HTML.
 *
 *  @param      text     The new field's plain text contents.
 */
- (void)setText:(NSString*)text;

/**
 *  @brief      Sets the field's html contents.
 *
 *  @param      html				The new field's html contents.
 *	@param		completionBlock		The block to execute when the operation completes.
 */
- (void)setHtml:(NSString*)html
	 onComplete:(WPEditorFieldVoidQueryCompletionBlock)completionBlock;

#pragma mark - Placeholder

/**
 *  @brief      Sets the placeholder text for this field.
 *
 *  @param      placeholderText     The new placeholder text.
 */
- (void)setPlaceholderText:(NSString*)placeholderText;

/**
 *  @brief      Sets the placeholder color for this field.
 *
 *  @param      placeholderText     The new placeholder color.
 */
- (void)setPlaceholderColor:(UIColor *)placeholderColor;

#pragma mark - Focus

/**
 *	@brief		Assigns focus to the field.
 *	@todo		DRM: Replace this with becomeFirstResponder????
 */
- (void)focus;

/**
 *	@brief		Resigns focus from the field.
 *	@todo		DRM: Replace this with resignFirstResponder????
 */
- (void)blur;

#pragma mark - i18n

/**
 *  @brief      Whether the field has RTL text direction enabled
 *
 *	@parameter	completionBlock		The block that will be executed when the javascript evaluation
 *									completes.  Cannot be nil.
 */
- (void)isRightToLeftTextEnabled:(WPEditorFieldBooleanQueryCompletionBlock)completionBlock;

/**
 *  @brief      Sets the field's right to left text direction.
 *
 *  @param      isRTL   Use YES if the field is RTL, NO otherwise.
 */
- (void)setRightToLeftTextEnabled:(BOOL)isRTL;

#pragma mark - Settings

/**
 *  @brief      Whether the field is single line or multiline.
 *
 *	@parameter	completionBlock		The block that will be executed when the javascript evaluation
 *									completes.  Cannot be nil.
 */
- (void)isMultiline:(WPEditorFieldBooleanQueryCompletionBlock)completionBlock;

/**
 *  @brief      Sets the field's multiline configuration.
 *
 *  @param      multiline   Use YES if the field is multiline, NO otherwise.
 */
- (void)setMultiline:(BOOL)multiline;

@end

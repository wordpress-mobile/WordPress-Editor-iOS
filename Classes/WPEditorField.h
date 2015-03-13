#import <Foundation/Foundation.h>

@interface WPEditorField : NSObject

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
                   webView:(UIWebView*)webView;

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
 *  @returns    The field's html contents.
 */
- (NSString*)html;

/**
 *  @brief      Retrieves the field's html sans HTML tags.
 *
 *  @returns    The field's contents without HTML tags.
 */
- (NSString*)strippedHtml;

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
 *  @param      html     The new field's html contents.
 */
- (void)setHtml:(NSString*)html;

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
 *  @returns    YES if the field is RTL, NO otherwise.
 */
- (BOOL)isRightToLeftTextEnabled;

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
 *  @returns    YES if the field is multiline, NO otherwise.
 */
- (BOOL)isMultiline;

/**
 *  @brief      Sets the field's multiline configuration.
 *
 *  @param      multiline   Use YES if the field is multiline, NO otherwise.
 */
- (void)setMultiline:(BOOL)multiline;

@end

#import <UIKit/UIKit.h>
#import "HRColorPickerViewController.h"

@class WPEditorField;
@class WPEditorView;
@class WPEditorViewController;
@class WPImageMeta;

typedef enum
{
    kWPEditorViewControllerModePreview = 0,
    kWPEditorViewControllerModeEdit
}
WPEditorViewControllerMode;

@protocol WPEditorViewControllerDelegate <NSObject>
@optional

- (void)editorDidBeginEditing:(WPEditorViewController *)editorController;
- (void)editorDidEndEditing:(WPEditorViewController *)editorController;
- (void)editorDidFinishLoadingDOM:(WPEditorViewController*)editorController;
- (BOOL)editorShouldDisplaySourceView:(WPEditorViewController *)editorController;
- (void)editorTitleDidChange:(WPEditorViewController *)editorController;
- (void)editorTextDidChange:(WPEditorViewController *)editorController;
- (void)editorDidPressMedia:(WPEditorViewController *)editorController;


/**
 *	@brief		Received when the format bar enabled status has changed.
 *	@param		editorController    The editor view.
 *	@param		enabled             BOOL describing the new state of the format bar
 */
- (void)editorFormatBarStatusChanged:(WPEditorViewController *)editorController
                             enabled:(BOOL)isEnabled;

/**
 *	@brief		Received when the field is created and can be used.
 *  @details    The editor fields will be nil before this method is called.  This is because editor
 *              fields are created as part of the process of loading the HTML.
 *
 *	@param		editorView		The editor view.
 *	@param		field			The new field.
 */
- (void)editorViewController:(WPEditorViewController*)editorViewController
                fieldCreated:(WPEditorField*)field;

/**
 *	@brief		Received when the user taps on a image in the editor.
 *
 *	@param		editorView	The editor view.
 *	@param		imageId		The id of image of the image that was tapped.
 *	@param		url			The url of the image that was tapped.
 *
 */
- (void)editorViewController:(WPEditorViewController*)editorViewController
       imageTapped:(NSString *)imageId
               url:(NSURL *)url;

/**
 *	@brief		Received when the user taps on a image in the editor.
 *
 *	@param		editorView	The editor view.
 *	@param		imageId		The id of image of the image that was tapped.
 *	@param		url			The url of the image that was tapped.
 *  @param		imageMeta	The parsed meta data about the image.
 */
- (void)editorViewController:(WPEditorViewController*)editorViewController
                 imageTapped:(NSString *)imageId
                         url:(NSURL *)url
                   imageMeta:(WPImageMeta *)imageMeta;

/**
 *	@brief		Received when the user taps on a image in the editor.
 *
 *	@param		editorView	The editor view.
 *	@param		videoID		The id of the video that was tapped.
 *	@param		url			The url of the video that was tapped.
 *
 */
- (void)editorViewController:(WPEditorViewController*)editorViewController
                 videoTapped:(NSString *)videoID
                         url:(NSURL *)url;

/**
 *	@brief		Received when the local image url is replace by the final image in the editor.
 *
 *	@param		editorView	The editor view.
 *	@param		imageId		The id of image of the image that was tapped.
 */
- (void)editorViewController:(WPEditorViewController*)editorViewController
               imageReplaced:(NSString *)imageId;

/**
 *	@brief		Received when the local video url is replace by the final video in the editor.
 *
 *	@param		editorView	The editor view.
 *	@param		videoID		The id of video that was tapped.
 */
- (void)editorViewController:(WPEditorViewController*)editorViewController
               videoReplaced:(NSString *)videoID;

/**
 *	@brief		Received when the editor requests information about a videopress video.
 *
 *	@param		editorView	The editor view.
 *	@param		videoID		The id of video that was tapped.
 */
- (void)editorViewController:(WPEditorViewController *)editorViewController
       videoPressInfoRequest:(NSString *)videoID;

/**
 *	@brief		Received when the editor removed an uploading media.
 *
 *	@param		editorView	The editor view.
 *	@param		mediaID		The id of the media that was removed.
 */
- (void)editorViewController:(WPEditorViewController *)editorViewController
                mediaRemoved:(NSString *)mediaID;

@end

@class ZSSBarButtonItem;

@interface WPEditorViewController : UIViewController

typedef void(^WPEditorViewControllerTextRequestCompletionBlock)(NSString *text, NSError *error);

@property (nonatomic, weak) id<WPEditorViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *titlePlaceholderText;
@property (nonatomic, copy) NSString *bodyPlaceholderText;

#pragma mark - Properties: Editor View
@property (nonatomic, strong, readonly) WPEditorView *editorView;

#pragma mark - Initializers

/**
 *	@brief		Initializes the VC with the specified mode.
 *
 *	@param		mode	The mode to initialize the VC in.
 *
 *	@returns	The initialized object.
 */
- (instancetype)initWithMode:(WPEditorViewControllerMode)mode;

#pragma mark - Getters & setters

- (void)bodyText:(WPEditorViewControllerTextRequestCompletionBlock)completionBlock;
- (void)setBodyText:(NSString*)bodyText;
- (void)titleText:(WPEditorViewControllerTextRequestCompletionBlock)completionBlock;
- (void)setTitleText:(NSString *)titleText;

#pragma mark - Editing

/**
 *	@brief		Call this method to know if the VC is in edit mode.
 *	@details	Edit mode has to be manually turned on and off, and is not reliant on fields gaining
 *				or losing focus.
 *
 *	@returns	YES if the VC is in edit mode, NO otherwise.
 */
- (BOOL)isEditing;

/**
 *	@brief		Starts editing.
 */
- (void)startEditing;

/**
 *  @brief		Stop all editing activities.
 */
- (void)stopEditing;

#pragma mark - Override these in subclasses

/**
 *  Gets called when the insert URL picker button is tapped in an alertView
 *
 *  @warning The default implementation of this method is blank and does nothing
 */
- (void)showInsertURLAlternatePicker;

/**
 *  Gets called when the insert Image picker button is tapped in an alertView
 *
 *  @warning The default implementation of this method is blank and does nothing
 */
- (void)showInsertImageAlternatePicker;

@end

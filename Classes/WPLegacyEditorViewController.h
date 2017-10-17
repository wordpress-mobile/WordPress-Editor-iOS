#import <UIKit/UIKit.h>
#import "WPEditorStat.h"

@class WPLegacyEditorViewController;

@protocol WPLegacyEditorViewControllerDelegate <NSObject>
@optional

- (BOOL)editorShouldBeginEditing:(WPLegacyEditorViewController *)editorController;

- (void)editorTitleDidChange:(WPLegacyEditorViewController *)editorController;
- (void)editorTextDidChange:(WPLegacyEditorViewController *)editorController;

- (void)editorDidPressSettings:(WPLegacyEditorViewController *)editorController;
- (void)editorDidPressMedia:(WPLegacyEditorViewController *)editorController;
- (void)editorDidPressPreview:(WPLegacyEditorViewController *)editorController;
- (void)editorTrackStat:(WPEditorStat)stat;
@end

@interface WPLegacyEditorViewController : UIViewController

@property (nonatomic, weak) id<WPLegacyEditorViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *bodyText;
@property (nonatomic) BOOL isShowingKeyboard;
@property (nonatomic) BOOL isExternalKeyboard;

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) UIFont *bodyFont;
@property (nonatomic, strong) UIColor *bodyColor;

@property (nonatomic, strong) UIColor *separatorColor;
@property (nonatomic, strong) UIColor *placeholderColor;

#pragma mark - Appearance
/**
 *	@brief		This method allows should be implement by view controllers that want customize the appearance
 *  of the editor view and toolbar
 *
 */
- (void)customizeAppearance;

- (void)stopEditing;
- (void)startEditing;

@end

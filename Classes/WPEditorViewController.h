#import <UIKit/UIKit.h>

@class WPEditorViewController;

@protocol WPEditorViewControllerDelegate <NSObject>

@optional

- (BOOL)editorShouldBeginEditing:(WPEditorViewController *)editorController;
- (BOOL)editorShouldEndEditing:(WPEditorViewController *)editorController;

- (void)editorTitleDidChange:(WPEditorViewController *)editorController;
- (void)editorTextDidChange:(WPEditorViewController *)editorController;

- (void)editorDidPressSettings:(WPEditorViewController *)editorController;
- (void)editorDidPressMedia:(WPEditorViewController *)editorController;
- (void)editorDidPressPreview:(WPEditorViewController *)editorController;

@end

@interface WPEditorViewController : UIViewController

@property(nonatomic,weak) id<WPEditorViewControllerDelegate> delegate;
@property(nonatomic,copy) NSString *titleText;
@property(nonatomic,copy) NSString *bodyText;
@property (nonatomic) BOOL isShowingKeyboard;
@property (nonatomic) BOOL isExternalKeyboard;

- (id)initWithTitle:(NSString *)title text:(NSString *)text;

@end

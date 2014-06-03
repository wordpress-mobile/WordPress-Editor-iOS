#import <UIKit/UIKit.h>

@interface WPEditorViewController : UIViewController

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *htmlBody;
@property (readonly) BOOL hasChanges;
@property (nonatomic) BOOL isShowingKeyboard;
@property (nonatomic) BOOL isExternalKeyboard;

- (id)initWithHTMLBody:(NSString *)html titleString:(NSString *)title;

@end

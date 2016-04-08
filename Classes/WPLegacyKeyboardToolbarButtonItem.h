#import <UIKit/UIKit.h>

@interface WPLegacyKeyboardToolbarButtonItem : UIBarButtonItem

@property (nonatomic, strong) NSString *actionTag;
@property (nonatomic, strong) NSString *actionName;

- (void)setImageName:(NSString *)imageName;

@end

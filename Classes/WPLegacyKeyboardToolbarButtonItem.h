#import <UIKit/UIKit.h>

@interface WPLegacyKeyboardToolbarButtonItem : UIBarButtonItem

@property (nonatomic, strong) NSString *actionTag, *actionName;

- (void)setImageName:(NSString *)imageName;

@end

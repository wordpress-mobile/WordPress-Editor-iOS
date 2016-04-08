#import "WPLegacyKeyboardToolbarButtonItem.h"
#import <QuartzCore/QuartzCore.h>
#import <WordPressShared/WPStyleGuide.h>

@implementation WPLegacyKeyboardToolbarButtonItem

- (UIImage *)imageNamed:(NSString *)imageName {
    NSBundle* editorBundle = [NSBundle bundleForClass:[self class]];
    return [[UIImage imageNamed:imageName inBundle:editorBundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setImageName:(NSString *)imageName {
    [self setImage:[self imageNamed:imageName]];
}

@end

#import "WPLegacyEditorStyledTextView.h"

@implementation WPLegacyEditorStyledTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.allowsEditingTextAttributes = YES;
    }

    return self;
}

- (void)toggleBoldface:(id)sender
{
    if (self.toggleBoldBlock) {
        self.toggleBoldBlock();
    }
}
- (void)toggleItalics:(id)sender
{
    if (self.toggleItalicBlock) {
        self.toggleItalicBlock();
    }
}
- (void)toggleUnderline:(id)sender
{
    if (self.toggleUnderlineBlock) {
        self.toggleUnderlineBlock();
    }
}

@end

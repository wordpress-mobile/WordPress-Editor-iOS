#import "WPTextFieldTableViewCell.h"

CGFloat const AccessoryPadding = 15.0f;
CGFloat const iPadLeftMargin = 60.0f;
CGFloat const iPadRightMargin = 100.0f;
CGFloat const iPhoneLeftMargin = 30.0f;
CGFloat const iPhoneRightMargin = 50.0f;

@interface WPTextFieldTableViewCell () <UITextFieldDelegate>

@end

@implementation WPTextFieldTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textField = [[UITextField alloc] initWithFrame:self.bounds];
        _textField.adjustsFontSizeToFitWidth = YES;
        _textField.textColor = [UIColor blackColor];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.clearButtonMode = UITextFieldViewModeNever;
        _textField.enabled = YES;
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.delegate = self;
        
        _minimumLabelWidth = 90;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        [self.contentView addSubview:self.textField];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize labelSize = [self.textLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
    labelSize.width = ceil(labelSize.width/5) * 5; // Round to upper 5
    labelSize.width = MAX(self.minimumLabelWidth, labelSize.width); // Impose alignment for shorter labels
    CGFloat leftMargin = 0;
    CGFloat rightMargin = self.accessoryView.frame.size.width;
    if (!self.accessoryView && self.accessoryType != UITableViewCellAccessoryNone) {
        rightMargin = AccessoryPadding;
    }
    if (IS_IPAD) {
        leftMargin  = iPadLeftMargin;
        rightMargin += iPadRightMargin;
    } else {
        leftMargin  = iPhoneLeftMargin;
        rightMargin += iPhoneRightMargin;
    }
    CGRect frame = CGRectMake(labelSize.width + leftMargin,
                       self.textLabel.frame.origin.y,
                       self.frame.size.width - labelSize.width - rightMargin,
                       self.textField.frame.size.height);
    self.textField.frame = frame;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.textField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.shouldDismissOnReturn) {
        [self.textField resignFirstResponder];
    } else {
        if (self.delegate) {
            [self.delegate cellWantsToSelectNextField:self];
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellTextDidChange:)]) {
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.delegate cellTextDidChange:self];
        });
    }
    return YES;
}

- (void)setShouldDismissOnReturn:(BOOL)shouldDismissOnReturn {
    _shouldDismissOnReturn = shouldDismissOnReturn;
    if (shouldDismissOnReturn) {
        self.textField.returnKeyType = UIReturnKeyDone;
    } else {
        self.textField.returnKeyType = UIReturnKeyNext;
    }
}

@end

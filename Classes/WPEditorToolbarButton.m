#import "WPEditorToolbarButton.h"

@interface WPEditorToolbarButton ()
@property (nonatomic, weak, readonly) id target;
@property (nonatomic, assign, readonly) SEL selector;
@property (nonatomic, weak, readwrite) UIView* bottomLineView;
@end

static const CGFloat kAnimationDurationFast = 0.1;
static CGFloat kAnimationDurationNormal = 0.3;
static CGFloat kHighlightedAlpha = 0.2f;
static CGFloat kNormalAlpha = 1.0f;

static const int kBottomLineHMargin = 4;
static const int kBottomLineHeight = 2;


@implementation WPEditorToolbarButton

#pragma mark - Init & dealloc

- (void)dealloc
{
	[self removeTarget:self
				action:@selector(touchUpInside:)
	  forControlEvents:UIControlEventTouchUpInside];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setupAnimations];
		
		[self addTarget:self
				 action:@selector(touchUpInside:)
	   forControlEvents:UIControlEventTouchUpInside];
	}
	
	return self;
}

#pragma mark - Animations

- (void)setupAnimations
{
	self.adjustsImageWhenHighlighted = NO;
	
	[self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
	[self addTarget:self action:@selector(touchDragInside:) forControlEvents:UIControlEventTouchDragInside];
	[self addTarget:self action:@selector(touchDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
}

#pragma mark - Touch handling

- (void)touchDown:(id)sender
{
	[self setAlpha:kHighlightedAlpha];
}

- (void)touchDragInside:(id)sender
{
	[UIView animateWithDuration:kAnimationDurationNormal
					 animations:
     ^{
         [self setAlpha:kHighlightedAlpha];
     }];
}

- (void)touchDragOutside:(id)sender
{
	[UIView animateWithDuration:kAnimationDurationNormal
					 animations:
     ^{
		 [self setAlpha:kNormalAlpha];
	 }];
}

- (void)touchUpInside:(id)sender
{
	[self setAlpha:kNormalAlpha];
	self.selected = !self.selected;
}

#pragma mark - UIControl

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	
	if (highlighted) {
		self.titleLabel.alpha = 0.5f;
		self.imageView.alpha = 0.5f;
		self.bottomLineView.alpha = 0.5f;
	} else {
		self.titleLabel.alpha = 1.0f;
		self.imageView.alpha = 1.0f;
		self.bottomLineView.alpha = 1.0f;
	}
}

- (void)setSelected:(BOOL)selected
{
	BOOL hasChangedSelectedStatus = (selected != self.selected);
	
	[super setSelected:selected];
	
	if (hasChangedSelectedStatus) {
        if (self.enabled) {
            if (selected) {
                self.tintColor = self.selectedTintColor;
            } else {
                self.tintColor = self.normalTintColor;
            }
        } else {
            self.tintColor = self.disabledTintColor;
        }
	}
}

- (void)setEnabled:(BOOL)enabled
{
    BOOL hasChangedEnabledStatus = (enabled != self.enabled);
    
    [super setEnabled:enabled];
    
    if (hasChangedEnabledStatus) {
        if (!enabled) {
            self.tintColor = self.disabledTintColor;
        } else {
            self.tintColor = self.normalTintColor;
        }
    }
}

#pragma mark - Tint color

- (void)setNormalTintColor:(UIColor *)normalTintColor
{
	if (_normalTintColor != normalTintColor) {
		_normalTintColor = normalTintColor;
		
		[self setTitleColor:normalTintColor forState:UIControlStateNormal];
		
		if (!self.selected) {
			self.tintColor = normalTintColor;
		}
	}
}

- (void)setDisabledTintColor:(UIColor *)disabledTintColor
{
    if (_disabledTintColor != disabledTintColor) {
        _disabledTintColor = disabledTintColor;
        
        [self setTitleColor:disabledTintColor forState:UIControlStateDisabled];
        self.tintColor = disabledTintColor;
    }
}

- (void)setSelectedTintColor:(UIColor *)selectedTintColor
{
	if (_selectedTintColor != selectedTintColor) {
		_selectedTintColor = selectedTintColor;
		
		[self setTitleColor:selectedTintColor forState:UIControlStateSelected];
		
		if (self.selected) {
			self.tintColor = selectedTintColor;
		}
	}
}

@end

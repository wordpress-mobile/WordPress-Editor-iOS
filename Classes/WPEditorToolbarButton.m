#import "WPEditorToolbarButton.h"

@interface WPEditorToolbarButton ()
@property (nonatomic, weak, readwrite) UIView* bottomLineView;
@end

static const CGFloat kAnimationDuration = 0.1;
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
		[self addTarget:self
				 action:@selector(touchUpInside:)
	   forControlEvents:UIControlEventTouchUpInside];
	}
	
	return self;
}

#pragma mark - Memory warnings support

- (void)didReceiveMemoryWarning
{
	if (!self.selected) {
		[self destroyBottomLineView];
	}
}

#pragma mark - Touch handling

- (void)touchUpInside:(id)sender
{
	__weak typeof(self) weakSelf = self;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		weakSelf.selected = !weakSelf.selected;
	});
}

#pragma mark - Bottom line

- (void)createBottomLineView
{
	NSAssert(!_bottomLineView, @"The bottom line view should not exist here");
	
	CGRect bottomLineFrame = self.frame;
	bottomLineFrame.origin.x = bottomLineFrame.origin.x + kBottomLineHMargin;
	bottomLineFrame.origin.y = bottomLineFrame.size.height;
	bottomLineFrame.size.width = bottomLineFrame.size.width - kBottomLineHMargin * 2;
	bottomLineFrame.size.height = kBottomLineHeight;
	
	UIView* bottomLineView = [[UIView alloc] initWithFrame:bottomLineFrame];
	bottomLineView.backgroundColor = [self titleColorForState:UIControlStateSelected];
	bottomLineView.userInteractionEnabled = NO;
	
	self.bottomLineView = bottomLineView;
	
	[self addSubview:bottomLineView];
}

- (void)destroyBottomLineView
{
	NSAssert(_bottomLineView, @"The bottom line view should exist here");
	
	[self.bottomLineView removeFromSuperview];
	self.bottomLineView = nil;
}

- (void)slideInBottomLineView
{
	if (!_bottomLineView) {
		[self createBottomLineView];
	}
	
	CGRect newFrame = self.bottomLineView.frame;
	newFrame.origin.y -= kBottomLineHeight;
	
	[UIView animateWithDuration:kAnimationDuration animations:^{
		self.bottomLineView.frame = newFrame;
	}];
}

- (void)slideOutBottomLineView
{
	NSAssert(_bottomLineView, @"The bottom line view should exist here");
	
	CGRect newFrame = self.bottomLineView.frame;
	newFrame.origin.y = self.frame.size.height;
	
	[UIView animateWithDuration:kAnimationDuration animations:^{
		self.bottomLineView.frame = newFrame;
	}];
}

#pragma mark - UIControl

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	
	if (highlighted) {
		self.titleLabel.alpha = 0.5f;
		self.bottomLineView.alpha = 0.5f;
	} else {
		self.titleLabel.alpha = 1.0f;
		self.bottomLineView.alpha = 1.0f;
	}
}

- (void)setSelected:(BOOL)selected
{
	[super setSelected:selected];
	
	if (selected) {
		[self slideInBottomLineView];
	} else {
		[self slideOutBottomLineView];
	}
}

@end

#import "WPEditorToolbarButton.h"

static NSString* const CircleLayerKey = @"circleLayer";
static CGFloat TouchAnimationCircleRadius = 15.0;
static CGFloat TouchAnimationDuration = 0.25;
static CGFloat TouchAnimationInitialOpacity = 0.8;

static CGFloat AnimationDurationNormal = 0.3;
static CGFloat HighlightedAlpha = 0.1;
static CGFloat NormalAlpha = 1.0;

@interface WPEditorToolbarButton () <CAAnimationDelegate>

@property (nonatomic, weak, readonly) id target;
@property (nonatomic, assign, readonly) SEL selector;

@property (nonatomic, strong) CABasicAnimation *circleScaleAnimation;
@property (nonatomic, strong) CABasicAnimation* circleOpacityAnimation;

@end

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

#pragma mark - Memory warnings support

- (void)didReceiveMemoryWarning
{
    self.circleOpacityAnimation = nil;
    self.circleScaleAnimation = nil;
}


#pragma mark - Animations

- (void)setupAnimations
{
	self.adjustsImageWhenHighlighted = NO;
	
	[self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
	[self addTarget:self action:@selector(touchDragInside:) forControlEvents:UIControlEventTouchDragInside];
	[self addTarget:self action:@selector(touchDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
    
    self.circleScaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    self.circleScaleAnimation.fromValue = [NSNumber numberWithFloat:0.5];
    self.circleScaleAnimation.toValue = [NSNumber numberWithFloat:1.4];
    [self.circleScaleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    self.circleOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    self.circleOpacityAnimation.fillMode = kCAFillModeForwards;
    self.circleOpacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    [self.circleOpacityAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
}

- (void)startAnimation
{
    CGFloat circleLineWidth = 1.0;
    CGRect circleRect = CGRectInset(self.bounds, circleLineWidth / 2.0, circleLineWidth / 2.0);
    CGPoint drawPoint = CGPointMake(CGRectGetMidX(circleRect), CGRectGetMidY(circleRect));
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointZero radius:TouchAnimationCircleRadius startAngle:0 endAngle:M_PI*2 clockwise:NO].CGPath;
    circleLayer.position = drawPoint;
    circleLayer.fillColor =  [self.selectedTintColor CGColor];
    circleLayer.strokeColor =  [self.selectedTintColor CGColor];
    circleLayer.lineWidth = 1.0;
    circleLayer.opacity = TouchAnimationInitialOpacity;
    [self.layer addSublayer:circleLayer];
    
    CAAnimationGroup * group =[CAAnimationGroup animation];
    group.fillMode=kCAFillModeForwards;
    group.animations =[NSArray arrayWithObjects:self.circleScaleAnimation, self.circleOpacityAnimation, nil];
    group.duration = TouchAnimationDuration;
    group.repeatCount = 0.0;
    group.removedOnCompletion = NO;
    group.delegate = self;
    [group setValue:circleLayer forKey:CircleLayerKey];
    [circleLayer addAnimation:group forKey:@"innerCircleAnimations"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CALayer *layer = [anim valueForKey:CircleLayerKey];
    if (layer) {
        [layer removeAllAnimations];
        [layer removeFromSuperlayer];
    }
}


#pragma mark - Touch handling

- (void)touchDown:(id)sender
{
    [self setAlpha:HighlightedAlpha];
    [self startAnimation];
}

- (void)touchDragInside:(id)sender
{
	[UIView animateWithDuration:AnimationDurationNormal
					 animations:
     ^{
         [self setAlpha:HighlightedAlpha];
     }];
}

- (void)touchDragOutside:(id)sender
{
	[UIView animateWithDuration:AnimationDurationNormal
					 animations:
     ^{
		 [self setAlpha:NormalAlpha];
	 }];
}

- (void)touchUpInside:(id)sender
{
	[self setAlpha:NormalAlpha];
	self.selected = !self.selected;
}

#pragma mark - UIControl

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	
	if (highlighted) {
		self.titleLabel.alpha = 0.5;
		self.imageView.alpha = 0.5;
	} else {
		self.titleLabel.alpha = 1.0;
		self.imageView.alpha = 1.0;
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
    [super setEnabled:enabled];
    
    if (enabled) {
        if (self.selected) {
            self.tintColor = self.selectedTintColor;
        } else {
            self.tintColor = self.normalTintColor;
        }
    } else {
        self.tintColor = self.disabledTintColor;
    }
}

#pragma mark - Tint color

- (void)setNormalTintColor:(UIColor *)normalTintColor
{
	if (_normalTintColor == normalTintColor) {
        return;
    }
    
    _normalTintColor = normalTintColor;
    [self setTitleColor:normalTintColor forState:UIControlStateNormal];
    if (!self.selected) {
        self.tintColor = normalTintColor;
    }
}

- (void)setDisabledTintColor:(UIColor *)disabledTintColor
{
    if (_disabledTintColor == disabledTintColor) {
        return;
    }
    
    _disabledTintColor = disabledTintColor;
    [self setTitleColor:disabledTintColor forState:UIControlStateDisabled];
    self.tintColor = disabledTintColor;
}

- (void)setSelectedTintColor:(UIColor *)selectedTintColor
{
	if (_selectedTintColor == selectedTintColor) {
        return;
    }
    
    _selectedTintColor = selectedTintColor;
    [self setTitleColor:selectedTintColor forState:UIControlStateSelected];
    if (self.selected) {
        self.tintColor = selectedTintColor;
    }
}

@end

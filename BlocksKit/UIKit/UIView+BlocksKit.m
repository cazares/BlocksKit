//
//  UIView+BlocksKit.m
//  BlocksKit
//

#import "UIView+BlocksKit.h"
#import "UIGestureRecognizer+BlocksKit.h"

typedef void (^SSNEmptyBlock)();

@interface UIView (BlocksKit)

@property (nonatomic, strong) SSNEmptyBlock bkWhenTappedBlock;

@end

@implementation UIView (BlocksKit)

- (void)bk_whenTouches:(NSUInteger)numberOfTouches tapped:(NSUInteger)numberOfTaps handler:(void (^)(void))block
{
	if (!block) return;
	
	UITapGestureRecognizer *gesture = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
		if (state == UIGestureRecognizerStateRecognized) block();
	}];
	
	gesture.numberOfTouchesRequired = numberOfTouches;
	gesture.numberOfTapsRequired = numberOfTaps;

	[self.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (![obj isKindOfClass:[UITapGestureRecognizer class]]) return;

		UITapGestureRecognizer *tap = obj;
		BOOL rightTouches = (tap.numberOfTouchesRequired == numberOfTouches);
		BOOL rightTaps = (tap.numberOfTapsRequired == numberOfTaps);
		if (rightTouches && rightTaps) {
			[gesture requireGestureRecognizerToFail:tap];
		}
	}];

	[self addGestureRecognizer:gesture];
}

- (void)bk_whenTapped:(void (^)(void))block
{
    self.bkWhenTappedBlock = block;
    if ([UIView isKindOfClass:UIButton.class]) {
        UIButton *button = (UIButton *)self;
        [button addTarget:self.superview action:@selector(onBkWhenTapped) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)onBkWhenTapped {
    if (!self.bkWhenTappedBlock) {
        return;
    }
    self.bkWhenTappedBlock();
}

- (void)bk_whenDoubleTapped:(void (^)(void))block
{
	[self bk_whenTouches:1 tapped:2 handler:block];
}

- (void)bk_eachSubview:(void (^)(UIView *subview))block
{
	NSParameterAssert(block != nil);

	[self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		block(subview);
	}];
}

@end

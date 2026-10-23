#import "../Headers/AboutMeTweak.h"

@implementation AboutMeHeaderView

// 確保所有子卡片皆能正常接收點擊事件
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
        if (!subview.hidden && subview.alpha > 0.01 && subview.userInteractionEnabled) {
            CGPoint convertedPoint = [self convertPoint:point toView:subview];
            if ([subview pointInside:convertedPoint withEvent:event]) {
                return YES;
            }
        }
    }
    return [super pointInside:point withEvent:event];
}

@end


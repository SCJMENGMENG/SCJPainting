//
//  ArtboardView.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "ArtboardView.h"
#import "SCJBezierPath.h"

#import <YYKit.h>

@interface ArtboardView ()

@property (nonatomic, strong) NSMutableArray *bezierPathArrM;

@property (nonatomic, strong) SCJBezierPath *bezierPath;

@property (nonatomic, strong) NSMutableArray *backPathArrM;

@property (nonatomic, strong) UIView *eraserFollowView;

/// 捏合手势
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
/// 平移手势
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
/// 视图初始化宽
@property (nonatomic, assign) CGFloat originalWidth;
/// 旋转缩放参考点
@property (nonatomic, assign) CGPoint originalPoint;
@end

@implementation ArtboardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
//        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        self.lineWidth = 17;
        [self initializeSize];
        [self addGesture];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    if(self.bezierPathArrM.count) {
        for (SCJBezierPath *path  in self.bezierPathArrM) {
            
            path.lineJoinStyle = kCGLineJoinRound;
            path.lineCapStyle = kCGLineCapRound;
            
            if (path.isErase) {
                [self.backgroundColor setStroke];
                [path strokeWithBlendMode:kCGBlendModeCopy alpha:1.0];
            }
            else {
                [path.lineColor setStroke];
                [path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
            }
            [path stroke];
        }
    }
    
    [super drawRect:rect];
}

/** 初始化大小 */
- (void)initializeSize {
    // 参考点默认为视图中心，point值为中心点比例
    self.originalPoint = CGPointMake(0.5, 0.5);
    self.originalWidth = kArtboardViewWidth;
    
    self.transform = CGAffineTransformScale(self.transform, 1, 1);
}

#pragma mark - touch方法

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if ([self isDrawWithTouch:touch] == NO) {
        self.eraserFollowView.hidden = YES;
        return;
    }
    
    CGPoint currentPoint = [touch locationInView:touch.view];
    self.bezierPath = [[SCJBezierPath alloc] init];
    
    self.bezierPath.lineJoinStyle = kCGLineJoinRound;
    self.bezierPath.lineCapStyle = kCGLineCapRound;
    self.bezierPath.lineWidth = self.lineWidth;
    self.bezierPath.lineColor = self.lineColor;
    self.bezierPath.isErase = self.isErase;
    [self.bezierPath moveToPoint:currentPoint];
    
    [self.bezierPathArrM addObject:self.bezierPath];
    
    // 橡皮擦跟踪视图
    if (self.isErase) {
        [self eraserFollowViewMoveWithPoint:[touch locationInView:self]];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([self isDrawWithTouch:touch] == NO) {
        return;
    }
    
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];

    CGPoint midP = midPoint(previousPoint,currentPoint);
    [self.bezierPath addQuadCurveToPoint:currentPoint controlPoint:midP];

    [[self.bezierPathArrM lastObject] addLineToPoint:currentPoint];
    
   [self setNeedsDisplay];
    
    if (self.isErase) {
        [self eraserFollowViewMoveWithPoint:[touch locationInView:self]];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.eraserFollowView.hidden = YES;
    
    UITouch *touch = [touches anyObject];
    if ([self isDrawWithTouch:touch] == NO) {
        return;
    }
    
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];
    CGPoint midP = midPoint(previousPoint,currentPoint);
    [self.bezierPath addQuadCurveToPoint:currentPoint controlPoint:midP];
    [self setNeedsDisplay];
    
    if (self.touchesEndedBlock) {
        self.touchesEndedBlock(self.bezierPathArrM, self.backPathArrM);
    }
}

/*
// 捏合
- (void)pinchAction:(UIPinchGestureRecognizer *)pinchGesture {
    NSUInteger touchCount = pinchGesture.numberOfTouches;
    if (touchCount <= 1) {
        return;
    }
    
    CGFloat scale = pinchGesture.scale;
    
    if (pinchGesture.state == UIGestureRecognizerStateBegan || pinchGesture.state == UIGestureRecognizerStateChanged) {
        
        if (scale < 1 ) {
            if (pinchGesture.view.frame.size.width <= self.originalWidth) {
                [UIView animateWithDuration:0.5 animations:^{
                    pinchGesture.view.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
                }];
            } else {
                pinchGesture.view.transform = CGAffineTransformScale(pinchGesture.view.transform, scale, scale);
                if (self.pinchGestureBlock) {
                    self.pinchGestureBlock(pinchGesture.view, scale);
                }
            }

        } else {
            if (pinchGesture.view.frame.size.width <= 4 * kArtboardViewWidth) {
                pinchGesture.view.transform = CGAffineTransformScale(pinchGesture.view.transform, scale, scale);
                if (self.pinchGestureBlock) {
                    self.pinchGestureBlock(pinchGesture.view, scale);
                }
            }
        }
    }
    
    if (pinchGesture.state == UIGestureRecognizerStateEnded) {
        if (self.frame.size.width <= kArtboardViewWidth ) {
            [UIView animateWithDuration:0.5 animations:^{
                pinchGesture.view.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
                pinchGesture.view.center = CGPointMake(kArtboardViewWidth*0.5, kArtboardViewWidth*0.5);
            }];
            
            if (self.pinchGestureBlock) {
                self.pinchGestureBlock(pinchGesture.view, scale);
            }
        }
    }
    
    pinchGesture.scale = 1;
}
*/


// 捏合
- (void)pinchAction:(UIPinchGestureRecognizer *)pinchGesture {
    NSUInteger touchCount = pinchGesture.numberOfTouches;
    if (touchCount <= 1) {
        return;
    }

    CGFloat scale = pinchGesture.scale;
    if (pinchGesture.state == UIGestureRecognizerStateBegan || pinchGesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint p1 = [pinchGesture locationOfTouch: 0 inView:self];
        CGPoint p2 = [pinchGesture locationOfTouch: 1 inView:self];
        CGPoint newCenter = CGPointMake((p1.x+p2.x)/2, (p1.y+p2.y)/2);
        self.originalPoint = CGPointMake(newCenter.x/self.bounds.size.width, newCenter.y/self.bounds.size.height);
        CGPoint oPoint = [self convertPoint:[self getRealOriginalPoint] toView:self.superview];
        self.center = oPoint;
        
        if (scale < 1) {
            if (self.frame.size.width > self.originalWidth) {
                self.transform = CGAffineTransformScale(self.transform, scale, scale);
            }
        }
        else {
            if (self.frame.size.width <= self.originalWidth*4) {
                self.transform = CGAffineTransformScale(self.transform, scale, scale);
            }
        }
        
        oPoint = [self convertPoint:[self getRealOriginalPoint] toView:self.superview];
        self.center = CGPointMake(self.center.x + (self.center.x - oPoint.x), self.center.y + (self.center.y - oPoint.y));
        
        if (self.pinchGestureBlock) {
            self.pinchGestureBlock(pinchGesture.view, scale);
        }
    }
    
    if (pinchGesture.state == UIGestureRecognizerStateEnded || pinchGesture.state == UIGestureRecognizerStateCancelled) {
        
        CGPoint newCenter = CGPointMake(pinchGesture.view.center.x + self.originalPoint.x, pinchGesture.view.center.y + self.originalPoint.y);
        
        CGFloat tempMargin = 0;
        CGFloat defaultMargin = kArtboardViewMargin;
        CGFloat offsetX = 0.0;
        CGFloat offsetY = 0.0;
        if (self.frame.size.width > kScreenWidth) {
            offsetX = (self.frame.size.width-kScreenWidth)*0.5 + defaultMargin;
            offsetY = (self.frame.size.height-kScreenWidth)*0.5 + defaultMargin;
        }
        
        float halfx = CGRectGetMidX(self.bounds);
        newCenter.x = MAX(halfx + tempMargin - offsetX, newCenter.x);
        newCenter.x = MIN(self.superview.bounds.size.width - tempMargin - halfx  + offsetX, newCenter.x);
        
        float halfy = CGRectGetMidY(self.bounds);
        newCenter.y = MAX(halfy + tempMargin - offsetY, newCenter.y);
        newCenter.y = MIN(self.superview.bounds.size.height - tempMargin - halfy + offsetY, newCenter.y);
        
        [UIView animateWithDuration:0.3 animations:^{
            pinchGesture.view.center = newCenter;
        }];
        
        if (self.frame.size.width <= kArtboardViewWidth ) {
            [UIView animateWithDuration:0.3 animations:^{
                pinchGesture.view.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
            }];
        }
        
        if (self.pinchGestureBlock) {
            self.pinchGestureBlock(pinchGesture.view, scale);
        }
    }
    
    pinchGesture.scale = 1;
}

////设置图片的锚点
//- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
//    CGPoint oldOrigin = view.frame.origin;
//    view.layer.anchorPoint = anchorPoint;
//    CGPoint newOrigin = view.frame.origin;
//
//    CGPoint transition;
//    transition.x = newOrigin.x - oldOrigin.x;
//    transition.y = newOrigin.y - oldOrigin.y;
//
//    view.center = CGPointMake (view.center.x - transition.x, view.center.y - transition.y);
//}
////设置回原来的锚点
//- (void)setDefaultAnchorPointforView:(UIView *)view {
//    [self setAnchorPoint:CGPointMake(0.5f, 0.5f) forView:view];
//}

// 平移
- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        if (panGesture.view.frame.origin.x == kArtboardViewMargin && panGesture.view.frame.origin.y == kArtboardViewMargin) {
            return;
        }
    
        CGPoint translation = [panGesture translationInView:panGesture.view.superview];
        CGPoint newCenter = CGPointMake(panGesture.view.center.x + translation.x, panGesture.view.center.y + translation.y);
        
        CGFloat tempMargin = 0;
        CGFloat defaultMargin = kArtboardViewMargin;
        CGFloat offsetX = 0.0;
        CGFloat offsetY = 0.0;
        if (self.frame.size.width > kScreenWidth) {
            offsetX = (self.frame.size.width-kScreenWidth)*0.5 + defaultMargin;
            offsetY = (self.frame.size.height-kScreenWidth)*0.5 + defaultMargin;
        }
        
        float halfx = CGRectGetMidX(self.bounds);
        newCenter.x = MAX(halfx + tempMargin - offsetX, newCenter.x);
        newCenter.x = MIN(self.superview.bounds.size.width - tempMargin - halfx  + offsetX, newCenter.x);

        float halfy = CGRectGetMidY(self.bounds);
        newCenter.y = MAX(halfy + tempMargin - offsetY, newCenter.y);
        newCenter.y = MIN(self.superview.bounds.size.height - tempMargin - halfy + offsetY, newCenter.y);
        
        panGesture.view.center = newCenter;
        [panGesture setTranslation:CGPointZero inView:panGesture.view.superview];
        
        if (self.panGestureBlock) {
            self.panGestureBlock(panGesture.view);
        }
    }
}

#pragma mark - Privare

- (void)addGesture {
    
    if (![self.gestureRecognizers containsObject:self.pinchGesture]) {
        [self addGestureRecognizer:self.pinchGesture];
    }

    if (![self.gestureRecognizers containsObject:self.panGesture]) {
        [self addGestureRecognizer:self.panGesture];
    }
}

/** 截图 */
- (UIImage *)snapshot {
    if (self.bezierPathArrM.count > 0) {
        @autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
            [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return image;
        }
    }
    return nil;
}

/** 改变橡皮擦位置 */
- (void)eraserFollowViewMoveWithPoint:(CGPoint)point {
    self.eraserFollowView.hidden = NO;
    [self addSubview:self.eraserFollowView];
    [self.eraserFollowView setCenter:(CGPoint){point.x, point.y}];
}

/** 计算中间点 */
CGPoint midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

/** 获取参考点坐标 */
- (CGPoint)getRealOriginalPointWithView:(UIView *)view {
    return CGPointMake(view.bounds.size.width * self.originalPoint.x, view.bounds.size.height * self.originalPoint.y);
}

- (CGPoint)getRealOriginalPoint {
    return CGPointMake(self.bounds.size.width * self.originalPoint.x, self.bounds.size.height * self.originalPoint.y);
}

/** 判断是否是绘制还是拖动 */
- (BOOL)isDrawWithTouch:(UITouch *)touch {
    UIGestureRecognizer *panGesture;
    for (UIGestureRecognizer *gesture in touch.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            panGesture = gesture;
            break;
        }
    }
    
    return panGesture.numberOfTouches > 1 ? NO : YES;
}

#pragma mark - getter

- (UIColor *)lineColor {
    if (!_lineColor) {
        _lineColor = [UIColor blackColor];
    }
    return _lineColor;
}

#pragma mark - setter

- (void)setIsErase:(BOOL)isErase {
    _isErase = isErase;
    
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    
    self.eraserFollowView.layer.cornerRadius = lineWidth*0.5;
    self.eraserFollowView.size = CGSizeMake(lineWidth, lineWidth);
}

- (void)back {
    if (self.bezierPathArrM.count > 0) {
        [self.backPathArrM addObject:self.bezierPathArrM.lastObject];
        
        [self.bezierPathArrM removeLastObject];
        [self setNeedsDisplay];
    }
    
    if (self.revokeAndBackClickBlock) {
        self.revokeAndBackClickBlock(self.bezierPathArrM, self.backPathArrM);
    }
}

- (void)next {
    if (self.backPathArrM.count > 0) {
        [self.bezierPathArrM addObject:self.backPathArrM.lastObject];
        [self setNeedsDisplay];
        
        [self.backPathArrM removeObject:self.backPathArrM.lastObject];
    }
    
    if (self.revokeAndBackClickBlock) {
        self.revokeAndBackClickBlock(self.bezierPathArrM, self.backPathArrM);
    }
}

- (void)clearScreen {
    [self.bezierPathArrM removeAllObjects];
    [self setNeedsDisplay];
}

#pragma mark - UIGestureRecognizerDelegate

/** 同时触发多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer.view == self) {
        
        NSLog(@"手势代理2222=====%@", gestureRecognizer);
    }
    return YES;
}
*/

#pragma mark - 懒加载

- (NSMutableArray *)bezierPathArrM {
    if (!_bezierPathArrM) {
        _bezierPathArrM  = [NSMutableArray array];
    }
    return _bezierPathArrM;
}

- (NSMutableArray *)backPathArrM {
    if (!_backPathArrM) {
        _backPathArrM  = [NSMutableArray array];
    }
    return _backPathArrM;
}

- (UIView *)eraserFollowView {
    if (!_eraserFollowView) {
        _eraserFollowView = [[UIView alloc] init];
        _eraserFollowView.size = CGSizeMake(self.lineWidth, self.lineWidth);
        _eraserFollowView.hidden = YES;
        _eraserFollowView.backgroundColor = [UIColor colorWithRed:82/255.0 green:122/255.0 blue:255/255.0 alpha:0.8];
        _eraserFollowView.layer.borderColor = [UIColor colorWithRed:82/255.0 green:122/255.0 blue:255/255.0 alpha:0.3].CGColor;
        _eraserFollowView.layer.borderWidth = 2;
        _eraserFollowView.layer.cornerRadius = self.lineWidth*0.5;
    }
    return _eraserFollowView;
}

- (UIPinchGestureRecognizer *)pinchGesture {
    if (!_pinchGesture) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchAction:)];
//        _pinchGesture.delegate = self;
    }
    return _pinchGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
        _panGesture.minimumNumberOfTouches = 2;
    }
    return _panGesture;
}

@end

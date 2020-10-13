//
//  PasteImageView.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "PasteImageView.h"

#define Layer_BorderWidth 2

@interface PasteImageView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *textLab;
/// 删除按钮
@property (nonatomic, strong) UIImageView *removeBtn;
/// 旋转缩放按钮
@property (nonatomic, strong) UIImageView *rotateAndZoomBtn;
/// 点击手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
/// 平移手势
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
/// 捏合手势
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
/// 旋转手势
@property (nonatomic, strong) UIRotationGestureRecognizer *rotateGesture;

/// 视图初始化宽
@property (nonatomic, assign) CGFloat originalWidth;
/// 视图初始化高
@property (nonatomic, assign) CGFloat originalHeight;
/// 旋转缩放参考点
@property (nonatomic, assign) CGPoint originalPoint;
/// 记录上一个控制点
@property (nonatomic, assign) CGPoint lastCtrlPoint;

@end

@implementation PasteImageView

- (void)setupUI {
    if (self.pasteType == PasteTypeImage) {
        [self addSubview:self.imageView];
        self.imageView.layer.borderWidth = Layer_BorderWidth;
        self.imageView.layer.borderColor = [UIColor cyanColor].CGColor;
    } else {
        [self addSubview:self.textLab];
        self.textLab.layer.borderWidth = Layer_BorderWidth;
        self.textLab.layer.borderColor = [UIColor cyanColor].CGColor;
    }
    
    [self addSubview:self.rotateAndZoomBtn];
    [self addSubview:self.removeBtn];
    
    [self addViewGesture];
}

/** 初始化大小 */
- (void)initializeSize {
    // 参考点默认为视图中心，point值为中心点比例
    self.originalPoint = CGPointMake(0.5, 0.5);
    self.originalWidth = self.frame.size.width;
    self.originalHeight = self.frame.size.height;
}

- (void)addViewGesture {
    self.panGesture.delegate = self;
    [self addGestureRecognizer:self.tapGesture];
}

#pragma mark - setter

- (void)setPasteType:(PasteType)pasteType {
    _pasteType = pasteType;
    
    [self setupUI];
    [self initializeSize];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
}

- (void)setText:(NSString *)text {
    _text = text;
    
    self.textLab.text = text.length > 0 ? text : @"点击添加文本";
    self.textLab.textColor = self.textColor;
    
    BOOL isContainEnter = [self textContainEnterWithStr:text];
    
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:20.0]} context:nil].size;
    
    if (isContainEnter) {
        textSize = [self.textLab sizeThatFits:textSize];
    }
    
    CGFloat tempWidth = self.originalWidth;
    CGFloat tempHeight = self.originalHeight;
    if (textSize.width > self.originalWidth) {
        tempWidth = textSize.width + Ctrl_Radius*2 + 20;
    }
    
    if (isContainEnter) {
        if (textSize.height > self.originalHeight-Ctrl_Radius*2) {
            tempHeight = textSize.height + Ctrl_Radius*2 + 20;
        }
    }
    
    self.bounds = CGRectMake(0, 0, tempWidth, tempHeight);
    self.textLab.frame = CGRectMake(Ctrl_Radius, Ctrl_Radius, tempWidth - Ctrl_Radius*2, tempHeight - Ctrl_Radius*2);
    
    [self.rotateAndZoomBtn setCenter:(CGPoint){self.textLab.frame.origin.x + self.textLab.frame.size.width, self.textLab.frame.origin.y + self.textLab.frame.size.height}];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    
    if (self.textLab.text.length > 0) {
        self.textLab.textColor = textColor;
    }
}

- (void)setIsOperation:(BOOL)isOperation {
    _isOperation = isOperation;
    
    if (isOperation) {
        self.removeBtn.hidden = NO;
        self.rotateAndZoomBtn.hidden = NO;
        if (self.pasteType == PasteTypeImage) {
            self.imageView.layer.borderWidth = Layer_BorderWidth;
        } else {
            self.textLab.layer.borderWidth = Layer_BorderWidth;
        }
        
        if (![self.gestureRecognizers containsObject:self.panGesture]) {
            [self addGestureRecognizer:self.panGesture];
        }
        if (![self.gestureRecognizers containsObject:self.pinchGesture]) {
            [self addGestureRecognizer:self.pinchGesture];
        }
        if (![self.gestureRecognizers containsObject:self.rotateGesture]) {
            [self addGestureRecognizer:self.rotateGesture];
        }
    }
    else {
        self.removeBtn.hidden = YES;
        self.rotateAndZoomBtn.hidden = YES;
        
        if (self.pasteType == PasteTypeImage) {
            self.imageView.layer.borderWidth = 0;
        } else {
            self.textLab.layer.borderWidth = 0;
        }
        
        /*
        if ([self.gestureRecognizers containsObject:self.panGesture]) {
            [self removeGestureRecognizer:self.panGesture];
        }
        if ([self.gestureRecognizers containsObject:self.pinchGesture]) {
            [self removeGestureRecognizer:self.pinchGesture];
        }
        if ([self.gestureRecognizers containsObject:self.rotateGesture]) {
            [self removeGestureRecognizer:self.rotateGesture];
        }
         */
    }
}

#pragma mark - 手势操作

// 旋转
- (void)rotateAction:(UIRotationGestureRecognizer *)rotateGesture {
    NSUInteger touchCount = rotateGesture.numberOfTouches;
    if (touchCount <= 1) {
        return;
    }
    
    CGPoint p1 = [rotateGesture locationOfTouch: 0 inView:self];
    CGPoint p2 = [rotateGesture locationOfTouch: 1 inView:self];
    CGPoint newCenter = CGPointMake((p1.x+p2.x)/2, (p1.y+p2.y)/2);
    self.originalPoint = CGPointMake(newCenter.x/self.bounds.size.width, newCenter.y/self.bounds.size.height);
    
    CGPoint oPoint = [self convertPoint:[self getRealOriginalPoint] toView:self.superview];
    self.center = oPoint;
    self.transform = CGAffineTransformRotate(self.transform, rotateGesture.rotation);
    rotateGesture.rotation = 0;
    
    oPoint = [self convertPoint:[self getRealOriginalPoint] toView:self.superview];
    self.center = CGPointMake(self.center.x + (self.center.x - oPoint.x), self.center.y + (self.center.y - oPoint.y));
}

// 捏合
- (void)pinchAction:(UIPinchGestureRecognizer *)pinchGesture {
    NSUInteger touchCount = pinchGesture.numberOfTouches;
    if (touchCount <= 1) {
        return;
    }
    
    CGPoint p1 = [pinchGesture locationOfTouch: 0 inView:self];
    CGPoint p2 = [pinchGesture locationOfTouch: 1 inView:self];
    CGPoint newCenter = CGPointMake((p1.x+p2.x)/2, (p1.y+p2.y)/2);
    self.originalPoint = CGPointMake(newCenter.x/self.bounds.size.width, newCenter.y/self.bounds.size.height);
    
    CGPoint oPoint = [self convertPoint:[self getRealOriginalPoint] toView:self.superview];
    self.center = oPoint;
    
    CGFloat scale = pinchGesture.scale;
    
    if (scale < 1 ) {
        // 控制缩放比例：当缩小到初始化宽高的一半时，停止缩小
        if (self.frame.size.width > self.originalWidth/2) {
            self.transform = CGAffineTransformScale(self.transform, scale, scale);
            [self fitCtrlScaleX:scale scaleY:scale];
        }
    }
    else {
        if (self.frame.size.width <= self.originalWidth*10) {
            self.transform = CGAffineTransformScale(self.transform, scale, scale);
            [self fitCtrlScaleX:scale scaleY:scale];
        }
    }
    
    CGFloat tempScale = self.frame.size.width/self.originalWidth;
    if (self.pasteType == PasteTypeText && tempScale > 1) {
        [self.textLab.layer setContentsScale:tempScale * [[UIScreen mainScreen] scale]];
        [self.textLab.layer setNeedsDisplay];
    }
    
    oPoint = [self convertPoint:[self getRealOriginalPoint] toView:self.superview];
    self.center = CGPointMake(self.center.x + (self.center.x - oPoint.x), self.center.y + (self.center.y - oPoint.y));
    pinchGesture.scale = 1;
}

// 平移
- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:self.superview];
        [self setCenter:(CGPoint){self.center.x + translation.x, self.center.y + translation.y}];
        [panGesture setTranslation:CGPointZero inView:self.superview];
        
        // 使当前view在第一个
        ((PasteImageView *)panGesture.view).isTapGesture = NO;
        [self clickPasteImage:panGesture.view];
    }
}

// 点击
- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture {
    
    ((PasteImageView *)tapGesture.view).isTapGesture = YES;
    [self clickPasteImage:tapGesture.view];
}

#pragma mark - 视图控制按钮 手势事件

// 缩放旋转
- (void)rotateCtrlPanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.lastCtrlPoint = [self convertPoint:self.rotateAndZoomBtn.center toView:self.superview];
        return;
    }
    
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint ctrlPoint = [panGesture locationInView:self.superview];
    [self scaleViewWithCtrlPoint:ctrlPoint];
    [self rotateViewWithCtrlPoint:ctrlPoint];
    self.lastCtrlPoint = ctrlPoint;
}

// 移除视图
- (void)removeCtrlTapGesture:(UITapGestureRecognizer *)tapGesture {
    self.isRemove = YES;
    if (self.removeBlock) {
        self.removeBlock(self);
    }
    [self removeFromSuperview];
}

#pragma mark - 旋转

- (void)rotateViewWithCtrlPoint:(CGPoint)ctrlPoint {
    
    CGPoint oPoint = [self convertPoint:[self getRealOriginalPoint] toView:self.superview];
    self.center = CGPointMake(self.center.x - (self.center.x - oPoint.x), self.center.y - (self.center.y - oPoint.y));
    
    
    float angle = atan2(self.center.y - ctrlPoint.y, ctrlPoint.x - self.center.x);
    float lastAngle = atan2(self.center.y - self.lastCtrlPoint.y, self.lastCtrlPoint.x - self.center.x);
    angle = - angle + lastAngle;
    self.transform = CGAffineTransformRotate(self.transform, angle);
    
    oPoint = [self convertPoint:[self getRealOriginalPoint] toView:self.superview];
    self.center = CGPointMake(self.center.x + (self.center.x - oPoint.x), self.center.y + (self.center.y - oPoint.y));
}

#pragma mark - 缩放

/** 等比缩放 */
- (void)scaleViewWithCtrlPoint:(CGPoint)ctrlPoint {
    CGPoint oPoint = [self convertPoint:[self getRealOriginalPoint] toView:self.superview];
    self.center = oPoint;
    
    // 上一个控制点距离中心的距离
    CGFloat preDistance = [self distanceWithStartPoint:self.center endPoint:self.lastCtrlPoint];
    // 当前控制点距离中心的距离
    CGFloat newDistance = [self distanceWithStartPoint:self.center endPoint:ctrlPoint];
    CGFloat scale = newDistance / preDistance;
    
    if (scale < 1 ) {
        // 控制缩放比例
        if (self.frame.size.width > self.originalWidth/2) {
            self.transform = CGAffineTransformScale(self.transform, scale, scale);
            [self fitCtrlScaleX:scale scaleY:scale];
        }
    }
    else {
        if (self.frame.size.width <= self.originalWidth*10) {
            self.transform = CGAffineTransformScale(self.transform, scale, scale);
            [self fitCtrlScaleX:scale scaleY:scale];
        }
    }
    
    CGFloat tempScale = self.frame.size.width/self.originalWidth;
    if (self.pasteType == PasteTypeText && tempScale > 1) {
        [self.textLab.layer setContentsScale:tempScale * [[UIScreen mainScreen] scale]];
        [self.textLab.layer setNeedsDisplay];
    }
    
    oPoint = [self convertPoint:[self getRealOriginalPoint] toView:self.superview];
    self.center = CGPointMake(self.center.x + (self.center.x - oPoint.x), self.center.y + (self.center.y - oPoint.y));
}

#pragma mark - private

// 点击或平移
- (void)clickPasteImage:(UIView *)view {
    
    if (self.pasteType == PasteTypeImage) {
        if (!self.isOperation) {
            if (self.clickPasteImageBlock) {
                self.clickPasteImageBlock(view);
            }
            self.isOperation = YES;
        }
    }
    else {
        if (self.clickPasteImageBlock) {
            self.clickPasteImageBlock(view);
        }
        
        self.isOperation = YES;
    }
}

// 检测是否有回车
- (BOOL)textContainEnterWithStr:(NSString *)str {
    NSString *signStr = @"\n";
    BOOL isContainEnter = NO;

    for (int i = 0; i<str.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *tempStr = [str substringWithRange:range];
        if ([tempStr isEqualToString:signStr]) {
            isContainEnter = YES;
            break;
        }
    }
    return isContainEnter;
}

/** 控制按钮保持大小不变 */
- (void)fitCtrlScaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY {
    self.removeBtn.transform = CGAffineTransformScale(self.removeBtn.transform, 1/scaleX, 1/scaleY);
    self.rotateAndZoomBtn.transform = CGAffineTransformScale(self.rotateAndZoomBtn.transform, 1/scaleX, 1/scaleY);
}

/** 计算两点间距 */
- (CGFloat)distanceWithStartPoint:(CGPoint)start endPoint:(CGPoint)end {
    CGFloat x = start.x - end.x;
    CGFloat y = start.y - end.y;
    return sqrt(x * x + y * y);
}

/** 获取参考点坐标 */
- (CGPoint)getRealOriginalPoint {
    return CGPointMake(self.bounds.size.width * self.originalPoint.x,
                       self.bounds.size.height * self.originalPoint.y);
}

#pragma mark - UIGestureRecognizerDelegate

/** 同时触发多个手势 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

/** 当点击旋转控制按钮时，禁止全图平移手势 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer.view == self) {
        CGPoint p = [touch locationInView:self];
        if (CGRectContainsPoint(self.rotateAndZoomBtn.frame, p)) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 懒加载

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(Ctrl_Radius, Ctrl_Radius, self.frame.size.width-Ctrl_Radius*2, self.frame.size.height-Ctrl_Radius*2)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
        
//        _imageView.layer.magnificationFilter = @"linear";// linear nearest
    }
    return _imageView;
}

- (UILabel *)textLab {
    if (!_textLab) {
        _textLab = [[UILabel alloc] initWithFrame:CGRectMake(Ctrl_Radius, Ctrl_Radius, self.frame.size.width-Ctrl_Radius*2, self.frame.size.height-Ctrl_Radius*2)];
        _textLab.text = @"点击添加文本";
        _textLab.textColor = [UIColor blackColor];
        _textLab.font = [UIFont systemFontOfSize:20];
        _textLab.textAlignment = NSTextAlignmentCenter;
        _textLab.numberOfLines = 0;
    }
    return _textLab;
}

- (UIImageView *)removeBtn {
    if (!_removeBtn) {
        _removeBtn = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Ctrl_Radius*2, Ctrl_Radius*2)];
        _removeBtn.userInteractionEnabled = YES;
        _removeBtn.image = [UIImage imageNamed:@"diy_clear"];
        _removeBtn.layer.cornerRadius = Ctrl_Radius;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeCtrlTapGesture:)];
        [_removeBtn addGestureRecognizer:tapGesture];
    }
    return _removeBtn;
}

- (UIImageView *)rotateAndZoomBtn {
    if (!_rotateAndZoomBtn) {
        _rotateAndZoomBtn = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-Ctrl_Radius*2, self.frame.size.height-Ctrl_Radius*2, Ctrl_Radius*2, Ctrl_Radius*2)];
        _rotateAndZoomBtn.image = [UIImage imageNamed:@"diy_drag"];
        _rotateAndZoomBtn.userInteractionEnabled = YES;
        _rotateAndZoomBtn.layer.cornerRadius = Ctrl_Radius;
        _rotateAndZoomBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotateCtrlPanGesture:)];
        [_rotateAndZoomBtn addGestureRecognizer:panGesture];
    }
    return _rotateAndZoomBtn;
}

- (UIRotationGestureRecognizer *)rotateGesture {
    if (!_rotateGesture) {
        _rotateGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotateAction:)];
        _rotateGesture.delegate = self;
    }
    return _rotateGesture;
}

- (UIPinchGestureRecognizer *)pinchGesture {
    if (!_pinchGesture) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchAction:)];
        _pinchGesture.delegate = self;
    }
    return _pinchGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    }
    return _panGesture;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
    }
    return _tapGesture;
}

@end

//
//  StickersView.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "StickersView.h"
#import "PasteImageView.h"

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kArtboardViewMargin 15
#define kArtboardViewWidth (kScreenWidth - kArtboardViewMargin*2)

@interface StickersView ()

@property (nonatomic, strong) NSMutableArray *addViewList;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation StickersView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        [self addGestureRecognizer:self.tapGesture];
    }
    return self;
}

- (void)setSelctedImage:(UIImage *)selctedImage {
    _selctedImage = selctedImage;
    
    [self addPasteViewWithImage:selctedImage];
}

- (void)setSelctedImageUrl:(NSString *)selctedImageUrl {
    _selctedImageUrl = selctedImageUrl;
    
    [self addPasteViewWithImage:[self getImageWithURL:selctedImageUrl]];
}

#pragma mark - Help Method

// 添加照片
- (void)addPasteViewWithImage:(UIImage *)image {
    
    [self cleanSubviewOperationStatus];
    
    CGSize viewSize = [self initializePasteImageViewSizeWithImage:image];
    
    CGRect frame = CGRectMake((self.bounds.size.width-viewSize.width)/2.0, (self.bounds.size.height - viewSize.height)/2.0, viewSize.width, viewSize.height);
    
    PasteImageView *pasteView = [[PasteImageView alloc]initWithFrame:frame];
    pasteView.pasteType =   PasteTypeImage;
    pasteView.image = image;
    pasteView.isOperation = YES;
    [self addSubview:pasteView];

    __weak __typeof(&*self)weakSelf = self;
    pasteView.clickPasteImageBlock = ^(UIView * _Nonnull clickView) {
        [weakSelf bringSubviewToFront:clickView];
        [weakSelf cleanSubviewOperationStatus];
    };
    
    pasteView.removeBlock = ^(PasteImageView * _Nonnull pasteImageView) {
        [weakSelf.addViewList removeObject:pasteImageView];
    };
    
    [self.addViewList insertObject:pasteView atIndex:0];
}

/// 清除所有已添加子视图的可操作状态
- (void)cleanSubviewOperationStatus {
    [self.addViewList enumerateObjectsUsingBlock:^(PasteImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isOperation) {
            obj.isOperation = NO;
        }
    }];
}

// 初始化图片尺寸
- (CGSize)initializePasteImageViewSizeWithImage:(UIImage *)image {
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    // 最终添加视图的宽高
    CGFloat width = 0;
    CGFloat height = 0;
    
    if (imageWidth > imageHeight) {
        CGFloat tempWidth = imageWidth > kArtboardViewWidth ? kArtboardViewWidth - Ctrl_Radius *2 : imageWidth;
        width = tempWidth;
        height = (width * imageHeight / imageWidth);
        
    } else if (imageWidth < imageHeight) {
        
        CGFloat tempHeight = imageHeight > kArtboardViewWidth ? kArtboardViewWidth - Ctrl_Radius *2 : imageHeight;
        height = tempHeight;
        width = (height * imageWidth / imageHeight);
        
    } else {
        CGFloat margin = imageWidth == kArtboardViewWidth ? 20*2 : 0;// 如果正好等于屏幕宽度，则四周需要留出间距
        CGFloat tempWidth = imageWidth > kArtboardViewWidth ? kArtboardViewWidth - Ctrl_Radius *2 : imageWidth - margin;
        width = tempWidth;
        height = tempWidth;
    }
    
    width += Ctrl_Radius *2;
    height += Ctrl_Radius *2;
    
    return CGSizeMake(width, height);
}

// 获取网络图片
- (UIImage *)getImageWithURL:(id)imageURL {
    
    NSURL *URL = nil;
    
    if ([imageURL isKindOfClass:[NSURL class]]) {
        URL = imageURL;
    }
    
    if ([imageURL isKindOfClass:[NSString class]]) {
        URL = [NSURL URLWithString:imageURL];
    }
    
    NSData *data = [NSData dataWithContentsOfURL:URL];
    UIImage *image = [UIImage imageWithData:data];
    
    return image;
}

// 截图
- (UIImage *)snapshot {
    if (self.addViewList.count > 0) {
        [self cleanSubviewOperationStatus];
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

- (NSMutableArray *)addViewList {
    if (!_addViewList) {
        _addViewList = [NSMutableArray array];
    }
    return _addViewList;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
    }
    return _tapGesture;
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture {
    
    [self cleanSubviewOperationStatus];
}

@end

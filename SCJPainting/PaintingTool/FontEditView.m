//
//  FontEditView.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "FontEditView.h"
#import "PasteImageView.h"

@interface FontEditView ()

@property (nonatomic, assign) CGFloat originOffsetX;
@property (nonatomic, assign) CGFloat originOffsetY;
@end

@implementation FontEditView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)addText {
   
    [self addTextBox];
}

// 添加文本框
- (void)addTextBox {
    
    [self cleanSubviewOperationStatus];
    
    [self originOffset:YES];

    CGSize viewSize = [self initializePasteImageViewSize];
    CGRect frame = CGRectMake((self.bounds.size.width-viewSize.width)/2.0 + self.originOffsetX, (self.bounds.size.height - viewSize.height)/2.0 + self.originOffsetY, viewSize.width, viewSize.height);
    
    PasteImageView *pasteView = [[PasteImageView alloc]initWithFrame:frame];
    pasteView.pasteType = PasteTypeText;
    pasteView.isOperation = YES;
    [self addSubview:pasteView];
    
    __weak __typeof(&*self)weakSelf = self;
    pasteView.clickPasteImageBlock = ^(UIView * _Nonnull clickView) {
        
        if (weakSelf.textBoxPanOrTapBlock) {
            weakSelf.textBoxPanOrTapBlock(clickView, ((PasteImageView*)clickView).isOperation, ((PasteImageView*)clickView).isTapGesture);
        }
        
        [weakSelf bringSubviewToFront:clickView];
        [weakSelf cleanSubviewOperationStatus];
        
        [weakSelf bringObjToFront:clickView];
    };
    
    pasteView.removeBlock = ^(PasteImageView * _Nonnull pasteImageView) {
        [weakSelf.textViewList removeObject:pasteImageView];
        [self originOffset:NO];
    };
    
    [self.textViewList addObject:pasteView];
}

// 截图
- (UIImage *)snapshot {
    if (self.textViewList.count > 0) {
    
        // 截图时隐藏边框和按钮，以及未输入文字的输入框
        NSMutableArray *tempArr = [NSMutableArray array];
        [self.textViewList enumerateObjectsUsingBlock:^(PasteImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isOperation) {
                obj.isOperation = NO;
            }
            
            if (!(obj.text.length > 0)) {
               [tempArr addObject:obj];
               [obj removeFromSuperview];
            }
        }];
        
        if (tempArr.count < self.textViewList.count) {
            @autoreleasepool {
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
                [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                return image;
            }
        }
        [self.textViewList removeObjectsInArray:tempArr];
    }
    return nil;
}

#pragma mark - Help

// 初始化图片尺寸
- (CGSize)initializePasteImageViewSize {
    CGFloat width = 160 + Ctrl_Radius *2;
    CGFloat height = 52 + Ctrl_Radius *2;
    
    return CGSizeMake(width, height);
}

/// 清除所有已添加子视图的可操作状态
- (void)cleanSubviewOperationStatus {
    [self.textViewList enumerateObjectsUsingBlock:^(PasteImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isOperation) {
            obj.isOperation = NO;
        }
    }];
}

- (void)bringObjToFront:(UIView *)clickView {
    
    for (PasteImageView *pasteView in self.textViewList) {
        if ((PasteImageView *)clickView == pasteView) {
            NSUInteger index = [self.textViewList indexOfObject:pasteView];
            [self.textViewList removeObjectAtIndex:index];
            [self.textViewList insertObject:pasteView atIndex:0];
            break;
        }
    }
}

- (void)originOffset:(BOOL)isAdd {
    int offset = isAdd ? 20 : -20;
    if (self.textViewList.count > 0) {
        self.originOffsetX += offset;
        self.originOffsetY += offset;
    }
}

#pragma mark -

- (NSMutableArray *)textViewList {
    if (!_textViewList) {
        _textViewList = [NSMutableArray array];
    }
    return _textViewList;
}
@end

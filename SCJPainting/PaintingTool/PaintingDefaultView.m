//
//  PaintingDefaultView.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "PaintingDefaultView.h"
#import "CacheTool.h"

#import <Masonry.h>
#import <YYKit.h>

@interface PaintingDefaultView ()

/// 背景View
@property (nonatomic, strong) UIImageView *diyBgImageView;

@end

@implementation PaintingDefaultView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - setter

- (void)setBgImage:(UIImage *)bgImage {
    _bgImage = bgImage;
    
    self.diyBgImageView.image = bgImage;
}

- (void)back {
    if (self.addImageArr.count > 0) {
        UIImageView *imageView = self.addImageArr.lastObject;
        [imageView removeFromSuperview];
        
        [self.backImageArr insertObject:imageView atIndex:0];
        
        [self.addImageArr removeLastObject];

        [self backAndNextBlock];
    }
}

- (void)next {
    if (self.backImageArr.count > 0) {
        
        UIImageView *imageView = self.backImageArr.firstObject;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.diyBgImageView);
        }];
        
        [self.addImageArr addObject:imageView];
        
        [self.backImageArr removeFirstObject];
        
        [self backAndNextBlock];
    }
}

- (void)addImage:(UIImage *)image edit:(BOOL)isEdit {
    if (!isEdit) {
        if ([CacheTool containsObjectForName:@"kCacheName" objectForKey:@"kCacheKey"]) {
            [CacheTool removeCacheWithName:@"kCacheName"];
        }
    }
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = image;
    [self addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.diyBgImageView);
    }];
    
    [self.addImageArr addObject:imageView];
}

- (void)addCacheImage:(NSArray *)imageArr {
    for (UIImageView *imageView in imageArr) {
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.diyBgImageView);
        }];
        
        [self.addImageArr addObject:imageView];
    }
}

- (void)cleanRevokeImage {
    [self.backImageArr removeAllObjects];
}

#pragma mark - Help

- (void)backAndNextBlock {
    if (self.backAndNextClickBlock) {
        self.backAndNextClickBlock(self.addImageArr, self.backImageArr);
    }
}

/** 截图 */
- (UIImage *)snapshot {
    @autoreleasepool {
        
        self.diyBgImageView.backgroundColor = [UIColor clearColor];
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.diyBgImageView.backgroundColor = [UIColor colorWithRed:242/255.0 green:245/255.0 blue:255/255.0 alpha:1];
        
        return image;
    }
    return nil;
}

// 合并图片

- (UIImage *)mergeImage  {
    if (self.addImageArr.count > 0) {
        
//        [self.addImageArr insertObject:self.diyBgImageView atIndex:0];
        
        UIGraphicsBeginImageContext(self.bounds.size);
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
        for (UIImageView *imageView in self.addImageArr) {
            [imageView.image drawInRect:CGRectMake(0, 0, imageView.size.width, imageView.size.height)];
        }
        UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
//        [self.addImageArr removeObjectAtIndex:0];
        
        return resultingImage;
    }
    return nil;
}

#pragma mark - Layuot

- (void)setupUI {
    
    [self addSubview:self.diyBgImageView];
   
    [self.diyBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark - 懒加载

- (UIImageView *)diyBgImageView {
    if (!_diyBgImageView) {
        _diyBgImageView = [[UIImageView alloc] init];
        _diyBgImageView.backgroundColor = [UIColor colorWithRed:242/255.0 green:245/255.0 blue:255/255.0 alpha:1];
        _diyBgImageView.clipsToBounds = YES;
        _diyBgImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _diyBgImageView;
}

- (NSMutableArray *)addImageArr {
    if (!_addImageArr) {
        _addImageArr = [NSMutableArray array];
    }
    return _addImageArr;
}

- (NSMutableArray *)backImageArr {
    if (!_backImageArr) {
        _backImageArr = [NSMutableArray array];
    }
    return _backImageArr;
}

@end

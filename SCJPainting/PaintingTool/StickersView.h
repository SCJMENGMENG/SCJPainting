//
//  StickersView.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StickersView : UIView

@property (nonatomic, strong) UIImage *selctedImage;

@property (nonatomic, copy) NSString *selctedImageUrl;

/// 截屏
- (UIImage *)snapshot;
@end

NS_ASSUME_NONNULL_END

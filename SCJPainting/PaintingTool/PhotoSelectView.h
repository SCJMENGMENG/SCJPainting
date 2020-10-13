//
//  PhotoSelectView.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoSelectView : UIView

@property (nonatomic, copy) void(^cellSelectedBlock)(NSInteger indexPathRow, UIImage *image);
@property (nonatomic, copy) void(^closeAndOpenBtnClickBlock)(BOOL btnSelected);
@end

NS_ASSUME_NONNULL_END

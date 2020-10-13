//
//  StickersViewController.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^StickersVCPopBlock)(UIImage *image);

@interface StickersViewController : UIViewController

@property (nonatomic, copy) StickersVCPopBlock stickersVCPopBlock;

+ (void)openStickersVCWithDiyBgImage:(UIImage *)bgImage baseVC:(UIViewController *)vc lastImage:(UIImage *)lastImage confirmBlock:(StickersVCPopBlock)stickersVCPopBlock;
@end

NS_ASSUME_NONNULL_END

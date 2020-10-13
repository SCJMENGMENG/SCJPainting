//
//  ColorSelectModel.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColorSelectModel : NSObject
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END

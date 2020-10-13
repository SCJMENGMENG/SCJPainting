//
//  CacheTool.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CacheTool : NSObject

+ (void)removeCacheWithName:(NSString *)yyCacheName;

+ (BOOL)containsObjectForName:(NSString *)yyCacheName objectForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

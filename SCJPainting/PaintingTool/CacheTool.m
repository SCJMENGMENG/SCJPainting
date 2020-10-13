//
//  CacheTool.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "CacheTool.h"

#import <YYCache.h>

@implementation CacheTool

+ (void)removeCacheWithName:(NSString *)yyCacheName {
    YYCache *cache = [YYCache cacheWithName:yyCacheName];
    [cache removeAllObjects];
}

+ (BOOL)containsObjectForName:(NSString *)yyCacheName objectForKey:(NSString *)key {
    YYCache *cache = [YYCache cacheWithName:yyCacheName];
    BOOL isContains = [cache containsObjectForKey:key];
    return isContains;
}


@end

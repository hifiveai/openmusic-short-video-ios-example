//
//  NSArray+ACCAdditions.m
//  Pods
//
//  Created by bytedance on 2019/9/27.
//

#import "NSArray+DVEAlbumAdditions.h"


@implementation NSArray (DVEAlbumAdditions)

- (id)acc_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return self[index];
    } else {
        return nil;
    }
}

//-----由SMCheckProject工具删除-----
//- (NSString *)acc_stringWithIndex:(NSUInteger)index {
//    id value = [self acc_objectAtIndex:index];
//    if (value == nil || value == [NSNull null]) {
//        return nil;
//    }
//
//    if ([value isKindOfClass:[NSString class]]) {
//        return (NSString *)value;
//    }
//
//    if ([value isKindOfClass:[NSNumber class]]) {
//        return [value stringValue];
//    }
//
//    return nil;
//}


//-----由SMCheckProject工具删除-----
//- (NSDictionary *)acc_dictionaryWithIndex:(NSUInteger)index {
//    id value = [self acc_objectAtIndex:index];
//    if (value == nil || value == [NSNull null]) {
//        return nil;
//    }
//
//    if ([value isKindOfClass:[NSDictionary class]]) {
//        return value;
//    }
//
//    return nil;
//}

- (NSArray *)acc_mapObjectsUsingBlock:(id  _Nonnull (^)(id _Nonnull, NSUInteger))block
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [result addObject:block(obj, idx)];
    }];
    return result.copy;
}

- (id)acc_match:(BOOL (^)(id _Nonnull))matcher
{
    if (!matcher) {
        return nil;
    }
    for (id item in [self copy]) {
        if (matcher(item)) {
            return item;
        }
    }
    return nil;
}

- (NSArray *)acc_filter:(BOOL (^)(id _Nonnull))filter
{
    if (!filter) {
        return self;
    }
    NSArray *tmp = [self copy];
    NSMutableArray *array = [NSMutableArray array];
    for (id item in tmp) {
        if (filter(item)) {
            [array addObject:item];
        }
    }
    return [array copy];
}

@end


@implementation NSMutableArray (ACCAdditions)

- (void)acc_addObject:(id)object {
    if (object != nil) {
        [self addObject:object];
    }
}

@end


@implementation NSArray (ACCJSONString)

- (NSString *)acc_JSONString {
    NSString *jsonString = [self acc_JSONStringWithOptions:NSJSONWritingPrettyPrinted];
    return jsonString;
}

- (NSString *)acc_JSONStringWithOptions:(NSJSONWritingOptions)opt {
    NSError *error = nil;
    NSData *jsonData;
    @try {
        jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                   options:opt
                                                     error:&error];
    } @catch (NSException *exception) {
    }
    if (jsonData == nil) {
        NSAssert(error,@"fail to get JSON");
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end




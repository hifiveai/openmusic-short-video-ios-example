//
//  NSArray+ACCAdditions.h
//  Pods
//
//  Created by bytedance on 2019/9/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/****************    Immutable Array        ****************/
@interface NSArray<__covariant ObjectType> (DVEAlbumAdditions)

/**
 return value if index is valid, return nil if others.
 */
- (ObjectType)acc_objectAtIndex:(NSUInteger)index;

/**
 return @"" if value is nil or NSNull; return value if NSString or NSNumber class; return nil if others
 */
//-----由SMCheckProject工具删除-----
//- (NSString *)acc_stringWithIndex:(NSUInteger)index;

/**
 return nil if value is nil or NSNull; return NSDictionary if value is NSDictionary; return nil if others.
 */
//-----由SMCheckProject工具删除-----
//- (NSDictionary *)acc_dictionaryWithIndex:(NSUInteger)index;


- (NSArray *)acc_mapObjectsUsingBlock:(id(^)(id obj, NSUInteger idex))block;
/**
 * return any item matched by matcher
 * return nil if no item matched
 */
- (_Nullable ObjectType)acc_match:(BOOL (^)(ObjectType item))matcher;

/**
 * return a new array of items applied by filter
 */
- (NSArray *)acc_filter:(BOOL (^)(ObjectType item))filter;

@end



/****************    Mutable Array        ****************/
@interface NSMutableArray (ACCAdditions)

/**
 add object if object is not nil; add object if object is [NSNull null]; do nothing if object is nil.
 */
- (void)acc_addObject:(id)object;

@end


@interface NSArray (ACCJSONString)

- (NSString *)acc_JSONString;

- (NSString *)acc_JSONStringWithOptions:(NSJSONWritingOptions)opt;

@end


NS_ASSUME_NONNULL_END



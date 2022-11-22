//
//   DVEModuleBaseCategoryModel.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/20.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEModuleBaseCategoryModel.h"

@implementation DVEModuleBaseCategoryModel

@synthesize cachedWidth;

- (BOOL)isLoading {
    return NO;
}


- (void)loadModelListIfNeeded {
    
}

-(NSString*)name {
    return self.category.name;
}

- (BOOL)favorite {
    return NO;
}

- (NSArray<DVEEffectValue *> *)models {
    return self.category.models;
}




@end

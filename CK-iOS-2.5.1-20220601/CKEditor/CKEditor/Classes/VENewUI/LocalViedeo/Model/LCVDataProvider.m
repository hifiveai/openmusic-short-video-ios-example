//
//  LCVDataProvider.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/5/25.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "LCVDataProvider.h"

@implementation LCVDataProvider

+ (NSArray *)readAllFilesAtDir:(NSString *)dirPath
{
    NSURL *dirUrl = [NSURL fileURLWithPath:dirPath];
    if (!dirUrl) {
        return @[];
    }
    // 工程目录
    NSString *BASE_PATH = dirPath;
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray *subDirArr = [myFileManager contentsOfDirectoryAtPath:BASE_PATH error:nil];
            
    BOOL isDir = NO;
    BOOL isExist = NO;
    
    NSMutableArray *fileArr = [NSMutableArray new];
            
    //列举目录内容，可以遍历子目录
    for (NSString *path in subDirArr) {
                
        NSLog(@"%@", path);  // 所有路径
                
        isExist = [myFileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", BASE_PATH, path] isDirectory:&isDir];
            if (isDir) {
                NSLog(@"LCVDataProvider：%@", path);    // 目录路径
                
            } else {
                NSLog(@"LCVDataProvider:%@", [BASE_PATH stringByAppendingPathComponent:path]);    // 文件路径
                [fileArr addObject:[BASE_PATH stringByAppendingPathComponent:path]];
            }
        
    }
    
    return fileArr;
}

+ (NSArray *)readAllDirAtDir:(NSString *)dirPath
{
    NSURL *dirUrl = [NSURL fileURLWithPath:dirPath];
    if (!dirUrl) {
        return @[];
    }
    // 工程目录
    NSString *BASE_PATH = dirPath;
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray *subDirArr = [myFileManager contentsOfDirectoryAtPath:BASE_PATH error:nil];
            
    BOOL isDir = NO;
    BOOL isExist = NO;
    
    NSMutableArray *dirArr = [NSMutableArray new];
            
    //列举目录内容，可以遍历子目录
    for (NSString *path in subDirArr) {
                
        NSLog(@"%@", path);  // 所有路径
                
        isExist = [myFileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", BASE_PATH, path] isDirectory:&isDir];
            if (isDir) {
                NSLog(@"LCVDataProvider:%@", path);    // 目录路径
                [dirArr addObject:path];
            } else {
                NSLog(@"LCVDataProvider:%@", path);    // 文件路径
                
            }
        
    }
    
    return dirArr;
}

+ (NSArray *)getAllDrafts
{
    NSString *videoLocalPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/localVideo"];
    
    NSFileManager *fileManager =  [NSFileManager defaultManager];
    //判断文件是否存在
    BOOL isExist = [fileManager fileExistsAtPath:videoLocalPath];
    return [LCVDataProvider readAllFilesAtDir:videoLocalPath];
}

@end

//
//  DVERequestModel.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/23.
//

#import "DVERequestModel.h"

@implementation DVERequestModel

@synthesize bodyBlock = _bodyBlock;
@synthesize fileName = _fileName;
@synthesize fileURL = _fileURL;
@synthesize headerField = _headerField;
@synthesize needCommonParams = _needCommonParams;
@synthesize objectClass = _objectClass;
@synthesize params = _params;
@synthesize targetPath = _targetPath;
@synthesize timeout = _timeout;
@synthesize urlString = _urlString;
@synthesize requestType = _requestType;
@synthesize requestSerializer = _requestSerializer;


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestType = DVERequestTypeGET;
        self.needCommonParams = YES;
    }
    return self;
}

@end

//
//  DVERequestModel.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/23.
//

#import <Foundation/Foundation.h>
#import <TTNetworkManager/TTNetworkManager.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DVERequestType) {
    DVERequestTypeGET,      //GET方法请求一个指定资源的表示形式. 使用GET的请求应该只被用于获取数据
    DVERequestTypeHEAD,     //HEAD方法请求一个与GET请求的响应相同的响应，但没有响应体
    DVERequestTypePOST,     //POST方法用于将实体提交到指定的资源，通常导致在服务器上的状态变化或副作用
    DVERequestTypePUT,      //PUT方法用请求有效载荷替换目标资源的所有当前表示
    DVERequestTypeDELETE,   //DELETE方法删除指定的资源
    DVERequestTypeCONNECT,  //CONNECT方法建立一个到由目标资源标识的服务器的隧道
    DVERequestTypeOPTIONS,  //OPTIONS方法用于描述目标资源的通信选项
    DVERequestTypeTRACE,    //TRACE方法沿着到目标资源的路径执行一个消息环回测试
    DVERequestTypePATCH     //PATCH方法用于对资源应用部分修改
};

@protocol DVERequestModelProtocol <NSObject>
//common
@property (nonatomic, assign) DVERequestType requestType;//请求类型
@property (nonatomic,   copy) NSString *urlString;       //接口
@property (nonatomic,   copy) NSDictionary *params;      //参数
@property (nonatomic, assign) BOOL needCommonParams;     //公共参数
@property (nonatomic, strong) NSDictionary *headerField; //header
@property (nonatomic, assign) NSTimeInterval timeout;    //超时时间
@property (nonatomic, strong) Class objectClass;         //response model class
//upload
@property (nonatomic, strong) NSURL * fileURL;           //文件路径
@property (nonatomic,   copy) NSString * fileName;       //文件名
//如果请求的body内需要带有文件名和文件，需要通过该block设置
@property (nonatomic,   copy) TTConstructingBodyBlock bodyBlock;
@property (nonatomic, strong) Class<TTHTTPRequestSerializerProtocol> requestSerializer;
@property (nonatomic, strong) Class<TTJSONResponseSerializerProtocol> responseSerializer;
//downlaod
@property (nonatomic,   copy) NSString * targetPath;     //下载路径
@end



@interface DVERequestModel : NSObject<DVERequestModelProtocol>

@end

NS_ASSUME_NONNULL_END

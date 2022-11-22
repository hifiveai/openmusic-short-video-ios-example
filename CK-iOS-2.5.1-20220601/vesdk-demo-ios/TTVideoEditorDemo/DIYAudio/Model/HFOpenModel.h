//
//  HFOpenModel.h
//  HFOpenMusic
//
//  Created by 郭亮 on 2021/3/23.
//

#import <Foundation/Foundation.h>
@class HFOpenRadioModel,HFOpenChannelSheetTagModel,HFOpenMusicAuthorModel,HFOpenMusicComposerModel,HFOpenMusicArrangerModel,HFOpenMusicCoverModel,HFOpenMusicVersionModel,HFOpenMusicArtistModel,HFOpenMusicModel;

@interface HFOpenModel : NSObject

@end


@interface HFOpenChannelModel : NSObject

@property(nonatomic ,copy)NSString*groupId;//电台id
@property(nonatomic ,copy)NSString*groupName;//电台名称
@property(nonatomic ,copy)NSString*coverUrl;//电台封面

@end


@interface HFOpenChannelSheetModel : NSObject

@property(nonatomic ,copy)NSString*sheetId;//歌单id
@property(nonatomic ,copy)NSString*sheetName;//歌单名
@property(nonatomic ,copy)NSString*musicTotal;//音乐总数
@property(nonatomic ,copy)NSString*describe;//歌单描述
@property(nonatomic ,copy)NSString*free;//是否免费,1：免费 0：收费
@property(nonatomic ,copy)NSString*price;//歌单价格（分）
@property(nonatomic ,copy)NSString*type;//歌单类型， 1：自定义歌单，0：系统歌单
@property(nonatomic ,copy)NSArray <HFOpenChannelSheetTagModel *>*tag;//标签数组
@property(nonatomic ,copy)NSArray <HFOpenMusicModel *>*music;//音乐列表
@property(nonatomic ,copy)NSArray <HFOpenMusicCoverModel *>*cover;

@end

@interface HFOpenMetaModel : NSObject

@property(nonatomic ,assign)NSInteger totalCount;
@property(nonatomic ,assign)NSInteger currentPage;

@end


@interface HFOpenChannelSheetTagModel: NSObject

@property(nonatomic ,assign)NSInteger tagId;//封面图片
@property(nonatomic ,copy)NSString *tagName;//封面尺寸，该字段可能为""，代表没有设置尺寸

@end


@interface HFOpenMusicModel : NSObject

@property(nonatomic ,copy)NSString *musicId;//音乐id
@property(nonatomic ,copy)NSString *musicName;//音乐名
@property(nonatomic ,copy)NSString *albumId;//专辑id
@property(nonatomic ,copy)NSString *albumName;//专辑名

@property(nonatomic ,copy)NSArray <HFOpenMusicAuthorModel *>*author;//作词者
@property(nonatomic ,copy)NSArray <HFOpenMusicComposerModel *>*composer;//作曲者
@property(nonatomic ,copy)NSArray <HFOpenMusicArrangerModel *>*arranger;//编曲者
@property(nonatomic ,copy)NSArray <HFOpenMusicCoverModel *>*cover;//封面
@property(nonatomic ,copy)NSString *duration;//时长（秒），此字段可能和播放器读取时长有一定误差
@property(nonatomic ,copy)NSString *auditionBegin;//推荐试听开始时间
@property(nonatomic ,copy)NSString *auditionEnd;//推荐试听结束时间
@property(nonatomic ,copy)NSString *bpm;//每分钟节拍
@property(nonatomic ,copy)NSArray <HFOpenChannelSheetTagModel *>*tag;//标签数组
@property(nonatomic ,copy)NSArray <HFOpenMusicVersionModel *>*version;//版本信息
@property(nonatomic ,copy)NSArray <HFOpenMusicArtistModel *>*artist;//表演者


//自加属性
@property(nonatomic ,assign)      BOOL isPlaying;
@property(nonatomic ,assign)      BOOL isDownloading;
@end


@interface HFOpenMusicArtistModel : NSObject

@property(nonatomic ,copy)NSString *name;//表演者
@property(nonatomic ,copy)NSString *code;//表演者编号
@property(nonatomic ,copy)NSString *avatar;//表演者头像

@end


@interface HFOpenMusicAuthorModel : NSObject

@property(nonatomic ,copy)NSString *name;//作词者
@property(nonatomic ,copy)NSString *code;//作词者编号
@property(nonatomic ,copy)NSString *avatar;//作词者头像

@end



@interface HFOpenMusicComposerModel : NSObject

@property(nonatomic ,copy)NSString *name;//作曲者
@property(nonatomic ,copy)NSString *code;//作曲者编号
@property(nonatomic ,copy)NSString *avatar;//作曲者头像

@end


@interface HFOpenMusicArrangerModel : NSObject

@property(nonatomic ,copy)NSString *name;//编曲者
@property(nonatomic ,copy)NSString *code;//编曲者编号
@property(nonatomic ,copy)NSString *avatar;//编曲者头像

@end



@interface HFOpenMusicCoverModel : NSObject

@property(nonatomic ,copy)NSString *url;//封面
@property(nonatomic ,copy)NSString *size;//封面尺寸，该字段可能为""，代表没有设置尺寸

@end



@interface HFOpenMusicVersionModel : NSObject

@property(nonatomic ,copy)NSString *musicId;
@property(nonatomic ,copy)NSString *name;
@property(nonatomic ,copy)NSString *majorVersion;
@property(nonatomic ,copy)NSString *free;
@property(nonatomic ,copy)NSString *price;
@property(nonatomic ,copy)NSString *duration;
@property(nonatomic ,copy)NSString *auditionBegin;
@property(nonatomic ,copy)NSString *auditionEnd;

@end

@interface HFOpenMusicDetailInfoSubModel : NSObject

/// 歌曲
@property(nonatomic ,copy)NSString *path;
/// 波形图路径
@property(nonatomic ,copy)NSString *wavePath;
/// 相对父歌的开始时间
@property(nonatomic ,copy)NSString *startTime;
/// 相对父歌结束时间
@property(nonatomic ,copy)NSString *endTime;
/// 版本名称
@property(nonatomic ,copy)NSString *versionName;
@end

@interface HFOpenMusicDetailInfoModel : NSObject

@property(nonatomic ,copy)NSString *musicId;
@property(nonatomic ,copy)NSString *expires;
@property(nonatomic ,copy)NSString *fileUrl;
@property(nonatomic ,copy)NSString *fileSize;
@property(nonatomic ,copy)NSString *waveUrl;


/// 动态歌词
@property(nonatomic ,copy)NSString *dynamicLyricUrl;

/// 静态歌词
@property(nonatomic ,copy)NSString *staticLyricUrl;

@property (nonatomic, strong) NSArray<HFOpenMusicDetailInfoSubModel *> *subVersions;
@end


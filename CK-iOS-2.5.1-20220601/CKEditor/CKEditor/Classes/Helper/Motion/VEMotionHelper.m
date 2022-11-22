//
//  VEMotionHelper.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEMotionHelper.h"
#import <CoreMotion/CoreMotion.h>

@interface VEMotionHelper ()

@property (nonatomic, strong) NSHashTable <id <VEMotionHelperProtocol>>*delegates;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) UIDeviceOrientation direction;

@end

@implementation VEMotionHelper

static VEMotionHelper *instance = nil;

static const float kYSensitive = 0.618;
static const float kXSensitive = 0.9;

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.delegates = [NSHashTable weakObjectsHashTable];
        
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 0.5f;
        
    }
    return self;
}


- (void)startWithDelegate:(id<VEMotionHelperProtocol>)delegate
{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
        if (self.delegates.count == 1) {
            if (_motionManager.deviceMotionAvailable) {
                
                [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                                    withHandler: ^(CMDeviceMotion *motion, NSError *error){
                    [self performSelectorOnMainThread:@selector(deviceMotion:) withObject:motion waitUntilDone:YES];
                }];
            }
        }
    }
    
}

- (void)stopWithDelegate:(id<VEMotionHelperProtocol>)delegate
{
    if ([self.delegates containsObject:delegate]) {
        [self.delegates removeObject:delegate];
    }
    
    if (self.delegates.count == 0) {
        [_motionManager stopDeviceMotionUpdates];
    }
}

- (void)deviceMotion:(CMDeviceMotion *)motion{
    
    double x = motion.gravity.x;
    double y = motion.gravity.y;
    if (y < 0 ) {
        if (fabs(y) > kYSensitive) {
            if (_direction != UIDeviceOrientationPortrait) {
                _direction = UIDeviceOrientationPortrait;
                
                
            }
        }
    }else {
        if (y > kYSensitive) {
            if (_direction != UIDeviceOrientationPortraitUpsideDown) {
                _direction = UIDeviceOrientationPortraitUpsideDown;
                
            }
        }
    }
    if (x < 0 ) {
        if (fabs(x) > kXSensitive) {
            if (_direction != UIDeviceOrientationLandscapeLeft) {
                _direction = UIDeviceOrientationLandscapeLeft;
                
            }
        }
    }else {
        if (x > kXSensitive) {
            if (_direction != UIDeviceOrientationLandscapeRight) {
                _direction = UIDeviceOrientationLandscapeRight;
                
            }
        }
    }
    
    
    for (id obj in self.delegates) {
        if ([obj respondsToSelector:@selector(directionChange:)]) {
            [obj directionChange:_direction];
        }
    }
}

@end

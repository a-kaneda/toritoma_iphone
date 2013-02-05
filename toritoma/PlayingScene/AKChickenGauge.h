/*!
 @file AKChickenGauge.h
 @brief チキンゲージクラス定義
 
 チキンゲージのクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// チキンゲージクラス
@interface AKChickenGauge : CCNode {
    /// 空ゲージの画像
    CCSprite *emptyImage_;
    /// 満ゲージの画像
    CCSprite *fullImage_;
    /// ゲージの溜まっている比率
    float percent_;
}

/// 空ゲージの画像
@property (nonatomic, retain)CCSprite *emptyImage;
/// 満ゲージの画像
@property (nonatomic, retain)CCSprite *fullImage;
/// ゲージの溜まっている比率
@property (nonatomic)float percent;

@end

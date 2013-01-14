/*!
 @file AKPlayer.h
 @brief 自機クラス定義
 
 自機を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCharacter.h"

// 自機クラス
@interface AKPlayer : AKCharacter {
    /// 無敵状態かどうか
    BOOL isInvincible_;
    /// 無敵状態の残り時間
    float invincivleTime_;
}

/// 無敵状態かどうか
@property (nonatomic)BOOL isInvincible;

// 復活
- (void)rebirth;
// 初期化
- (void)reset;

@end
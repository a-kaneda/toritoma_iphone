/*!
 @file AKPlayData.h
 @brief ゲームデータ
 
 プレイ画面シーンのデータを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "AKPlayingScene.h"
#import "AKPlayer.h"

@class AKPlayingScene;

// ゲームデータ
@interface AKPlayData : NSObject {
    /// シーンクラス(弱い参照)
    AKPlayingScene *scene_;
    /// 自機
    AKPlayer *player_;
}

/// シーンクラス(弱い参照)
@property (nonatomic, readonly)AKPlayingScene *scene;
/// 自機
@property (nonatomic, retain)AKPlayer *player;

// オブジェクト初期化処理
- (id)initWithScene:(AKPlayingScene *)scene;
// 状態更新
- (void)update:(ccTime)dt;

@end

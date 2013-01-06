/*!
 @file AKPlayData.h
 @brief ゲームデータ
 
 プレイ画面シーンのデータを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "AKPlayingScene.h"

@class AKPlayingScene;

// ゲームデータ
@interface AKPlayData : NSObject {
    /// シーンクラス(弱い参照)
    AKPlayingScene *scene_;
}

/// シーンクラス(弱い参照)
@property (nonatomic, readonly)AKPlayingScene *scene;

// オブジェクト初期化処理
- (id)initWithScene:(AKPlayingScene *)scene;

@end

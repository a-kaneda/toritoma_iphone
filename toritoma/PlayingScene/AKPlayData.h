/*!
 @file AKPlayData.h
 @brief ゲームデータ
 
 プレイ画面シーンのデータを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "AKPlayingScene.h"
#import "AKPlayer.h"
#import "AKScript.h"

@class AKPlayingScene;

// ゲームデータ
@interface AKPlayData : NSObject {
    /// シーンクラス(弱い参照)
    AKPlayingScene *scene_;
    /// スクリプト情報
    AKScript *script_;
    /// 自機
    AKPlayer *player_;
}

/// シーンクラス(弱い参照)
@property (nonatomic, readonly)AKPlayingScene *scene;
/// スクリプト情報
@property (nonatomic, retain)AKScript *script;
/// 自機
@property (nonatomic, retain)AKPlayer *player;

// インスタンス取得
+ (AKPlayData *)getInstance;
// オブジェクト初期化処理
- (id)initWithScene:(AKPlayingScene *)scene;
// 状態更新
- (void)update:(ccTime)dt;
// スクリプト読み込み
- (void)readScript:(NSInteger)stage;
// スクリプト実行再開
- (void)resumeScript;
// 自機の移動
- (void)movePlayerByDx:(float)dx dy:(float)dy;

@end

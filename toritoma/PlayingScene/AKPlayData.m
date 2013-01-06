/*!
 @file AKPlayData.m
 @brief ゲームデータ
 
 プレイ画面シーンのゲームデータを管理するクラスを定義する。
 */

#import "AKPlayData.h"

/*!
 @brief ゲームデータ
 
 プレイ画面のゲームデータを管理する。
 */
@implementation AKPlayData

@synthesize scene = scene_;

/*!
 @brief オブジェクト初期化処理
 
 オブジェクトの初期化を行う。
 @param scene プレイシーン
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithScene:(AKPlayingScene *)scene
{
    AKLog(1, @"start");
    
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        AKLog(1, @"error");
        return nil;
    }
    
    // シーンをメンバに設定する
    scene_ = scene;
    
    AKLog(1, @"end");
    return self;
}

@end

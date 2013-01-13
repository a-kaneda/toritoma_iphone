/*!
 @file AKCharacter.h
 @brief キャラクタークラス定義
 
 当たり判定を持つオブジェクトの基本クラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "AKLib.h"
#import "cocos2d.h"

// キャラクタークラス
@interface AKCharacter : NSObject {
    /// 画像
    CCSprite *image_;
    /// 当たり判定サイズ幅
    NSInteger width_;
    /// 当たり判定サイズ高さ
    NSInteger height_;
    /// 位置x座標
    float positionX_;
    /// 位置y座標
    float positionY_;
    /// 速度x方向
    float speedX_;
    /// 速度y方向
    float speedY_;
    /// HP
    NSInteger hitPoint_;
    /// ステージ上に存在しているかどうか
    BOOL isStaged_;
    /// アニメーションパターン数
    NSInteger animationPattern_;
    /// アニメーション間隔
    float animationInterval_;
    /// アニメーション時間
    float animationTime_;
    /// 画像読み込み位置
    CGPoint imageBasePos_;
    /// 画像サイズ
    CGSize imageSize_;
}

/// 画像
@property (nonatomic, retain)CCSprite *image;
/// 当たり判定サイズ幅
@property (nonatomic)NSInteger width;
/// 当たり判定サイズ高さ
@property (nonatomic)NSInteger height;
/// 位置x座標
@property (nonatomic)float positionX;
/// 位置y座標
@property (nonatomic)float positionY;
/// 速度x方向
@property (nonatomic)float speedX;
/// 速度y方向
@property (nonatomic)float speedY;
/// HP
@property (nonatomic)NSInteger hitPoint;
/// ステージ上に存在しているかどうか
@property (nonatomic)BOOL isStaged;
/// アニメーションパターン数
@property (nonatomic)NSInteger animationPattern;
/// アニメーション間隔
@property (nonatomic)float animationInterval;
/// アニメーション時間
@property (nonatomic)float animationTime;
/// 画像読み込み位置
@property (nonatomic)CGPoint imageBasePos;
/// 画像サイズ
@property (nonatomic)CGSize imageSize;

// 移動処理
- (void)move:(ccTime)dt;
// キャラクター固有の動作
- (void)action:(ccTime)dt;
// 破壊処理
- (void)destroy;
// 衝突判定
- (void)hit:(const NSEnumerator *)characters;
// 画面外配置判定
- (BOOL)isOutOfStage;
@end

/*!
 @file AKEnemy.h
 @brief 敵クラス定義
 
 敵キャラクターのクラスの定義をする。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCharacter.h"

/// 敵画像定義
struct AKEnemyImageDef {
    NSInteger fileNo;           ///< ファイル名の番号
    NSInteger animationFrame;   ///< アニメーションフレーム数
    float animationInterval;    ///< アニメーション更新間隔
};

/// 敵種別定義
struct AKEnemyDef {
    NSInteger action;       ///< 動作処理の種別
    NSInteger destroy;      ///< 破壊処理の種別
    NSInteger image;        ///< 画像ID
    NSInteger hitWidth;     ///< 当たり判定の幅
    NSInteger hitHeight;    ///< 当たり判定の高さ
    NSInteger hitPoint;     ///< ヒットポイント
    NSInteger score;        ///< スコア
};

// 敵クラス
@interface AKEnemy : AKCharacter {
    /// 動作開始からの経過時間(各敵種別で使用)
    ccTime time_;
    /// 動作状態(各敵種別で使用)
    NSInteger state_;
    /// 動作処理のセレクタ
    SEL action_;
    /// 破壊処理のセレクタ
    SEL destroy_;
    /// スコア
    NSInteger score_;
}

// 生成処理
- (void)createEnemyType:(NSInteger)type x:(NSInteger)x y:(NSInteger)y parent:(CCNode*)parent;
// 動作処理取得
- (SEL)actionSelector:(NSInteger)type;
// 破壊処理取得
- (SEL)destroySeletor:(NSInteger)type;
// 動作処理1
- (void)action_01:(ccTime)dt;
// 動作処理2
- (void)action_02:(ccTime)dt;
// 破壊処理1
- (void)destroy_01;
// n-Way弾発射
- (void)fireNWay:(NSInteger)way interval:(float)interval speed:(float)speed;
@end

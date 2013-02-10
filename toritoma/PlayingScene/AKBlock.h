/*!
 @file AKBlock.h
 @brief 障害物クラス
 
 障害物を管理するクラスを定義する。
 */

#import "AKCharacter.h"

/// 障害物定義
struct AKBlcokDef {
    NSInteger image;            ///< 画像ファイル名の番号
    NSInteger animationFrame;   ///< アニメーションフレーム数
    float animationInterval;    ///< アニメーション更新間隔
    NSInteger hitWidth;         ///< 当たり判定の幅
    NSInteger hitHeight;        ///< 当たり判定の高さ
};

// 障害物クラス
@interface AKBlock : AKCharacter {
    
}

// 障害物生成処理
- (void)createBlockType:(NSInteger)type x:(NSInteger)x y:(NSInteger)y parent:(CCNode *)parent;
// ぶつかったキャラクターを押し動かす
- (void)pushCharacter:(AKCharacter *)character;
// ぶつかったキャラクターを消す
- (void)destroyCharacter:(AKCharacter *)character;

@end

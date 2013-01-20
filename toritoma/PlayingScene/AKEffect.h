/*!
 @file AKEffect.h
 @brief 画面効果クラス定義
 
 爆発等の画面効果を生成するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKLib.h"
#import "AKCharacter.h"

/// 画面効果定義
struct AKEffectDef {
    NSInteger fileNo;           ///< ファイル名の番号
    NSInteger width;            ///< 幅
    NSInteger height;           ///< 高さ
    NSInteger animationFrame;   ///< アニメーションフレーム数
    float animationInterval;    ///< アニメーション更新間隔
    NSInteger animationRepeat;  ///< アニメーション繰り返し回数
};

// 画面効果クラス
@interface AKEffect : AKCharacter {
}

// 画面効果開始
- (void)createEffectType:(NSInteger)type x:(NSInteger)x y:(NSInteger)y z:(NSInteger)z parent:(CCLayer *)parent;

@end

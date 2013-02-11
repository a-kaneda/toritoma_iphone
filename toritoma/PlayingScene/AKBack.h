/*!
 @file AKBack.h
 @brief 背景クラス
 
 背景を管理するクラスを定義する。
 */

#import "AKCharacter.h"

/// 背景定義
struct AKBackDef {
    NSInteger image;            ///< 画像ファイル名の番号
    NSInteger animationFrame;   ///< アニメーションフレーム数
    float animationInterval;    ///< アニメーション更新間隔
};

// 背景クラス
@interface AKBack : AKCharacter {
    
}

// 背景生成処理
- (void)createBackType:(NSInteger)type x:(NSInteger)x y:(NSInteger)y parent:(CCNode *)parent;

@end

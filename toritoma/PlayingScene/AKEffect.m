/*!
 @file AKEffect.m
 @brief 画面効果クラス定義
 
 爆発等の画面効果を生成するクラスを定義する。
 */

#import "AKEffect.h"

/// 画像名のフォーマット
static NSString *kAKImageNameFormat = @"Effect_%02d";
/// 画面効果の種類の数
static const NSInteger kAKEffectDefCount = 1;
/// 画面効果の定義
static const struct AKEffectDef kAKEffectDef[kAKEffectDefCount] = {
    {1, 32, 32, 8, 0.1f, 1}    // 爆発
};

/*!
 @brief 画面効果クラス
 
 爆発等の画面効果を生成する。
 */
@implementation AKEffect

/*!
 @brief 画面効果開始
 
 画面効果を生成する。
 @param type 画面効果の種別
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param parent 画面効果を配置する親ノード
 */
- (void)createEffectType:(NSInteger)type x:(NSInteger)x y:(NSInteger)y parent:(CCLayer *)parent
{
    // パラメータの内容をメンバに設定する
    self.positionX = x;
    self.positionY = y;
    
    // 画面配置フラグとHPを設定する
    self.isStaged = YES;
    self.hitPoint = 1;
    
    NSAssert(type > 0 && type <= kAKEffectDefCount, @"画面効果種別が不正");
    
    // 画像名を作成する
    self.imageName = [NSString stringWithFormat:kAKImageNameFormat, kAKEffectDef[type - 1].fileNo];
        
    // アニメーションフレームの個数を設定する
    self.animationPattern = kAKEffectDef[type - 1].animationFrame;
    
    // アニメーションフレーム間隔を設定する
    self.animationInterval = kAKEffectDef[type - 1].animationInterval;
    
    // アニメーション繰り返し回数を設定する
    self.animationRepeat = kAKEffectDef[type - 1].animationRepeat;

    // レイヤーに配置する
    [parent addChild:self.image];
}
@end

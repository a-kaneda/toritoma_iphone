/*!
 @file AKPlayer.m
 @brief 自機クラス定義
 
 自機を管理するクラスを定義する。
 */

#import "AKPlayer.h"
#import "AKPlayData.h"
#import "AKEnemyShot.h"

/// 自機のサイズ
static const NSInteger kAKPlayerSize = 8;
/// 自機のかすり判定サイズ
static const NSInteger kAKPlayerGrazeSize = 32;
/// 復活後の無敵状態の時間
static const float kAKInvincibleTime = 2.0f;
/// 自機の画像ファイル名
static NSString *kAKPlayerImageFile = @"Player_%02d";
/// 画像サイズ
static const float kAKPlayerImageSize = 32;
/// アニメーションフレーム数
static const NSInteger kAKPlayerAnimationCount = 2;
/// 弾発射の間隔
static const float kAKPlayerShotInterval = 0.2f;

/*!
 @brief 自機クラス

 自機を管理する。
 */
@implementation AKPlayer

@synthesize isInvincible = isInvincible_;
@synthesize chickenGauge = chickenGauge_;

/*!
 @brief オブジェクト生成処理

 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }

    // サイズを設定する
    self.width = kAKPlayerSize;
    self.height = kAKPlayerSize;
    
    // アニメーションフレームの個数を設定する
    self.animationPattern = kAKPlayerAnimationCount;
    
    // 状態を初期化する
    [self reset];
    
    // 画像名を設定する
    self.imageName = [NSString stringWithFormat:kAKPlayerImageFile, 1];
    
    // 弾発射までの残り時間を設定する
    shootTime_ = kAKPlayerShotInterval;
    
    // チキンゲージをリセットする
    self.chickenGauge = 0.0f;
                                              
    return self;
}

/*!
 @brief キャラクター固有の動作

 速度によって位置を移動する。自機の表示位置は固定とする。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    // 無敵状態の時は無敵時間をカウントする
    if (isInvincible_) {
        invincivleTime_ -= dt;
        
        // 無敵時間が切れている場合は通常状態に戻す
        if (invincivleTime_ < 0.0f) {
            isInvincible_ = NO;
        }
    }
    
    // 弾発射までの時間をカウントする
    shootTime_ -= dt;
    
    // 弾発射までの残り時間が0になっている場合は弾を発射する
    if (shootTime_ < 0.0f) {
        
        // 自機弾を生成する
        [[AKPlayData getInstance] createPlayerShotAtX:self.positionX y:self.positionY];
        
        // 弾発射までの残り時間をリセットする
        shootTime_ = kAKPlayerShotInterval;
    }
}

/*!
 @brief 破壊処理
 
 HPが0になったときに爆発エフェクトを生成する。
 */
- (void)destroy
{
    // 破壊時の効果音を鳴らす

    // 画面効果を生成する
    
    // 配置フラグを落とす
    self.isStaged = NO;
    
    // 非表示とする
    self.image.visible = NO;
    
    // 自機破壊時の処理を行う
}

/*!
 @brief 復活
 
 破壊された自機を復活させる。
 */
- (void)rebirth
{    
    // HPの設定
    hitPoint_ = 1;
    
    // ステージ配置フラグを立てる
    isStaged_ = YES;
    
    // 表示させる
    self.image.visible = YES;
    
    // 無敵状態にする
    isInvincible_ = YES;
    invincivleTime_ = kAKInvincibleTime;
    
    // 無敵中はブリンクする
    CCBlink *blink = [CCBlink actionWithDuration:kAKInvincibleTime blinks:kAKInvincibleTime * 8];
    [self.image runAction:blink];
}

/*!
 @brief 初期化
 
 状態を初期化する。
 */
- (void)reset
{
    // 初期位置は原点
    self.image.position = ccp(0, 0);
    
    // HPの設定
    hitPoint_ = 1;
    
    // ステージ配置フラグを立てる
    isStaged_ = YES;
    
    // 表示させる
    self.image.visible = YES;
    
    // 無敵状態はOFFにする
    isInvincible_ = NO;
    invincivleTime_ = 0.0f;
    
    // アクションはすべて停止する
    [self.image stopAllActions];
}

/*!
 @brief かすり判定
 
 自機が敵弾にかすっているか判定し、かすっている場合は弾のかすりポイントを自機の方へ移す。
 @param characters 判定対象のキャラクター群
 */
- (void)graze:(const NSEnumerator *)characters
{
    // 画面に配置されていない場合は処理しない
    if (!self.isStaged) {
        return;
    }
    
    // 自キャラのかすり判定の上下左右の端を計算する
    float myleft = self.positionX - kAKPlayerGrazeSize / 2.0f;
    float myright = self.positionX + kAKPlayerGrazeSize / 2.0f;
    float mytop = self.positionY + kAKPlayerGrazeSize / 2.0f;
    float mybottom = self.positionY - kAKPlayerGrazeSize / 2.0f;
    
    // 判定対象のキャラクターごとに判定を行う
    for (AKEnemyShot *target in characters) {
        
        // 相手が画面に配置されていない場合は処理しない
        if (!target.isStaged) {
            continue;
        }
        
        // 相手の上下左右の端を計算する
        float targetleft = target.positionX - target.width / 2.0f;
        float targetright = target.positionX + target.width / 2.0f;
        float targettop = target.positionY + target.height / 2.0f;
        float targetbottom = target.positionY - target.height / 2.0f;
        
        AKLog(0, @"target=(%f, %f, %f, %f)", targetleft, targetright, targettop, targetbottom);
        
        // 以下のすべての条件を満たしている時、衝突していると判断する。
        //   ・相手の右端が自キャラの左端よりも右側にある
        //   ・相手の左端が自キャラの右端よりも左側にある
        //   ・相手の上端が自キャラの下端よりも上側にある
        //   ・相手の下端が自キャラの上端よりも下側にある
        if ((targetright > myleft) &&
            (targetleft < myright) &&
            (targettop > mybottom) &&
            (targetbottom < mytop)) {
            
            // 相手のかすりポイントを取得する
            if (target.grazePoint > 0.0f) {
                self.chickenGauge += target.grazePoint;
            }
            
            // 相手のかすりポイントをリセットする
            target.grazePoint = 0.0f;
            
            AKLog(1, @"chickenGauge=%f", self.chickenGauge);
        }
    }
}
@end

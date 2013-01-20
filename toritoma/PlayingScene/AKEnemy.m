/*!
 @file AKEnemy.m
 @brief 敵クラス定義
 
 敵キャラクターのクラスの定義をする。
 */

#import "AKEnemy.h"

/// 爆発エフェクト画像のファイル名
static NSString *kAKExplosion = @"Explosion.png";
/// 爆発エフェクトの位置とサイズ
static const CGRect kAKExplosionRect = {0, 0, 32, 32};
/// 爆発エフェクトのフレーム数
static const NSInteger kAKExplosionFrameCount = 8;
/// 爆発エフェクトのフレーム更新間隔
static const float kAKExplosionFrameDelay = 0.2f;

/// 画像ファイル名のフォーマット
static NSString *kAKImageFileFormat = @"Enemy_%02d.png";
/// 画像の種類の数
static const NSInteger kAKEnemyImageDefCount = 1;
/// 敵の種類の数
static const NSInteger kAKEnemyDefCount = 1;

/// 敵画像の定義
static const struct AKEnemyImageDef kAKEnemyImageDef[] = {
    {1, 32, 32, 2, 0.05f}   // トンボ
};

/// 敵の定義
static const struct AKEnemyDef kAKEnemyDef[] = {
    {1, 1, 1, 32, 32, 1, 100}   // トンボ
};

/*!
 @brief 敵クラス
 
 敵キャラクターのクラス。
 */
@implementation AKEnemy

/*!
 @brief キャラクター固有の動作

 生成時に指定されたセレクタを呼び出す。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    NSNumber *objdt = NULL;     // フレーム更新間隔(オブジェクト版)
    
    // 動作開始からの経過時間をカウントする
    time_ += dt;
    
    // id型として渡すためにNSNumberを作成する
    objdt = [NSNumber numberWithFloat:dt];
    
    // 敵種別ごとの処理を実行
    [self performSelector:action_ withObject:objdt];
}

/*!
 @brief 破壊処理

 HPが0になったときに敵種別固有の破壊処理を呼び出す。
 */
- (void)destroy
{
    // 破壊時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKHitSE];
    
    // 敵種別ごとの処理を実行
    [self performSelector:destroy_];
    
    // 画像の解放
    [self.image removeFromParentAndCleanup:YES];
    self.image = nil;
    
    // スーパークラスの処理を行う
    [super destroy];
}

/*!
 @brief 生成処理

 敵キャラを生成する。
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param z 生成位置z座標
 @param parent 敵キャラを配置する親ノード
 */
- (void)createEnemyType:(NSInteger)type x:(NSInteger)x y:(NSInteger)y z:(NSInteger)z parent:(CCNode*)parent;
{
    // パラメータの内容をメンバに設定する
    self.positionX = x;
    self.positionY = y;
    
    // 配置フラグを立てる
    isStaged_ = YES;
    
    // 動作時間をクリアする
    time_ = 0;
    
    // 状態をクリアする
    state_ = 0;
    
    NSAssert(type > 0 && type <= kAKEnemyDefCount, @"敵の種類の値が範囲外");
    NSAssert(kAKEnemyDef[type - 1].image <= kAKEnemyImageDefCount, @"敵の画像の種類の値が範囲外");
    
    // 動作処理を設定する
    action_ = [self actionSelector:kAKEnemyDef[type - 1].action];
    
    // 破壊処理を設定する
    destroy_ = [self destroySeletor:kAKEnemyDef[type - 1].destroy];
    
    // 画像定義を取得する
    const struct AKEnemyImageDef *imageDef = &kAKEnemyImageDef[kAKEnemyDef[type - 1].image - 1];
    
    // ファイル名を作成する
    NSString *imageFile = [NSString stringWithFormat:kAKImageFileFormat, imageDef->fileNo];

    // 画像を読み込む
    self.image = [CCSprite spriteWithFile:imageFile
                                     rect:CGRectMake(0.0f,
                                                     0.0f,
                                                     imageDef->width,
                                                     imageDef->height)];
    
    // 画像サイズを設定する
    self.imageSize = CGSizeMake(imageDef->width, imageDef->height);
    
    // アニメーションフレームの個数を設定する
    self.animationPattern = imageDef->animationFrame;
    
    // アニメーションフレーム間隔を設定する
    self.animationInterval = imageDef->animationInterval;
    
    // 当たり判定のサイズを設定する
    self.width = kAKEnemyDef[type - 1].hitWidth;
    self.height = kAKEnemyDef[type - 1].hitHeight;
    
    // ヒットポイントを設定する
    self.hitPoint = kAKEnemyDef[type - 1].hitPoint;
    
    // スコアを設定する
    score_ = kAKEnemyDef[type - 1].score;
    
    // レイヤーに配置する
    [parent addChild:self.image z:z];
}

/*!
 @brief 動作処理取得
 
 種別番号から動作処理のセレクタを取得する。
 @param type 種別番号
 @return 動作処理のセレクタ
 */
- (SEL)actionSelector:(NSInteger)type
{
    switch (type) {
        case 1:
            return @selector(action_01:);
            
        default:
            NSAssert(0, @"不正な種別");
            return @selector(action_01:);
    }
}

/*!
 @brief 破壊処理取得
 
 種別番号から破壊処理のセレクタを取得する。
 @param type 種別番号
 @return 破壊処理のセレクタ
 */
- (SEL)destroySeletor:(NSInteger)type
{
    switch (type) {
        case 1:
            return @selector(destroy_01);
            
        default:
            NSAssert(0, @"不正な種別");
            return @selector(destroy_01);
    }
}

/*!
 @brief 動作処理1
 
 まっすぐ進む。一定間隔で自機を狙う1-way弾発射。
 @param dt フレーム更新間隔
 */
- (void)action_01:(ccTime)dt
{
    // 左へ直進する
    self.speedX = -120.0f;
    self.speedY = 0.0f;
    
    // 一定時間経過しているときは自機を狙う1-way弾を発射する
    if (time_ > 1.0f) {
        
        // 弾を発射する
        [self fireNWay:1 interval:0.0f];
        
        // 動作時間の初期化を行う
        time_ = 0.0f;
    }
    
    AKLog(0, @"pos=(%f, %f)", self.positionX, self.positionY);
    AKLog(0, @"img=(%f, %f)", self.image.position.x, self.image.position.y);
}

/*!
 @brief 破壊処理1
 
 破壊エフェクトを発生させる。
 */
- (void)destroy_01
{
    // 画面効果を生成する
//    [[AKGameScene getInstance] entryEffect:kAKExplosion
//                                 startRect:kAKExplosionRect
//                                frameCount:kAKExplosionFrameCount
//                                     delay:kAKExplosionFrameDelay
//                                      posX:self.absx posY:self.absy];
}

/*!
 @brief n-Way弾発射
 
 n-Way弾の発射を行う。
 @param way 発射方向の数
 @param interval 弾の間隔
 */
- (void)fireNWay:(NSInteger)way interval:(float)interval
{
    // 発射角度を計算する
//    NSArray *angleArray = AKCalcNWayAngle(way, self.angle, interval);
    
    // 各弾を発射する
//    for (NSNumber *angle in angleArray) {
//        // 通常弾を生成する
//    }
}
@end

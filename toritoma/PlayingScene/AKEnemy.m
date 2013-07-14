/*
 * Copyright (c) 2013 Akihiro Kaneda.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1.Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   2.Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   3.Neither the name of the Monochrome Soft nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
/*!
 @file AKEnemy.m
 @brief 敵クラス定義
 
 敵キャラクターのクラスの定義をする。
 */

#import "AKEnemy.h"

/// 画像名のフォーマット
static NSString *kAKImageNameFormat = @"Enemy_%02d";
/// 敵の種類の数
static const NSInteger kAKEnemyDefCount = 40;

/// 敵の定義
static const struct AKEnemyDef kAKEnemyDef[kAKEnemyDefCount] = {
    //動作,破壊,画像,フレーム数,フレーム間隔幅,高さ,HP,スコア
    {1, 1, 1, 2, 0.5f, 32, 32, 3, 100},     // トンボ
    {2, 1, 2, 2, 0.5f, 32, 16, 3, 100},     // アリ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // チョウ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // テントウムシ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備5
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備6
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備7
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備8
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備9
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備10
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // ミノムシ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // セミ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // バッタ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // ハチ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備15
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備16
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備17
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備18
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備19
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備20
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // ゴキブリ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // カタツムリ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // クワガタ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備24
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備25
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備26
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備27
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備28
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備29
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備30
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // カブトムシ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // カマキリ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // ハチの巣
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // クモ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // ムカデ（頭）
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // ムカデ（胴体）
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // ムカデ（尾）
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // ウジ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0},         // ハエ
    {0, 0, 0, 0, 0.0f, 0, 0, 0, 0}          // 予備40
};

/// 標準弾の種別
static const NSInteger kAKEnemyShotTypeNormal = 1;

/*!
 @brief 敵クラス
 
 敵キャラクターのクラス。
 */
@implementation AKEnemy

/*!
 @brief キャラクター固有の動作

 生成時に指定されたセレクタを呼び出す。
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)action:(ccTime)dt data:(id<AKPlayDataInterface>)data
{
    NSNumber *objdt = NULL;     // フレーム更新間隔(オブジェクト版)
    
    // 動作開始からの経過時間をカウントする
    time_ += dt;
    
    // id型として渡すためにNSNumberを作成する
    objdt = [NSNumber numberWithFloat:dt];
    
    // 敵種別ごとの処理を実行
    [self performSelector:action_ withObject:objdt withObject:data];
}

/*!
 @brief 破壊処理

 HPが0になったときに敵種別固有の破壊処理を呼び出す。
 @param data ゲームデータ
 */
- (void)destroy:(id<AKPlayDataInterface>)data
{
    // 破壊時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKHitSE];
    
    // スコアを加算する
    [data addScore:score_];
    
    // 進行度を進める
    [data addProgress:progress_];
    
    // 敵種別ごとの処理を実行
    [self performSelector:destroy_ withObject:data];
    
    // 画像の解放
    [self.image removeFromParentAndCleanup:YES];
    self.image = nil;
    
    // スーパークラスの処理を行う
    [super destroy:data];
}

/*!
 @brief 生成処理

 敵キャラを生成する。
 @param type 敵キャラの種別
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param progress 倒した時に進む進行度
 @param parent 敵キャラを配置する親ノード
 */
- (void)createEnemyType:(NSInteger)type x:(NSInteger)x y:(NSInteger)y progress:(NSInteger)progress parent:(CCNode *)parent
{
    // パラメータの内容をメンバに設定する
    self.positionX = x;
    self.positionY = y;
    progress_ = progress;
    
    // 配置フラグを立てる
    isStaged_ = YES;
    
    // 各メンバ変数を初期化する
    time_ = 0.0f;
    state_ = 0;
    work_ = 0;
    
    AKLog(type < 0 || type > kAKEnemyDefCount, @"敵の種類の値が範囲外:%d", type);
    NSAssert(type > 0 && type <= kAKEnemyDefCount, @"敵の種類の値が範囲外");
    
    // 動作処理を設定する
    action_ = [self actionSelector:kAKEnemyDef[type - 1].action];
    
    // 破壊処理を設定する
    destroy_ = [self destroySeletor:kAKEnemyDef[type - 1].destroy];
        
    // 画像名を作成する
    self.imageName = [NSString stringWithFormat:kAKImageNameFormat, kAKEnemyDef[type - 1].image];
                
    // アニメーションフレームの個数を設定する
    self.animationPattern = kAKEnemyDef[type - 1].animationFrame;
    
    // アニメーションフレーム間隔を設定する
    self.animationInterval = kAKEnemyDef[type - 1].animationInterval;
    
    // 当たり判定のサイズを設定する
    self.width = kAKEnemyDef[type - 1].hitWidth;
    self.height = kAKEnemyDef[type - 1].hitHeight;
    
    // ヒットポイントを設定する
    self.hitPoint = kAKEnemyDef[type - 1].hitPoint;
    
    // スコアを設定する
    score_ = kAKEnemyDef[type - 1].score;
    
    // レイヤーに配置する
    [parent addChild:self.image];
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
            return @selector(action_01:data:);
            
        case 2:
            return @selector(action_02:data:);
            
        default:
            NSAssert(NO, @"不正な種別");
            return @selector(action_01:data:);
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
            return @selector(destroy_01:);
            
        default:
            NSAssert(NO, @"不正な種別");
            return @selector(destroy_01:);
    }
}

/*!
 @brief 動作処理1
 
 まっすぐ進む。一定間隔で自機を狙う1-way弾発射。
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)action_01:(ccTime)dt data:(id<AKPlayDataInterface>)data
{
    // 左へ直進する
    self.speedX = -120.0f;
    self.speedY = 0.0f;
    
    // 一定時間経過しているときは自機を狙う1-way弾を発射する
    if (time_ > 1.0f) {
        
        // 弾を発射する
        [self fireNWay:1 interval:0.0f speed:150.0f data:data];
        
        // 動作時間の初期化を行う
        time_ = 0.0f;
    }
    
    AKLog(kAKLogEnemy_1, @"pos=(%f, %f)", self.positionX, self.positionY);
    AKLog(kAKLogEnemy_1, @"img=(%f, %f)", self.image.position.x, self.image.position.y);
}

/*!
 @brief 動作処理2
 
 天井または地面に張り付いて歩く。
 
 初期状態:初期状態。上下どちらに張り付くか判定する。距離の近い方に張り付く。
 地面に張り付く場合は左移動(地面)に、天井に張り付く場合は左移動(天井)に遷移する。
 天井に張り付く場合は画像を上下反転する。
 
 左移動:左方向への移動。一定時間経過後に弾発射に遷移する。
 
 弾発射:停止して弾の発射。自機に向かって1-wayを一定数発射する。
 一定時間経過後に右移動に遷移する。
 
 右移動:地面右方向への移動。一定時間経過後に弾発射に遷移する。
 
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)action_02:(ccTime)dt data:(id<AKPlayDataInterface>)data
{
    // 弾のスピード
    const float kAKShotSpeed = 150.0f;
    // 移動スピード
    const float kAKMoveSpeed = 48.0f;
    // 移動する時間
    const float kAKMoveTime = 2.0f;
    // 弾を発射する間隔
    const float kAKFireInterval = 0.5f;
    // 一度に発射する弾の数
    const NSInteger kAKFireCount = 4;
    
    // 状態
    enum STATE {
        kAKStateInit = 0,           // 初期状態
        kAKStateLeftMove,           // 左移動
        kAKStateRightMove,          // 右移動
        kAKStateFire                // 弾発射
    };
    
    // 状態によって処理を分岐する
    switch (state_) {
        case kAKStateInit:     // 初期状態
            
            // 逆さま判定を行う
            [self checkReverse:data.blocks];
            
             // 動作時間の初期化を行う
            time_ = 0.0f;
            
            // 左移動に遷移する
            state_ = kAKStateLeftMove;
            
            break;
            
        case kAKStateLeftMove:  // 左移動
            
            // スピードをマイナスにして、左右反転はなしにする
            self.speedX = -kAKMoveSpeed;
            self.image.flipX = NO;
            
            // 移動時間が経過したら弾発射に遷移する
            if (time_ > kAKMoveTime) {
                time_ = 0.0f;
                state_ = kAKStateFire;
            }

            break;

        case kAKStateRightMove: // 右移動
            
            // スピードをプラスにして、左右反転はありにする
            self.speedX = kAKMoveSpeed;
            self.image.flipX = YES;
            
            // 移動時間が経過したら弾発射に遷移する
            if (time_ > kAKMoveTime) {
                time_ = 0.0f;
                state_ =kAKStateFire;
            }
            
            break;
                        
        case kAKStateFire:  // 弾発射
            
            // 自分より右側に自機がいれば左右反転する
            if (self.positionX < data.playerPosition.x) {
                self.image.flipX = YES;
            }
            else {
                self.image.flipX = NO;
            }

            // 待機する
            self.speedX = 0;
            
            // 一定時間経過したら弾を発射する
            if (time_ > kAKFireInterval) {
                
                // 一度に発射する弾をすでに発射済みの場合は右移動へ遷移する
                if (work_ >= kAKFireCount) {
                    
                    work_ = 0;
                    time_ = 0.0f;
                    state_ = kAKStateRightMove;
                }
                else {
                    
                    // 弾を発射する
                    [self fireNWay:1 interval:0.0f speed:kAKShotSpeed data:data];
                    
                    // 発射した弾をカウントする
                    work_++;
                    
                    // 動作時間の初期化を行う
                    time_ = 0.0f;
                }
            }
            
            break;
            
        default:
            break;
    }
    
    // スクロールに合わせて移動する
    self.speedX -= data.scrollSpeedX;
    self.speedY -= data.scrollSpeedY;
    
    // 障害物との衝突判定を行う
    [self checkBlockPosition:data];
    
    AKLog(kAKLogEnemy_1, @"pos=(%f, %f)", self.positionX, self.positionY);
    AKLog(kAKLogEnemy_1, @"img=(%f, %f)", self.image.position.x, self.image.position.y);
}

/*!
 @brief 破壊処理1
 
 破壊エフェクトを発生させる。
 @param data ゲームデータ
 */
- (void)destroy_01:(id<AKPlayDataInterface>)data
{
    AKLog(kAKLogEnemy_1, @"start");
    
    // 画面効果を生成する
    [data createEffect:1 x:self.positionX y:self.positionY];
}

/*!
 @brief n-Way弾発射
 
 n-Way弾の発射を行う。
 @param way 発射方向の数
 @param interval 弾の間隔
 @param speed 弾の速度
 @param data ゲームデータ
 */
- (void)fireNWay:(NSInteger)way interval:(float)interval speed:(float)speed data:(id<AKPlayDataInterface>)data
{
    // 敵と自機の位置から角度を計算する
    float baseAnble = AKCalcDestAngle(self.positionX,
                                      self.positionY,
                                      data.playerPosition.x,
                                      data.playerPosition.y);
    
    // 発射角度を計算する
    NSArray *angleArray = AKCalcNWayAngle(way, baseAnble, interval);
    
    // 各弾を発射する
    for (NSNumber *angle in angleArray) {
        // 通常弾を生成する
        [data createEnemyShotType:kAKEnemyShotTypeNormal
                                x:self.positionX
                                y:self.positionY
                            angle:[angle floatValue]
                            speed:speed];
    }
}

/*!
 @brief 逆さま判定
 
 上方向にある障害物と下方向にある障害物の近い方へ位置を移動する。
 上方向の方が近い場合は天井張り付き、下方向の方が近い場合は床に張り付きとする。
 存在しない場合は無限遠にあるものとして判定し、上下同じ場合は下側を優先する。
 @param blocks 障害物
 */
- (void)checkReverse:(NSArray *)blocks
{
    // 上方向距離と下方向距離の初期値を設定する
    float upDistance = FLT_MAX;
    float downDistance = FLT_MAX;
    
    // 移動先位置の初期値を設定する
    float upPosition = self.image.contentSize.height / 2;
    float downPosition = self.image.contentSize.height / 2;

    // 各障害物との距離を調べる
    for (AKCharacter *block in [blocks objectEnumerator]) {
        
        // x軸方向に重なりがない場合は処理を飛ばす
        if (abs(self.positionX - block.positionX) > (self.image.contentSize.width + block.image.contentSize.width) / 2) {
            continue;
        }
        
        // 障害物が上方向にある場合は上方向距離を更新する
        if (self.positionY < block.positionY) {
            
            // 距離が小さい場合は距離と移動先位置を更新する
            if (block.positionY - self.positionY < upDistance) {
                
                upDistance = block.positionY - self.positionY;
                upPosition = block.positionY - (block.height + self.image.contentSize.height) / 2;
            }
        }
        // 上方向にない場合は下方向距離を更新する
        else {
            
            // 距離が小さい場合は距離と移動先位置を更新する
            if (self.positionY - block.positionY < downDistance) {
                
                downDistance = self.positionY - block.positionY;
                downPosition = block.positionY + (block.height + self.image.contentSize.height) / 2;
            }
        }
    }
    
    // 上方向の距離が小さい場合は上方向に移動して、逆さにする
    if (upDistance < downDistance) {
        self.positionY = upPosition;
        self.image.flipY = YES;
    }
    // 下方向の距離が小さい場合は下方向に移動する
    else {
        self.positionY = downPosition;
    }
}

/*!
 @brief 障害物との衝突判定
 
 障害物との衝突判定を行う。
 移動先と移動元の段差が1/2ブロック以上ある場合は移動しない。
 左端の足元と右端の足元で障害物の高さが異なる場合は高い方（逆さまの場合は低い方）に合わせる。
 @param data ゲームデータ
 */
- (void)checkBlockPosition:(id<AKPlayDataInterface>)data
{
    // 乗り越えることのできる高さ
    const NSInteger kAKHalfBlockSize = 17;
    
    // 頭の座標を計算する
    float top = 0.0f;
    if (!self.image.flipY) {
        top = self.positionY + self.image.contentSize.height / 2.0f;
    }
    else {
        top = self.positionY - self.image.contentSize.height / 2.0f;
    }
    
    // 左端の座標を計算する
    float left = self.positionX - self.image.contentSize.width / 2.0f;
    
    // 左側の足元の障害物を取得する
    AKCharacter *leftBlock = [AKEnemy getBlockAtFeetAtX:left
                                                   from:top
                                              isReverse:self.image.flipY
                                                 blocks:data.blocks];
    
    // 右端の座標を計算する
    float right = self.positionX + self.image.contentSize.width / 2.0f;

    // 左側の足元の障害物を取得する
    AKCharacter *rightBlock = [AKEnemy getBlockAtFeetAtX:right
                                                    from:top
                                               isReverse:self.image.flipY
                                                  blocks:data.blocks];
    
    // 足元に障害物がない場合は移動はしない
    if (leftBlock == nil && rightBlock == nil) {
        return;
    }
    
    // 高さを合わせる障害物と移動先のx座標を決定する
    AKCharacter *blockAtFeet = nil;
    float newX = 0.0f;

    // 左側の障害物がない場合は自分の左端を右側の障害物の左端に合わせる
    if (leftBlock == nil) {
        newX = rightBlock.positionX - rightBlock.width / 2.0f + self.image.contentSize.width / 2.0f;
        blockAtFeet = rightBlock;
    }
    // 右側の障害物がない場合は自分の右端を左側の障害物の右端に合わせる
    else if (rightBlock == nil) {
        newX = leftBlock.positionX + leftBlock.width / 2.0f - self.image.contentSize.width / 2.0f;
        blockAtFeet = leftBlock;
    }
    // 左右の障害物の高さの差が1/2ブロック以上ある場合は進行方向と逆側の障害物に合わせる
    else if (abs((leftBlock.positionY + leftBlock.height / 2.0f) - (rightBlock.positionY + rightBlock.height / 2.0f)) > kAKHalfBlockSize) {
        
        // 左向きに移動している場合は自分の左端を右側の障害物の左端に合わせる
        if (self.speedX + data.scrollSpeedX > 0.0f) {
            newX = rightBlock.positionX - rightBlock.width / 2.0f + self.image.contentSize.width / 2.0f;
            blockAtFeet = rightBlock;
        }
        // 右向きに移動している場合は自分の右端を左側の障害物の右端に合わせる
        else {
            newX = leftBlock.positionX + leftBlock.width / 2.0f - self.image.contentSize.width / 2.0f;
            blockAtFeet = leftBlock;
        }
    }
    // その他の場合は足元に近い方の高さに合わせる
    else {
        
        // 逆向きでない場合は上の方にあるものを採用する
        if (!self.image.flipY) {
            if (leftBlock.positionY + leftBlock.height / 2.0f > rightBlock.positionY + rightBlock.height / 2.0f) {
                blockAtFeet = leftBlock;
            }
            else {
                blockAtFeet = rightBlock;
            }
        }
        // 逆向きの場合は下の方にあるものを採用する
        else {
            if (leftBlock.positionY + leftBlock.height / 2.0f < rightBlock.positionY + rightBlock.height / 2.0f) {
                blockAtFeet = leftBlock;
            }
            else {
                blockAtFeet = rightBlock;
            }
        }
        
        // x軸方向は移動しない
        newX = self.positionX;
    }
    
    // 移動先のy座標を決定する
    float newY = 0.0f;
    
    // 逆向きでない場合は自分の下端の位置を障害物の上端に合わせる
    if (!self.image.flipY) {
        newY = blockAtFeet.positionY + blockAtFeet.height / 2.0f + self.image.contentSize.height / 2.0f;
    }
    // 逆向きの場合は自分の上端の位置を障害物の下端に合わせる
    else {
        newY = blockAtFeet.positionY - blockAtFeet.height / 2.0f - self.image.contentSize.height / 2.0f;
    }
    
    // 位置を移動する
    self.positionX = newX;
    self.positionY = newY;
    self.image.position = ccp([AKScreenSize xOfStage:self.positionX],
                              [AKScreenSize yOfStage:self.positionY]);
}

/*!
 @brief 足元の障害物を取得する
 
 足元の障害物を取得する。
 指定したx座標で一番上にある障害物を取得する。ただし、頭よりも上にある障害物は除外する。
 逆さまになっている場合は上下を逆にして検索を行う。
 @param x x座標
 @param top 頭の位置
 @param isReverse 逆さまになっているかどうか
 @param blocks 障害物
 @return 足元の障害物
 */
+ (AKCharacter *)getBlockAtFeetAtX:(float)x from:(float)top isReverse:(BOOL)isReverse blocks:(NSArray *)blocks
{    
    // 足元の障害物を探す
    AKCharacter *blockAtFeet = nil;
    for (AKCharacter *block in [blocks objectEnumerator]) {
        
        // 配置されていない障害物は除外する
        if (!block.isStaged) {
            continue;
        }
        
        // 障害物の幅の範囲内に指定座標が入っている場合
        if (block.positionX - block.width / 2 < x &&
            block.positionX + block.width / 2 > x) {
            
            // 逆さまでない場合
            if (!isReverse) {
                
                // 障害物の下端が自分の上端よりも下にあるものの内、
                // 一番上にあるものを採用する
                if (block.positionY - block.height / 2 < top &&
                    (blockAtFeet == nil || block.positionY + block.height / 2 > blockAtFeet.positionY + blockAtFeet.height / 2)) {
                    
                    blockAtFeet = block;
                }
            }
            // 逆さまの場合
            else {
                
                // 障害物の上端が自分の下端より上にあるものの内、
                // 一番下にあるものを採用する
                if (block.positionY + block.height / 2 > top &&
                    (blockAtFeet == nil || block.positionY - block.height / 2 < blockAtFeet.positionY - blockAtFeet.height / 2)) {
                    
                    blockAtFeet = block;
                }
            }
        }
    }
    
    return blockAtFeet;
}

@end

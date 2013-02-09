/*!
 @file AKCharacter.m
 @brief キャラクタークラス定義
 
 当たり判定を持つオブジェクトの基本クラスを定義する。
 */

#import "AKCharacter.h"

/// デフォルトアニメーション間隔
static const float kAKDefaultAnimationInterval = 0.2f;
/// 画像ファイル名のフォーマット
static NSString *kAKImageFileFormat = @"%@_%02d.png";

/*!
 @brief キャラクタークラス
 
 当たり判定を持つオブジェクトの基本クラス。
 */
@implementation AKCharacter

@synthesize image = image_;
@synthesize width = width_;
@synthesize height = height_;
@synthesize positionX = positionX_;
@synthesize positionY = positionY_;
@synthesize speedX = speedX_;
@synthesize speedY = speedY_;
@synthesize hitPoint = hitPoint_;
@synthesize power = power_;
@synthesize isStaged = isStaged_;
@synthesize animationPattern = animationPattern_;
@synthesize animationInterval = animationInterval_;
@synthesize animationTime = animationTime_;
@synthesize animationRepeat = animationRepeat_;

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
    
    // 各メンバを0で初期化する
    self.image = nil;
    self.width = 0;
    self.height = 0;
    self.positionX = 0.0f;
    self.positionY = 0.0f;
    self.speedX = 0.0f;
    self.speedY = 0.0f;
    self.hitPoint = 0;
    self.isStaged = NO;
    self.animationTime = 0.0f;
    
    // 攻撃力の初期値は1とする
    self.power = 1;
    
    // アニメーションのデフォルトパターン数は1(アニメーションなし)とする
    self.animationPattern = 1;
    
    // アニメーションのデフォルト間隔を設定する
    self.animationInterval = kAKDefaultAnimationInterval;
    
    // アニメーション繰り返し回数は0(無限)とする
    self.animationRepeat = 0;
    
    return self;
}

/*!
 @brief インスタンス解放時処理

 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // スプライトを解放する
    [self.image removeFromParentAndCleanup:YES];
    self.image = nil;
    
    // スーパークラスの解放処理
    [super dealloc];
}

/*!
 @brief 画像名の取得
 
 画像名を取得する。
 @return 画像名
 */
- (NSString *)imageName
{
    return imageName_;
}

/*!
 @brief 画像名の設定
 
 画像名を設定する。
 @param imageName 画像名
 */
- (void)setImageName:(NSString *)imageName
{
    // スプライト名を設定する
    if (imageName_ != imageName) {
        [imageName_ release];
        imageName_ = [imageName retain];
    }
    
    // スプライト名が設定された場合はスプライト作成を行う
    if (imageName_ != nil) {
        
        // 画像ファイル名を決定する
        NSString *imageFileName = [NSString stringWithFormat:kAKImageFileFormat, imageName_, 1];
        
        // スプライト作成前の場合はスプライトを作成する
        if (self.image == nil) {
            self.image = [CCSprite spriteWithSpriteFrameName:imageFileName];
        }
        // すでにスプライトを作成している場合は画像の切り替えを行う
        else {
            [self.image setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageFileName]];
        }
    }
}

/*!
 @brief 移動処理

 速度によって位置を移動する。
 アニメーションを行う。
 @param dt フレーム更新間隔
 */
- (void)move:(ccTime)dt
{
    // 画面に配置されていない場合は無処理
    if (!self.isStaged) {
        return;
    }
    
    // HPが0になった場合は破壊処理を行う
    if (self.hitPoint <= 0) {
        [self destroy];
        return;
    }
    
    // 画面外に出た場合は削除する
    if ([self isOutOfStage]) {

        // ステージ配置フラグを落とす
        self.isStaged = NO;
        
        // 画面から取り除く
        [self.image removeFromParentAndCleanup:YES];
        
        return;
    }
            
    // 座標の移動
    self.positionX += (self.speedX * dt);
    self.positionY += (self.speedY * dt);
    
    AKLog(0, @"pos=(%.0f, %.0f) scr=(%d, %d)", self.positionX, self.positionY, [AKScreenSize xOfStage:self.positionX], [AKScreenSize yOfStage:self.positionY]);
        
    // 表示座標の設定
    self.image.position = ccp([AKScreenSize xOfStage:self.positionX],
                              [AKScreenSize yOfStage:self.positionY]);
    
    // アニメーション時間をカウントする
    self.animationTime += dt;
    
    // 表示するパターンを決定する
    NSInteger pattern = 1;
    
    // アニメーションパターンが複数存在する場合はパターン切り替えを行う
    if (self.animationPattern >= 2) {
        
        // 経過時間からパターンを決定する
        pattern = (NSInteger)(self.animationTime / self.animationInterval) + 1;
    
        // パターンがパターン数を超えた場合はアニメーション時間をリセットし、パターンを最初のものに戻す。
        if (pattern > self.animationPattern) {
            self.animationTime = 0.0f;
            pattern = 1;
            
            // 繰り返し回数が設定されている場合
            if (self.animationRepeat > 0) {
                
                // 繰り返し回数を減らす
                self.animationRepeat--;
                
                // 繰り返し回数が0になった場合は画面から取り除く
                if (self.animationRepeat <= 0) {
                    
                    // ステージ配置フラグを落とす
                    self.isStaged = NO;
                    
                    // 画面から取り除く
                    [self.image removeFromParentAndCleanup:YES];
                    
                    return;
                }
            }
        }
    }
    
    AKLog(0, @"pattern=%d time=%f interval=%f", pattern, self.animationTime, self.animationInterval);
    
    // アニメーションパターンに応じて画像ファイル名を作成する
    NSString *imageFileName = [NSString stringWithFormat:kAKImageFileFormat, self.imageName, pattern];
    
    // 表示スプライトを変更する
    [self.image setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageFileName]];
    
    // キャラクター固有の動作を行う
    [self action:dt];
}

/*!
 @brief キャラクター固有の動作

 キャラクター種別ごとの動作を行う。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    // 派生クラスで動作を定義する
}

/*!
 @brief 破壊処理

 HPが0になったときの処理
 */
- (void)destroy
{
    // ステージ配置フラグを落とす
    self.isStaged = NO;
    
    // 画面から取り除く
    AKLog(0, @"removeFromParentAndCleanup実行");
    [self.image removeFromParentAndCleanup:YES];
}

/*!
 @brief 衝突判定

 キャラクターが衝突しているか調べ、衝突しているときはHPを減らす。
 @param characters 判定対象のキャラクター群
 */
- (void)checkHit:(const NSEnumerator *)characters
{
    // 画面に配置されていない場合は処理しない
    if (!self.isStaged) {
        return;
    }
    
    // 自キャラの上下左右の端を計算する
    float myleft = self.positionX - self.width / 2.0f;
    float myright = self.positionX + self.width / 2.0f;
    float mytop = self.positionY + self.height / 2.0f;
    float mybottom = self.positionY - self.height / 2.0f;
    
    AKLog(0, @"my=(%f, %f, %f, %f)", myleft, myright, mytop, mybottom);
    
    // 判定対象のキャラクターごとに判定を行う
    for (AKCharacter *target in characters) {
        
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
            
            // 衝突処理を行う
            [self hit:target];
            
            AKLog(0, @"self.hitPoint=%d, target.hitPoint=%d", self.hitPoint, target.hitPoint);
        }
    }
}

/*!
 @brief 衝突処理
 
 衝突した時の処理、自分と相手のHPを減らす。
 @param character 衝突した相手
 */
- (void)hit:(AKCharacter *)character
{    
    // 自分と相手のHPを衝突した相手の攻撃力分減らす
    self.hitPoint -= character.power;
    character.hitPoint -= self.power;
}

/*!
 @brief 画面外配置判定
 
 キャラクターが画面範囲外に配置されているか調べる。
 @return 範囲外に出ている場合はTRUE、範囲内にある場合はFALSE
 */
- (BOOL)isOutOfStage
{
    // 表示範囲外でキャラクターを残す範囲
    const float kAKBorder = 50.0f;
    
    if (self.positionX < -kAKBorder ||
        self.positionX > [AKScreenSize stageSize].width + kAKBorder ||
        self.positionY < -kAKBorder ||
        self.positionY > [AKScreenSize stageSize].height + kAKBorder) {
        
        return TRUE;
    }
    else {
        return FALSE;
    }
}
@end

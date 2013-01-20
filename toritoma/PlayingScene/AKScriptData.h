/*!
 @file AKScriptData.h
 @brief スクリプト1行分のデータ
 
 スクリプト１行分の内容を管理するクラス。
 */

#import <Foundation/Foundation.h>
#import "AKLib.h"

/// スクリプト命令種別
enum AKScriptOpeType {
    kAKScriptOpeEnemy = 0,  ///< 敵の生成
    kAKScriptOpeBoss,       ///< ボスの生成
    kAKScriptOpeBack,       ///< 背景の生成
    kAKScriptOpeWall,       ///< 障害物の生成
    kAKScriptOpeScroll,     ///< スクロールスピード変更
    kAKScriptOpeBGM,        ///< BGM変更
    kAKScriptOpeSleep,      ///< 待機
};

// スクリプト1行分のデータ
@interface AKScriptData : NSObject {
    /// 命令種別
    enum AKScriptOpeType type_;
    /// 命令の値
    NSInteger value_;
    /// 生成位置x座標
    NSInteger positionX_;
    /// 生成位置y座標
    NSInteger positionY_;
}

/// 命令種別
@property (nonatomic, readonly)enum AKScriptOpeType type;
/// 命令の値
@property (nonatomic, readonly)NSInteger value;
/// 生成位置x座標
@property (nonatomic, readonly)NSInteger positionX;
/// 生成位置y座標
@property (nonatomic, readonly)NSInteger positionY;

// 初期化処理
- (id)initWithType:(NSString *)type value:(NSInteger)value x:(NSInteger)x y:(NSInteger)y;
// コンビニエンスコンストラクタ
+ (id)scriptDataWithType:(NSString *)type value:(NSInteger)value x:(NSInteger)x y:(NSInteger)y;

@end

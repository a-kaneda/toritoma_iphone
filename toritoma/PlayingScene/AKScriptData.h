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
}

/// 命令種別
@property (nonatomic, readonly)enum AKScriptOpeType type;
/// 命令の値
@property (nonatomic, readonly)NSInteger value;

// 初期化処理
- (id)initWithType:(NSString *)type value:(NSInteger)value;
// コンビニエンスコンストラクタ
+ (id)scriptDataWithType:(NSString *)type value:(NSInteger)value;

@end

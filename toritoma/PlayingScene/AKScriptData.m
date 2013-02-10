/*!
 @file AKScriptData.m
 @brief スクリプト1行分のデータ
 
 スクリプト１行分の内容を管理するクラス。
 */

#import "AKScriptData.h"

/*!
 @brief スクリプト1行分のデータ
 
 スクリプト１行分の内容を管理するクラス。
 */
@implementation AKScriptData

@synthesize type = type_;
@synthesize value = value_;
@synthesize positionX = positionX_;
@synthesize positionY = positionY_;

/*!
 @brief 初期化処理
 
 初期化処理を行う。
 @param type 命令種別
 @param value 命令の値
 @param x x座標
 @param y y座標
 @return 初期化したインスタンス
 */
- (id)initWithType:(NSString *)type value:(NSInteger)value x:(NSInteger)x y:(NSInteger)y
{
    // スーパークラスの初期化処理を行う
    self = [super init];
    if (!self) {
        AKLog(1, @"error");
        return nil;
    }
    
    // 種別を判別する
    // 敵
    if ([type isEqualToString:@"enemy"]) {
        type_ = kAKScriptOpeEnemy;
    }
    // ボス
    else if ([type isEqualToString:@"boss"]) {
        type_ = kAKScriptOpeBoss;
    }
    // 背景
    else if ([type isEqualToString:@"back"]) {
        type_ = kAKScriptOpeBack;
    }
    // 障害物
    else if ([type isEqualToString:@"block"]) {
        type_ = kAKScriptOpeWall;
    }
    // スクロールスピード変更
    else if ([type isEqualToString:@"speed"]) {
        type_ = kAKScriptOpeScroll;
    }
    // BGM変更
    else if ([type isEqualToString:@"bgm"]) {
        type_ = kAKScriptOpeBGM;
    }
    // 待機
    else if ([type isEqualToString:@"sleep"]) {
        type_ = kAKScriptOpeSleep;
    }
    // エラー
    else {
        NSAssert(0, @"種別が不正:%@", type);
        type_ = kAKScriptOpeSleep;
        value_ = 0;
        return self;
    }
    
    // 値を設定する
    value_ = value;
    
    // x座標、y座標を設定する
    positionX_ = x;
    positionY_ = y;
    
    return self;
}

/*!
 @brief コンビニエンスコンストラクタ
 
 インスタンスの生成、初期化、autoreleaseを行う。
 @param type 命令種別
 @param value 命令の値
 @param x x座標
 @param y y座標
 @return 初期化したインスタンス
 */
+ (id)scriptDataWithType:(NSString *)type value:(NSInteger)value x:(NSInteger)x y:(NSInteger)y
{
    return [[[AKScriptData alloc] initWithType:type value:value x:x y:y] autorelease];
}
@end

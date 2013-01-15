/*!
 @file AKScript.h
 @brief スクリプト読み込みクラス
 
 ステージ構成定義のスクリプトファイルを読み込む。
 */

#import <Foundation/Foundation.h>
#import "AKLib.h"
#import "AKScriptData.h"

// スクリプト読み込みクラス
@interface AKScript : NSObject {
    /// 読み込んだ内容
    NSMutableArray *dataList_;
    /// 実行した行番号
    NSInteger currentLine_;
    /// 待機時間
    float sleepTime_;
}

/// 読み込んだ内容
@property (nonatomic, retain)NSMutableArray *dataList;

// 初期化処理
- (id)initWithStageNo:(NSInteger)stage;
// コンビニエンスコンストラクタ
+ (id)scriptWithStageNo:(NSInteger)stage;
// 更新処理
- (void)update:(float)dt;

@end

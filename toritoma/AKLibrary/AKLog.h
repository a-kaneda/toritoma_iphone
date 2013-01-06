/*!
 @file AKLog.h
 @brief デバッグログ出力マクロ定義
 
 デバッグログを出力するマクロを定義する。
 */

#import <Foundation/Foundation.h>

#ifdef DEBUG

/*!
 @brief デバッグログ
 
 デバッグログ。出力条件の指定が可能。ログの先頭にメソッド名と行数を付加する。
 @param cond 出力条件
 @param fmt 出力フォーマット
 */
#define AKLog(cond, fmt, ...) if (cond) NSLog(@"%s(%d) " fmt, __FUNCTION__, __LINE__, ## __VA_ARGS__)

#else
/*!
 @brief デバッグログ
 
 デバッグログ。出力条件の指定が可能。ログの先頭にメソッド名と行数を付加する。
 @param cond 出力条件
 @param fmt 出力フォーマット
 */
#define AKLog(cond, fmt, ...)

#endif


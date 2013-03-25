// @author Simon Toens 03/16/13

#import <Foundation/Foundation.h>

@protocol ItemPickerDataSource <NSObject>

- (id<ItemPickerDataSource>)getNextDataSource:(NSString *)selection;

@property(nonatomic, strong, readonly) NSString *header;

@property(nonatomic, strong, readonly) NSArray *items;

@property(nonatomic, assign, readonly) BOOL itemsAlreadySorted;

@property(nonatomic, assign, readonly) BOOL sectionsEnabled;

@end
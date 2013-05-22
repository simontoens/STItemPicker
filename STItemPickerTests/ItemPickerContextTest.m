// @author Simon Toens 05/11/13

#import <SenTestingKit/SenTestingKit.h>
#import "ItemPickerContext.h"
#import "SampleCityDataSource.h"

@interface ItemPickerContextTest : SenTestCase
@end

@implementation ItemPickerContextTest

- (void)testEqualityAndHash
{
    SampleCityDataSource *ds = [[SampleCityDataSource alloc] init];
    
    ItemPickerContext *ctx1 = [[ItemPickerContext alloc] initWithDataSource:ds 
                                                              selectedIndex:10 
                                                               selectedItem:@"item1" 
                                                               autoSelected:NO];
    
    ItemPickerContext *ctx2 = [[ItemPickerContext alloc] initWithDataSource:ds 
                                                              selectedIndex:10 
                                                               selectedItem:@"item1"
                                                               autoSelected:NO];
    
    STAssertEqualObjects(ctx1, ctx2, @"bad equality");
    
    ItemPickerContext *ctx3 = [[ItemPickerContext alloc] initWithDataSource:ds 
                                                              selectedIndex:13 
                                                               selectedItem:@"item3" 
                                                               autoSelected:NO];
                               
    NSArray *array = [NSArray arrayWithObjects:ctx1, ctx2, ctx3, nil];
    STAssertTrue([array containsObject:ctx1], @"Where's the ctx?");
    STAssertTrue([array containsObject:ctx2], @"Where's the ctx?");
    STAssertTrue([array containsObject:ctx3], @"Where's the ctx?");
    STAssertFalse([array containsObject:[[ItemPickerContext alloc] initWithDataSource:ds selectedIndex:1 selectedItem:@"1" autoSelected:NO]], @"No way");
    
    STAssertEquals([ctx1 hash], [ctx2 hash], @"bad hash");
}

- (void)testCopy
{
    SampleCityDataSource *ds = [[SampleCityDataSource alloc] init];
    
    ItemPickerContext *ctx = [[ItemPickerContext alloc] initWithDataSource:ds selectedIndex:4 selectedItem:@"a" autoSelected:NO];
    ItemPickerContext *copy = [ctx copy];
    STAssertFalse(ctx == copy, @"Copy, what did you do?");
    STAssertEqualObjects(ctx, copy, @"Bad copy!");
}

@end
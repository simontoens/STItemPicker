// @author Simon Toens 05/11/13

#import <SenTestingKit/SenTestingKit.h>
#import "ItemPickerSelection.h"
#import "SampleCityDataSource.h"

@interface ItemPickerContextTest : SenTestCase
@end

@implementation ItemPickerContextTest

- (void)testEqualityAndHash
{
    SampleCityDataSource *ds = [[SampleCityDataSource alloc] init];
    
    ItemPickerSelection *ctx1 = [[ItemPickerSelection alloc] initWithDataSource:ds 
                                                              selectedIndex:10 
                                                               selectedItem:@"item1" 
                                                               autoSelected:NO
                                                               metaCell:NO];
    
    ItemPickerSelection *ctx2 = [[ItemPickerSelection alloc] initWithDataSource:ds 
                                                              selectedIndex:10 
                                                               selectedItem:@"item1"
                                                               autoSelected:NO
                                                               metaCell:NO];
    
    STAssertEqualObjects(ctx1, ctx2, @"bad equality");
    
    ItemPickerSelection *ctx3 = [[ItemPickerSelection alloc] initWithDataSource:ds 
                                                              selectedIndex:13 
                                                               selectedItem:@"item3" 
                                                               autoSelected:NO
                                                               metaCell:NO];
                               
    NSArray *array = @[ctx1, ctx2, ctx3];
    STAssertTrue([array containsObject:ctx1], @"Where's the ctx?");
    STAssertTrue([array containsObject:ctx2], @"Where's the ctx?");
    STAssertTrue([array containsObject:ctx3], @"Where's the ctx?");
    STAssertFalse([array containsObject:[[ItemPickerSelection alloc] initWithDataSource:ds selectedIndex:1 selectedItem:@"1" autoSelected:NO metaCell:NO]], @"No way");
    
    STAssertEquals([ctx1 hash], [ctx2 hash], @"bad hash");
}

- (void)testCopy
{
    SampleCityDataSource *ds = [[SampleCityDataSource alloc] init];
    
    ItemPickerSelection *ctx = [[ItemPickerSelection alloc] initWithDataSource:ds selectedIndex:4 selectedItem:@"a" 
                                                                  autoSelected:NO metaCell:NO];
    ItemPickerSelection *copy = [ctx copy];
    STAssertFalse(ctx == copy, @"Copy, what did you do?");
    STAssertEqualObjects(ctx, copy, @"Bad copy!");
}

@end

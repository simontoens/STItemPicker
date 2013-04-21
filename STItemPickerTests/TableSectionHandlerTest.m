// @author Simon Toens 03/23/13

#import <SenTestingKit/SenTestingKit.h>
#import "TableSectionHandler.h"

@interface TableSectionHandlerTest : SenTestCase
- (void)runTestItems:(NSArray *)items 
    expectedSections:(NSArray *)expectedSections 
  expectedItemCounts:(int[])expectedItemCounts
  itemsAlreadySorted:(BOOL)itemsAlreadySorted;
@end

@implementation TableSectionHandlerTest

- (void)testBasicSections 
{
    [self runTestItems:[NSArray arrayWithObjects:@"a", @"b", @"c", nil]
      expectedSections:[NSArray arrayWithObjects:@"A", @"B", @"C", nil]
    expectedItemCounts:(int[]){1, 1, 1}
    itemsAlreadySorted:YES];
    
    [self runTestItems:[NSArray arrayWithObjects:@"aa", @"bb", @"cc", nil]
      expectedSections:[NSArray arrayWithObjects:@"A", @"B", @"C", nil]
    expectedItemCounts:(int[]){1, 1, 1}
    itemsAlreadySorted:YES];
    
    [self runTestItems:[NSArray arrayWithObjects:@"aa", @"bb", @"cc", @"ccc", nil]
      expectedSections:[NSArray arrayWithObjects:@"A", @"B", @"C", nil]
    expectedItemCounts:(int[]){1, 1, 2}
    itemsAlreadySorted:YES];
    
    [self runTestItems:[NSArray arrayWithObjects:@"aa", @"AABB", @"AACC", @"cc", @"ccc", @"CCCAABB", nil]
      expectedSections:[NSArray arrayWithObjects:@"A",@"C", nil]
    expectedItemCounts:(int[]){3, 3}
    itemsAlreadySorted:YES];
}

- (void)testNumberSections 
{
    [self runTestItems:[NSArray arrayWithObjects:@"3", @"3003", nil]
      expectedSections:[NSArray arrayWithObjects:kTableSectionHandlerNumberHeader, nil]
    expectedItemCounts:(int[]){2}
    itemsAlreadySorted:YES];
}

- (void)testSymbolSections 
{
    [self runTestItems:[NSArray arrayWithObjects:@"*a", @"!44", @"@444", @"%$#", nil]
      expectedSections:[NSArray arrayWithObject:kTableSectionHandlerSymbolHeader]
    expectedItemCounts:(int[]){4}
    itemsAlreadySorted:YES];    
}

- (void)testAllLetters 
{
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
    STAssertEquals([alphabet length], (NSUInteger)26, @"bad number of letters");
    NSMutableArray *lowerCaseItems = [NSMutableArray arrayWithCapacity:[alphabet length]];
    NSMutableArray *upperCaseItems = [NSMutableArray arrayWithCapacity:[alphabet length]];
    int counts[[alphabet length]];
    for (int i = 0; i < [alphabet length]; i++) 
    {
        NSRange r;
        r.location = i;
        r.length = 1;
        counts[i] = 1;
        NSString *letter = [alphabet substringWithRange:r];
        [lowerCaseItems addObject:[letter lowercaseString]];
        [upperCaseItems addObject:[letter uppercaseString]];
    }

    [self runTestItems:lowerCaseItems expectedSections:upperCaseItems expectedItemCounts:counts itemsAlreadySorted:YES];
    [self runTestItems:upperCaseItems expectedSections:upperCaseItems expectedItemCounts:counts itemsAlreadySorted:YES];
}

- (void)testAllNumbers 
{
    NSString *numbers = @"0123456789";
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[numbers length]];
    for (int i = 0; i < [numbers length]; i++) {
        NSRange r;
        r.location = i;
        r.length = 1;
        [items addObject:[numbers substringWithRange:r]];
    }
    
    [self runTestItems:items 
      expectedSections:[NSArray arrayWithObject:kTableSectionHandlerNumberHeader] 
    expectedItemCounts:(int[]){10} itemsAlreadySorted:YES];
}

- (void)testItemImagesSort 
{
    NSArray *items = [NSArray arrayWithObjects:@"3", @"2", @"1", nil];
    NSArray *images = [NSArray arrayWithObjects:@"aa", @"bb", @"cc", nil];
    TableSectionHandler *handler = [[TableSectionHandler alloc] initWithItems:items alreadySorted:NO];
    handler.sectionsEnabled = NO;
    handler.itemImages = images;

    NSArray *expectedItems = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
    STAssertEqualObjects(handler.items, expectedItems, @"Bad sort order");
    
    NSArray *expectedImages = [NSArray arrayWithObjects:@"cc", @"bb", @"aa", nil];
    STAssertEqualObjects(handler.itemImages, expectedImages, @"Bad sort order");
}

- (void)runTestItems:(NSArray *)items 
    expectedSections:(NSArray *)expectedSections 
  expectedItemCounts:(int[])expectedItemCounts 
  itemsAlreadySorted:(BOOL)itemsAlreadySorted
{
    TableSectionHandler *handler = [[TableSectionHandler alloc] initWithItems:items alreadySorted:itemsAlreadySorted];
    STAssertEqualObjects(handler.sections, expectedSections, @"Unexpected sections");
    
    STAssertEquals([handler.sectionToNumberOfItems count], [handler.sections count], @"Unexpected number of section counts");
    for (int i = 0; i < [handler.sections count]; i++) {
        NSString *section = [handler.sections objectAtIndex:i];
        NSNumber *count = [handler.sectionToNumberOfItems objectForKey:section];
        STAssertNotNil(count, @"No count for section %@", section);
        STAssertEquals([count intValue], expectedItemCounts[i], @"Unexpected item count for section: %@", section);
    }
}

@end
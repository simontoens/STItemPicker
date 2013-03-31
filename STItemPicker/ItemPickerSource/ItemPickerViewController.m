// @author Simon Toens 12/14/12

#import "ItemPickerContext.h"
#import "ItemPickerViewController.h"
#import "Preconditions.h"
#import "TableHeaderViewContainer.h"
#import "TableSectionHandler.h"

@interface ItemPickerViewController()
- (void)configureHeaderView;
- (void)configureTitle;
- (NSInteger)getItemRow:(NSIndexPath *)indexPath;

/**
 * Returns an array of ItemPickerContext instances.
 */
- (NSArray *)getSelections;
- (ItemPickerContext *)getPreviousSelection;

@property(nonatomic, strong) ItemPickerContext *context;
@property(nonatomic, strong) TableSectionHandler *tableSectionHandler;

@end

@implementation ItemPickerViewController

@synthesize context = _context;
@synthesize itemPickerDelegate;
@synthesize tableSectionHandler = _tableSectionHandler;

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource
{
    if (self = [super initWithNibName:@"ItemPickerViewController" bundle:nil]) 
    {
        _tableSectionHandler = [[TableSectionHandler alloc] initWithItems:dataSource.items 
                                                            alreadySorted:dataSource.itemsAlreadySorted];
        _tableSectionHandler.sectionsEnabled = dataSource.sectionsEnabled;
        _context = [[ItemPickerContext alloc] initWithDataSource:dataSource];
        self.title = dataSource.title;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self configureTitle];
    [self configureHeaderView];
}

#pragma mark - UITableView methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    self.context.selectedIndex = [self getItemRow:indexPath];
    self.context.selectedItem = [self.tableSectionHandler.items objectAtIndex:[self getItemRow:indexPath]];
    
    id<ItemPickerDataSource> nextDataSource = [self.context.dataSource getNextDataSourceForSelectedRow:self.context.selectedIndex
                                                                                          selectedItem:self.context.selectedItem];
    if (nextDataSource) 
    {
        ItemPickerViewController *controller = [[ItemPickerViewController alloc] initWithDataSource:nextDataSource];
        controller.itemPickerDelegate = self.itemPickerDelegate;
        [self.navigationController pushViewController:controller animated:YES];
    } 
    else 
    {
        [self.itemPickerDelegate pickedItem:self.context.selectedItem atIndex:self.context.selectedIndex];
    }
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [self.tableSectionHandler.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return [self.tableSectionHandler.sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSString *s = [self.tableSectionHandler.sections objectAtIndex:section];
   return [[self.tableSectionHandler.sectionToNumberOfItems objectForKey:s] intValue];
} 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
        
    int row = [self getItemRow:indexPath];
    cell.textLabel.text = [self.tableSectionHandler.items objectAtIndex:row];
    return cell; 
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    return self.tableSectionHandler.sections;
}

#pragma mark - Private methods

- (NSArray *)getSelections
{
    NSMutableArray *selections = [[NSMutableArray alloc] initWithCapacity:[self.navigationController.viewControllers count]];
    for (ItemPickerViewController *vc in self.navigationController.viewControllers) 
    {
        [selections addObject:vc.context];
    }
    return selections;
}

- (ItemPickerContext *)getPreviousSelection
{
    NSArray *selections = [self getSelections];
    return [selections count] >= 2 ? [selections objectAtIndex:[selections count] - 2] : nil;
}

- (void)configureHeaderView 
{        
    UIImage *headerImage = self.context.dataSource.headerImage;
    if (headerImage) 
    {
        self.tableView.tableHeaderView = [TableHeaderView newTableHeaderView:headerImage];
    }    
}

- (void)configureTitle 
{
    ItemPickerContext *prevSelection = [self getPreviousSelection];
    if (prevSelection)
    {
        self.title = prevSelection.selectedItem;
    }
}

- (NSInteger)getItemRow:(NSIndexPath *)indexPath
{
    NSInteger row = 0;
    for (int i = 0; i < indexPath.section; i++) 
    {
        NSString *s = [self.tableSectionHandler.sections objectAtIndex:i];
        row += [[self.tableSectionHandler.sectionToNumberOfItems objectForKey:s] intValue];
    }
    return row + indexPath.row;
}

@end
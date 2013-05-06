// @author Simon Toens 12/14/12

#import "ItemPickerContext.h"
#import "ItemPickerViewController.h"
#import "Preconditions.h"
#import "Stack.h"
#import "TableHeaderViewContainer.h"
#import "TableSectionHandler.h"
#import "TableViewCell.h"
#import "TableViewCellContainer.h"

@interface ItemPickerViewController()
- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource contextStack:(Stack *)contextStack;
- (id)initWithNibName:(NSString *)nibName dataSource:(id<ItemPickerDataSource>)dataSource contextStack:(Stack *)contextStack;

- (void)configureHeaderView;
- (void)configureNavigationItem;
- (void)configureTitle;

- (UIImage *)getCellImageForRow:(NSUInteger)row;
- (NSInteger)getItemRow:(NSIndexPath *)indexPath;

/**
 * Returns an array of ItemPickerContext instances.
 */
- (ItemPickerContext *)getPreviousContext;

@property(nonatomic, strong) id<ItemPickerDataSource> dataSource;
@property(nonatomic, strong) Stack *contextStack;
@property(nonatomic, strong) TableSectionHandler *tableSectionHandler;

@end

@implementation ItemPickerViewController

UIColor *kGreyBackgroundColor;

@synthesize contextStack = _contextStack;
@synthesize dataSource = _dataSource;
@synthesize itemPickerDelegate;
@synthesize showCancelButton;
@synthesize tableSectionHandler = _tableSectionHandler;


- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource
{
    return [self initWithDataSource:dataSource contextStack:[[Stack alloc] init]];    
}

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource contextStack:(Stack *)contextStack
{
    return [self initWithNibName:@"PlainItemPickerTableView" dataSource:dataSource contextStack:contextStack];
}

- (id)initWithNibName:(NSString *)nibName dataSource:(id<ItemPickerDataSource>)dataSource contextStack:(Stack *)contextStack
{
    if (self = [super initWithNibName:nibName bundle:nil]) 
    {
        _contextStack = contextStack;
        _dataSource = dataSource;
        _tableSectionHandler = [[TableSectionHandler alloc] initWithItems:dataSource.items sections:dataSource.sections];
        _tableSectionHandler.itemsAlreadySorted = dataSource.itemsAlreadySorted;
        _tableSectionHandler.sectionsEnabled = dataSource.sectionsEnabled;
        _tableSectionHandler.itemImages = dataSource.itemImages;

        if (self.tabBarItem) 
        {
            self.title = dataSource.title;
            self.tabBarItem.image = dataSource.tabImage;
        }
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
    [self configureHeaderView];
    [self configureNavigationItem];
    [self configureTitle];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) 
    {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [self.contextStack pop];
    }
    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDelegate methods

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{    
    // hack to get rid of empty rows in table view (also see heightForFooterInSection)
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == [self.tableSectionHandler.sections count] - 1 ? 1 : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    ItemPickerContext *ctx = [[ItemPickerContext alloc] initWithDataSource:self.dataSource];
    ctx.selectedIndex = [self getItemRow:indexPath];
    ctx.selectedItem = [self.tableSectionHandler.items objectAtIndex:[self getItemRow:indexPath]];
    
    [self.contextStack push:ctx];
    
    id<ItemPickerDataSource> nextDataSource = [self.dataSource getNextDataSourceForSelectedRow:ctx.selectedIndex
                                                                                  selectedItem:ctx.selectedItem];
    if (nextDataSource)
    {
        ItemPickerViewController *controller = [[ItemPickerViewController alloc] initWithDataSource:nextDataSource 
                                                                                       contextStack:self.contextStack];
        controller.itemPickerDelegate = self.itemPickerDelegate;
        controller.showCancelButton = self.showCancelButton;
        [self.navigationController pushViewController:controller animated:YES];
    } 
    else
    {
        [self.itemPickerDelegate onPickItem:[self.contextStack allObjects]];
    }
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [self.tableSectionHandler.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return [[self.tableSectionHandler.sections objectAtIndex:section] title];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSRange range = [[self.tableSectionHandler.sections objectAtIndex:section] range];
    return range.length;
} 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    int row = [self getItemRow:indexPath];
    UIImage *cellImage = [self getCellImageForRow:row];
    TableViewCell *cell = nil;
    
    if (cellImage)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:[TableViewCellContainer imageTableViewCellIdentifier]];
        if (cell == nil) 
        {
            cell = [TableViewCellContainer newImageTableViewCell];
        }
        cell.iview.image = [self getCellImageForRow:row];
    }
    else 
    {
        cell = [tableView dequeueReusableCellWithIdentifier:[TableViewCellContainer plainTableViewCellIdentifier]];
        if (cell == nil) 
        {
            cell = [TableViewCellContainer newPlainTableViewCell];
        }        
    }
    
    cell.label.text = [self.tableSectionHandler.items objectAtIndex:row];
    return cell; 
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    return self.tableSectionHandler.sectionTitles;
}

#pragma mark - Private methods

- (UIImage *)getCellImageForRow:(NSUInteger)row
{
    UIImage *cellImage = nil;       
    if (self.tableSectionHandler.itemImages)
    {
        id thing = [self.tableSectionHandler.itemImages objectAtIndex:row];
        if (thing != [NSNull null])
        {
            cellImage = thing;
        }
    }
    return cellImage;
}

- (ItemPickerContext *)getPreviousContext
{
    NSArray *contexts = [self.contextStack allObjects];
    return [contexts count] >= 2 ? [contexts objectAtIndex:[contexts count] - 2] : nil;
}

- (ItemPickerContext *)getContextFrom:(NSArray *)contexts atOffsetFromEnd:(NSUInteger)offset
{
    return [contexts count] > offset ? [contexts objectAtIndex:[contexts count] - 1 - offset] : nil;
}

- (void)configureHeaderView 
{        
    UIImage *headerImage = self.dataSource.headerImage;
    if (headerImage)
    {
        NSArray *contexts = [self.contextStack allObjects];
        NSString *grandfatherSelection = [self getContextFrom:contexts atOffsetFromEnd:1].selectedItem;
        NSString *parentSelection = [self getContextFrom:contexts atOffsetFromEnd:2].selectedItem;
        NSString *numItems = [NSString stringWithFormat:@"%i %@", [self.tableSectionHandler.items count], self.dataSource.title];
        
        self.tableView.tableHeaderView = [TableHeaderViewContainer newTableHeaderView:headerImage label1:grandfatherSelection label2:parentSelection label3:numItems];
    }
}

- (void)configureTitle 
{
    ItemPickerContext *prevSelection = [self getPreviousContext];
    self.title = prevSelection ? prevSelection.selectedItem : self.dataSource.title;
}

- (void)configureNavigationItem
{
    if (self.showCancelButton)
    {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
                                                                         style:UIBarButtonItemStyleBordered 
                                                                        target:self.itemPickerDelegate
                                                                        action:@selector(onCancel)];
        self.navigationItem.rightBarButtonItem = cancelButton;
    }
}

- (NSInteger)getItemRow:(NSIndexPath *)indexPath
{
    NSInteger row = 0;
    for (int i = 0; i < indexPath.section; i++) 
    {
        NSRange range = [[self.tableSectionHandler.sections objectAtIndex:i] range];
        row += range.length;
    }
    return row + indexPath.row;
}

@end
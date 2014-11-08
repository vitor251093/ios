//
//  BusSuggestionsTable.m
//  riobus
//
//  Created by Vitor Marques de Miranda on 02/11/14.
//  Copyright (c) 2014 Rio Bus. All rights reserved.
//

#import "BusSuggestionsTable.h"

#define FAVORITES_SECTION        0
#define RECENTS_SECTION          1

#define RECENT_ITEMS_LIMIT       3

#define NUMBER_OF_ROWS_IN_SCREEN 8

#define CELL_TEXT_INSETS         0.2
#define CELL_LEFT_SPACE          10
#define CELL_TEXT_FONT_SIZE      18

@implementation BusSuggestionsTable

-(void)addToRecentTable:(NSString*)newOne{
    if (![_recents containsObject:newOne] && ![_favorites containsObject:newOne]){
        while ([_recents count]>=RECENT_ITEMS_LIMIT) [_recents removeObjectAtIndex:0];
        [_recents addObject:newOne];
        [[NSUserDefaults standardUserDefaults] setObject:_recents forKey:@"Recents"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self reloadData];
    }
}
-(IBAction)moveFromRecentToFavoriteTable:(UIButton*)sender{
    NSString* newItem = [_recents objectAtIndex:sender.tag];
    [_recents removeObjectAtIndex:sender.tag];
    [[NSUserDefaults standardUserDefaults] setObject:_recents forKey:@"Recents"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (![_favorites containsObject:newItem]){
        [_favorites addObject:newItem];
        [[NSUserDefaults standardUserDefaults] setObject:_favorites forKey:@"Favorites"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self reloadData];
}
-(IBAction)removeFromFavoriteTable:(UIButton*)sender{
    [_favorites removeObjectAtIndex:sender.tag];
    [[NSUserDefaults standardUserDefaults] setObject:_favorites forKey:@"Favorites"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadData];
}

-(UITextField*)generateTextFieldAtFrame:(CGRect)frame{
    UITextField* textField = [[UITextField alloc] initWithFrame:frame];
    textField.textAlignment = NSTextAlignmentLeft;
    textField.textColor = [UIColor blackColor];
    textField.backgroundColor = [UIColor clearColor];
    textField.enabled = NO;
    return textField;
}
-(UIButton*)generateFavoriteButton:(BOOL)favorite forIndex:(NSInteger)index atFrame:(CGRect)frame{
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    button.tag = index;
    if (favorite){
        [button setBackgroundImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(removeFromFavoriteTable:)       forControlEvents:UIControlEventTouchDown];
    }
    else{
        [button setBackgroundImage:[UIImage imageNamed:@"recent"]   forState:UIControlStateNormal];
        [button addTarget:self action:@selector(moveFromRecentToFavoriteTable:) forControlEvents:UIControlEventTouchDown];
    }
    
    return button;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setRowHeight:frame.size.height/NUMBER_OF_ROWS_IN_SCREEN];
    }
    return self;
}
-(void)drawRect:(CGRect)rect{
    self.delegate = self;
    self.dataSource = self;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Favorites"])
        _favorites = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Favorites"] mutableCopy];
    else _favorites = [[NSMutableArray alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Recents"])
        _recents = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Recents"] mutableCopy];
    else _recents = [[NSMutableArray alloc] init];
    
    [self reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == FAVORITES_SECTION) return [_favorites count];
    if (section == RECENTS_SECTION  ) return [_recents count];
    return 0;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
    UITableViewCell* cardCell = [[UITableViewCell alloc] init];
    cardCell.backgroundColor = [UIColor clearColor];
    
    CGFloat leftSpace = CELL_LEFT_SPACE;
    CGFloat sideSpace = self.rowHeight * CELL_TEXT_INSETS;
    CGRect buttonFrame = CGRectMake(leftSpace + sideSpace, sideSpace, self.rowHeight - sideSpace*2, self.rowHeight - sideSpace*2);
    CGRect textFrame =   CGRectMake(buttonFrame.origin.x + buttonFrame.size.width + sideSpace,
                                    sideSpace, self.frame.size.width, self.rowHeight - sideSpace*2);
    
    UITextField* nameText = [self generateTextFieldAtFrame:textFrame];
    nameText.font = [UIFont systemFontOfSize:CELL_TEXT_FONT_SIZE];
    nameText.textAlignment = NSTextAlignmentLeft;
    
    [cardCell addSubview:[self generateFavoriteButton:![indexPath section] forIndex:[indexPath item] atFrame:buttonFrame]];
    
    if ([indexPath section] == FAVORITES_SECTION) nameText.text = _favorites[[indexPath item]];
    if ([indexPath section] == RECENTS_SECTION  ) nameText.text = _recents[[indexPath item]];
    
    [cardCell addSubview:nameText];
    cardCell.textLabel.text = @"";
    cardCell.exclusiveTouch = NO;
    
    return cardCell;
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UISearchBar* searchInput;
    for (UIView* view in [self.superview subviews])
        if ([view isKindOfClass:[UISearchBar class]]) searchInput = (UISearchBar*)view;
    
    if (searchInput){
        if ([indexPath section] == FAVORITES_SECTION) [searchInput setText:_favorites[[indexPath section]]];
        if ([indexPath section] == RECENTS_SECTION  ) [searchInput setText:_recents[[indexPath section]]];
        [searchInput.delegate searchBarSearchButtonClicked:searchInput];
    }
    
    return indexPath;
}

@end

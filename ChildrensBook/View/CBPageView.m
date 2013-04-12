//
//  CBPageView.m
//  ChildrensBook
//
//  Created by Alex Silva on 4/4/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CBPageView.h"

@interface CBPageView()

@property (strong, nonatomic) NSMutableAttributedString *currentDisplayString;
@property (strong, nonatomic) NSMutableAttributedString *finalString;

@property (strong, nonatomic) NSMutableArray *timers;

@property (strong, nonatomic) NSArray *timeCodes;

@property (strong, nonatomic) NSMutableArray *attrStringArray;

@property NSUInteger index;

@end

@implementation CBPageView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CBPageView *CBview = [[[NSBundle mainBundle] loadNibNamed:@"CBPageView" owner:self options:nil] objectAtIndex:0];
        CBview.textView.layer.borderWidth = 5.0f;
        CBview.textView.layer.borderColor = [[UIColor magentaColor] CGColor];
        self = CBview;
        
        //TODO: add real timecodes!
        _timeCodes = @[@1.0, @3.0, @5.0, @6.0];
        _timers = [NSMutableArray array];
        
        _attrStringArray = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (IBAction)buttonPressed:(id)sender {
    
    NSLog(@"Button pressed");
    
    //ATTRIBUTES
    NSDictionary * normalAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    
    //RESET ELEMENTS
    //if user presses "read to me!" button while being read to, we need to cancel out the current timers.
    for(NSTimer *timer in self.timers) [timer invalidate];
    [self.timers removeAllObjects];
    
    //unhighlight text
    self.textView.attributedText = self.defaultString;
    
    //remove elements from attrString array
    [self.attrStringArray removeAllObjects];
    
    //print all elements in array
    for(NSMutableAttributedString *mstr in self.attrStringArray){
        NSLog(@"Array elements %@", mstr.mutableString);
    }
    
    //index counter for timeCode array
    self.index = 0;
    
    //play audio
    [self playSound];
    
    for(NSString *word in self.wordArray){
        
        NSMutableAttributedString *currentHighlightedWord = [[NSMutableAttributedString alloc] initWithString: self.wordArray[_index] attributes:normalAttributes];
        
            NSLog(@"Current highlighted word: %@", currentHighlightedWord.mutableString);
        
        NSArray *before;

        NSArray *after;
    
        //CASE: First word
        if (_index == 0) {
            after = [NSArray arrayWithArray: [self.wordArray subarrayWithRange: NSMakeRange(_index+1, self.wordArray.count-(_index+1))]];
            NSMutableAttributedString * tempAfter = [[NSMutableAttributedString alloc] initWithString:[after componentsJoinedByString:@" "] attributes:normalAttributes];
            
            //add space to the end of word
            [currentHighlightedWord replaceCharactersInRange:NSMakeRange(currentHighlightedWord.mutableString.length, 0) withString:@" "];
            //NSLog(@"testing added a character: %@", currentHighlightedWord.mutableString);
            
            [currentHighlightedWord addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(0, currentHighlightedWord.mutableString.length-1)];
            
            [currentHighlightedWord appendAttributedString:tempAfter];
            [self.attrStringArray addObject:currentHighlightedWord];
            NSLog(@"First index %@", currentHighlightedWord);
        }
        
        //CASE: Last word
        else if(_index == self.wordArray.count-1){
            before = [NSArray arrayWithArray: [self.wordArray subarrayWithRange: NSMakeRange(0, _index)]];
            NSMutableAttributedString * tempBefore = [[NSMutableAttributedString alloc] initWithString:[before componentsJoinedByString:@" "] attributes:normalAttributes];
            
            [tempBefore replaceCharactersInRange:NSMakeRange(tempBefore.mutableString.length, 0) withString:@" "];
            
            [currentHighlightedWord addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(0, currentHighlightedWord.mutableString.length)];
            
            [tempBefore appendAttributedString:currentHighlightedWord];
            [self.attrStringArray addObject:tempBefore];
                        NSLog(@"Last index %@", tempBefore);
        }
        
        
        else{
            
            before = [NSArray arrayWithArray: [self.wordArray subarrayWithRange: NSMakeRange(0, _index)]];
            
            NSMutableAttributedString * tempBefore = [[NSMutableAttributedString alloc] initWithString:[before componentsJoinedByString:@" "] attributes:normalAttributes];
            
            //NSLog(@"tempBefore for mid index: %@", tempBefore);
            
            after = [NSArray arrayWithArray: [self.wordArray subarrayWithRange: NSMakeRange(_index+1, (self.wordArray.count-1)-_index )]];
            NSMutableAttributedString * tempAfter = [[NSMutableAttributedString alloc] initWithString:[after componentsJoinedByString:@" "] attributes:normalAttributes];
            
            //NSLog(@"tempAfter for mid index: %@", tempAfter);
            
            [tempBefore replaceCharactersInRange:NSMakeRange(tempBefore.mutableString.length, 0) withString:@" "];
            [currentHighlightedWord replaceCharactersInRange:NSMakeRange(currentHighlightedWord.mutableString.length, 0) withString:@" "];
            
            [currentHighlightedWord addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(0, currentHighlightedWord.mutableString.length-1)];
            
            [tempBefore appendAttributedString:currentHighlightedWord];
            [tempBefore appendAttributedString:tempAfter];
            
            
            [self.attrStringArray addObject:tempBefore];
                        NSLog(@"%@", tempBefore);
        }

        
        NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval: [self.timeCodes[_index] doubleValue] target:self selector:@selector(updateTextField:) userInfo: @(_index) repeats: NO];
        
        //add timer to timer array
        [self.timers addObject:aTimer];
        
        [[NSRunLoop mainRunLoop] addTimer: aTimer forMode:NSRunLoopCommonModes];
        
    
    
//            //change color of word
//            NSAttributedString * subString = [[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@ ", word] attributes:highlightedAttributes];
//            
//            //append new attributed subString to our building final highlighted text
//            [self.finalString appendAttributedString:subString];
//        
//            NSMutableArray *remainingWords;
//            if (_index < self.wordArray.count-1)
//                remainingWords = [NSMutableArray arrayWithArray: [self.wordArray subarrayWithRange:NSMakeRange(_index, self.wordArray.count-_index)] ];
//            
//            //if there are remaining words
//            if (remainingWords) {
//                
//                //couldn't figure out how to use NSMakeRange to just pick up one element
//                [remainingWords removeObjectAtIndex:0];
//                
//                NSLog(@"Remaining words: %@", remainingWords);
//                
//                NSMutableAttributedString * postString = [[NSMutableAttributedString alloc] initWithString:[remainingWords componentsJoinedByString:@" "] attributes:normalAttributes];
//                
//                self.currentDisplayString = [[NSMutableAttributedString alloc] initWithAttributedString:self.finalString];
//                
//                [self.currentDisplayString appendAttributedString:postString];
//                
//                [self.attributedStrings addObject:self.currentDisplayString];
//                
//                NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval: [self.timeCodes[_index] floatValue] target:self selector:@selector(updateTextField:) userInfo: @(_index) repeats: NO];
//                
//                //add timer to timer array
//                [self.timers addObject:aTimer];
//                
//                [[NSRunLoop mainRunLoop] addTimer: aTimer forMode:NSRunLoopCommonModes];
//                
//            }
//            else{
//                
//                [self.attributedStrings addObject:self.finalString];
//                
//                NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval: [self.timeCodes[_index] doubleValue] target:self selector:@selector(updateTextField:) userInfo:@(_index) repeats: NO];
//                
//                //add timer to timer array
//                [self.timers addObject:aTimer];
//                
//                [[NSRunLoop mainRunLoop] addTimer: aTimer forMode:NSRunLoopCommonModes];
//                
//            }
        
        NSLog(@"timecode: %f", [self.timeCodes[_index] doubleValue]);
        NSLog(@"at index: %d", _index);
        _index++;
        
    }
    
    //reset to default, non-highlighted text
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval: [self.timeCodes[_index] doubleValue] target:self selector:@selector(resetTextField:) userInfo: @(_index) repeats: NO];

    //add last timer to timer array
    [self.timers addObject:aTimer];

    [[NSRunLoop mainRunLoop] addTimer: aTimer forMode:NSRunLoopCommonModes];
}

-(void)updateTextField:(NSTimer*)theTimer
{
    
    NSUInteger localIndex = [theTimer.userInfo intValue];
    
    self.textView.attributedText = self.attrStringArray[localIndex];

    [self setNeedsDisplay];
    
}

-(void)resetTextField:(NSTimer*)theTimer
{
    
    self.textView.attributedText = self.defaultString;
    
    [self setNeedsDisplay];
    
}

#pragma Sound methods

-(void)loadSound
{
    NSString *audioPath = [[NSBundle mainBundle]
                            pathForResource:_audioTextPath ofType:@"aiff"];
    NSURL *audioURL = [NSURL fileURLWithPath:audioPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)
                                     audioURL, &_soundID);
}

-(void)unloadSound
{
    AudioServicesDisposeSystemSoundID(_soundID);
    NSLog(@"Disposing sound");
}

-(void)playSound
{
    AudioServicesPlaySystemSound(_soundID);
}
@end
//
//  MKResponseAnnotationView.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/8/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "MKResponseAnnotationView.h"

@implementation MKResponseAnnotationView

- (void)reloadAnnotationView {
    [self drawStudentResponseSymbolForAnnotation:self.annotation];
}

- (void)drawStudentResponseSymbolForAnnotation:(MKStudentResponseAnnotation *)annotation {
    if (annotation.responseRecord)
        self.image=[UIImage imageNamed:@"response.jpeg"];
}

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithAnnotation:self.annotation reuseIdentifier:reuseIdentifier])
        [self drawStudentResponseSymbolForAnnotation:annotation];
    
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    
    [self drawStudentResponseSymbolForAnnotation:annotation];
}

@end

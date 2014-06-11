//
//  BKPLegoView.m
//  Lego Viewer
//
//  Created by Anson Jablinski on 6/9/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPLegoView.h"

#import "BKPPlacedBrick.h"

@implementation BKPLegoView {
	NSSet *bricksToDisplay;
	CGContextRef context;
}

#pragma mark - Main functions

@synthesize drawAxes = _drawAxes;
@synthesize drawBaseplate = _drawBaseplate;
@synthesize baseplateColor, baseplateSize;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		bricksToDisplay = nil;
		context = nil;
		_drawAxes = NO;
		_drawBaseplate = NO;
		baseplateColor = BKPBrickColorGreen;
		baseplateSize = 32;
	}
	
	return self;
}

- (void)setDrawAxes:(BOOL)drawAxes {
	_drawAxes = drawAxes;
	[self setNeedsDisplay];
}

- (void)setDrawBaseplate:(BOOL)drawBaseplate {
	_drawBaseplate = drawBaseplate;
	[self setNeedsDisplay];
}

- (void)setBaseplateColor:(BKPBrickColor)newColor andSize:(int)newSize {
	baseplateColor = newColor;
	baseplateSize = newSize;
	[self setNeedsDisplay];
}

- (void)displayBricks:(NSSet *)bricks {
	bricksToDisplay = bricks;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	// Save current context into instance variable for easy access
	context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	// Center the origin of the drawing context
	CGContextTranslateCTM(context, rect.size.width / 2.0, rect.size.height / 2.0);

	// Attempt to draw the content as large as possible.
	// tryToDrawInRect will return true if all the calls to drawPlacedBrick return true.
	// If any drawPlacedBrick returns false, then something is out of bounds,
	//		and we'll shrink everything a bit
	CGContextScaleCTM(context, 3, 3);
	while (![self tryToDrawInRect:rect]) {
		CGContextScaleCTM(context, 0.8, 0.8);
	}
	
	CGContextRestoreGState(context);
}


#pragma mark - All methods below this should be invoked via drawRect ONLY

- (BOOL)tryToDrawInRect:(CGRect)rect {
	// Erase any previous drawing attempts
	[[UIColor whiteColor] setFill];
	CGContextFillRect(context, CGRectInfinite);
	
	if (_drawBaseplate && ![self drawTheBaseplate])
		return NO;
	
	// We don't care if the axes go out of bounds.
	if (_drawAxes)
		[self drawTheAxes];
	
	// If there are no bricks to display, we're done
	if (!bricksToDisplay || [bricksToDisplay count] == 0)
		return YES;
	
	// Put the bricks into drawing order:
	//		lowest z coordinate is first; if z==z then highest sum of x and y is first
	NSMutableArray *drawingOrder = [NSMutableArray arrayWithCapacity:[bricksToDisplay count]];
	for (BKPPlacedBrick *brick in bricksToDisplay) {
		[drawingOrder addObject:brick];
	}
	[drawingOrder sortUsingComparator:^NSComparisonResult(BKPPlacedBrick *obj1, BKPPlacedBrick *obj2) {
		if (obj1.z < obj2.z)
			return NSOrderedAscending;
		else if (obj1.z > obj2.z)
			return NSOrderedDescending;
		else if ((obj1.x + obj1.y) < (obj2.x + obj2.y))
			return NSOrderedDescending;
		else if ((obj1.x + obj1.y) > (obj2.x + obj2.y))
			return NSOrderedAscending;
		else
			return NSOrderedSame;
	}];
	
	// Draw the placed bricks one at a time
	for (BKPPlacedBrick *brick in drawingOrder) {
		// If any one brick fails, this whole method fails
		if (![self drawPlacedBrick:brick])
			return NO;
	}
	
	return YES;
}

- (BOOL)drawPlacedBrick:(BKPPlacedBrick *)brick {
	if (brick.brick.color == BKPBrickColorBlack)
		[[UIColor grayColor] setStroke];
	else
		[[UIColor blackColor] setStroke];
	
	[[BKPBrickColorOptions colorForColor:brick.brick.color] setFill];
	
	// By default, the long side of a brick is the xLength in our PlacedBrick coordinate system.
	// If the brick is rotated, we want to swap the short and long side lengths.
	int xLength = (brick.isRotated?brick.brick.shortSideLength:brick.brick.longSideLength);
	int yLength = (brick.isRotated?brick.brick.longSideLength:brick.brick.shortSideLength);
	int height = brick.brick.height;
	// These x, y, z are the coordinates of the "center" of the brick,
	//		defined as the center of the bottom plane of the brick.
	float x = brick.x;
	float y = brick.y;
	float z = brick.z;
	// This is some preliminary math that we'll use when calculating the vertex points.
	// The vertices share some coordinate values; no sense doing the calculations multiple times.
	float xOfRightAndBack = x + xLength / 2.0;
	float xOfLeftAndFront = x - xLength / 2.0;
	float yOfRightAndFront = y - yLength / 2.0;
	float yOfLeftAndBack = y + yLength / 2.0;
	float zOfTop = z + height;
	float zOfBottom = z;

	// These are the points corresponding to the visible vertices of the brick.
	CGPoint topFront = [self	pointFrom3Dx:xOfLeftAndFront y:yOfRightAndFront andZ:zOfTop];
	CGPoint topLeft = [self		pointFrom3Dx:xOfLeftAndFront y:yOfLeftAndBack	andZ:zOfTop];
	CGPoint topBack = [self		pointFrom3Dx:xOfRightAndBack y:yOfLeftAndBack	andZ:zOfTop];
	CGPoint topRight = [self	pointFrom3Dx:xOfRightAndBack y:yOfRightAndFront andZ:zOfTop];
	CGPoint bottomRight = [self	pointFrom3Dx:xOfRightAndBack y:yOfRightAndFront andZ:zOfBottom];
	CGPoint bottomFront = [self	pointFrom3Dx:xOfLeftAndFront y:yOfRightAndFront andZ:zOfBottom];
	CGPoint bottomLeft = [self	pointFrom3Dx:xOfLeftAndFront y:yOfLeftAndBack	andZ:zOfBottom];
	// These points represent the bounding box.
	CGPoint boundingBottomLeft = CGPointMake(bottomLeft.x, bottomFront.y);
	CGPoint boundingTopRight = CGPointMake(topRight.x, topBack.y);
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	// Draw outline first
	[path moveToPoint:topLeft];
	[path addLineToPoint:topBack];
	[path addLineToPoint:topRight];
	[path addLineToPoint:bottomRight];
	[path addLineToPoint:bottomFront];
	[path addLineToPoint:bottomLeft];
	[path closePath];
	[path stroke];
	[path fill];
	// Draw inner 3 lines
	[path setLineWidth:0.5];
	[path removeAllPoints];
	[path moveToPoint:topLeft];
	[path addLineToPoint:topFront];
	[path addLineToPoint:bottomFront];
	[path moveToPoint:topRight];
	[path addLineToPoint:topFront];
	[path closePath];
	[path stroke];
	
	// Studs
	for (int xStud = 0; xStud < xLength; xStud++) {
		for (int yStud = 0; yStud < yLength; yStud++) {
			// Currently drawing studs as ovals inside rectangle with corners at center of brick top edges
			CGRect studRect;
			
			CGPoint offsetForOrigin = [self pointFrom3Dx:xStud y:0.5+yStud andZ:0];
			studRect.origin = CGPointMake(topFront.x + offsetForOrigin.x, topFront.y + offsetForOrigin.y);

			CGPoint offsetForSize = [self pointFrom3Dx:1 y:0 andZ:0];
			studRect.size = CGSizeMake(offsetForSize.x, offsetForSize.y);

			[[UIBezierPath bezierPathWithOvalInRect:studRect] stroke];
		}
	}
	
	
	BOOL (^pointIsOutOfBounds)(CGPoint) = ^BOOL(CGPoint point) {
		return !CGRectContainsPoint(self.bounds, CGContextConvertPointToDeviceSpace(context, point));
	};
	
	if (pointIsOutOfBounds(boundingBottomLeft) || pointIsOutOfBounds(boundingTopRight)) {
		return NO;
	}
		
	return YES;
}

- (BOOL)drawTheBaseplate {
	// The baseplate is just a big brick with zero height.
	BKPPlacedBrick *baseplate = [[BKPPlacedBrick alloc] init];
	baseplate.brick = [BKPBrick brickWithColor:baseplateColor shortSide:baseplateSize longSide:baseplateSize andHeight:0];
	[baseplate setX:0 Y:0 andZ:0];
	return [self drawPlacedBrick:baseplate];
}

- (void)drawTheAxes {
	// We don't care if these go out of bounds, so no worries.
	UIBezierPath *path = [UIBezierPath bezierPath];
	
	[path moveToPoint:CGPointMake(0, 0)];
	[path addLineToPoint:[self pointFrom3Dx:10 y:0 andZ:0]];
	
	[path moveToPoint:CGPointMake(0, 0)];
	[path addLineToPoint:[self pointFrom3Dx:0 y:10 andZ:0]];
	
	[path moveToPoint:CGPointMake(0, 0)];
	[path addLineToPoint:[self pointFrom3Dx:0 y:0 andZ:10]];
	
	[path closePath];
	
	[[UIColor grayColor] setStroke];
	[path stroke];
}

#pragma mark - 3D to 2D helper

- (CGPoint)pointFrom3Dx:(float)x y:(float)y andZ:(float)z {
	float newX = 0;
	float newY = 0;
	
	// Input x
	newX += x * 24;
	newY += x * 9;
	// Input y
	newX += y * -13;
	newY += y * 15;
	// Input z
	newY += z * 34;
	
	// Flip y
	newY *= -1;
	
	return CGPointMake(newX, newY);
}

@end

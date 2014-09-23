//
//  BKPLegoView.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/9/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPLegoView.h"
#import "BKPPlacedBrick.h"

@implementation BKPLegoView {
	NSSet *_bricksToDisplay;
	CGContextRef _context;
}

#pragma mark - Main functions

@synthesize drawAxes = _drawAxes;
@synthesize drawBaseplate = _drawBaseplate;
@synthesize baseplateColor, baseplateSize;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		_bricksToDisplay = nil;
		_context = nil;
		_drawAxes = NO;
		_drawBaseplate = NO;
		baseplateColor = BKPBrickColorGreen;
		baseplateSize = 32;
		
		[self setOpaque:NO];
		[self setBackgroundColor:[UIColor whiteColor]];
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
	// We need to go through the set. If they're PlacedBricks, just add them.
	// If they're only Bricks, then we can wrap them in a dummy PlacedBrick.
	// If they're not a brick, then don't try to draw it.
	NSMutableSet *placedBricksReadyForDisplay = [NSMutableSet set];
	
	for (id brickObject in bricks) {
		if ([brickObject isMemberOfClass:[BKPPlacedBrick class]]) {
			[placedBricksReadyForDisplay addObject:brickObject];
		} else if ([brickObject isMemberOfClass:[BKPBrick class]]) {
			BKPPlacedBrick *newPlacedBrick = [[BKPPlacedBrick alloc] init];
			[newPlacedBrick setBrick:brickObject];
			[newPlacedBrick setX:0 Y:0 andZ:0];
			[newPlacedBrick setIsRotated:NO];
			
			[placedBricksReadyForDisplay addObject:newPlacedBrick];
		}
	}
		
	_bricksToDisplay = [NSSet setWithSet:placedBricksReadyForDisplay];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	// Save current context into instance variable for easy access.
	_context = UIGraphicsGetCurrentContext();

	// Scale the context once, based on the size of the things you're trying to draw in it.
	{
		// Find the largest 3D bounding box for all the bricks.
		float minX = FLT_MAX, minY = FLT_MAX, maxX = FLT_MIN, maxY = FLT_MIN;
		for (BKPPlacedBrick *brick in _bricksToDisplay) {
			int xLength = (brick.isRotated?brick.brick.shortSideLength:brick.brick.longSideLength);
			int yLength = (brick.isRotated?brick.brick.longSideLength:brick.brick.shortSideLength);
			int height = brick.brick.height;
			float x = brick.x;
			float y = brick.y;
			float z = brick.z;
			
			float brickMinX = [self pointFrom3Dx:(x - xLength / 2.0) y:(y + yLength / 2.0) andZ:(z)].x;
			float brickMaxX = [self pointFrom3Dx:(x + xLength / 2.0) y:(y - yLength / 2.0) andZ:(z)].x;
			
			// Y coordinates grow from the top of the screen, not the bottom or center...
			// This is a bit of voodoo going on right here.
			float brickMinY = [self pointFrom3Dx:(x + xLength / 2.0) y:(y + yLength / 2.0) andZ:(z + height)].y;
			float brickMaxY = [self pointFrom3Dx:(x - xLength / 2.0) y:(y - yLength / 2.0) andZ:(z)].y;
			
			minX = MIN(minX, brickMinX);
			minY = MIN(minY, brickMinY);
			maxX = MAX(maxX, brickMaxX);
			maxY = MAX(maxY, brickMaxY);
		}

		// Compare with the visible self.bounds to determine the best scale factor.
		float desiredFillPercentage = 0.95;
		
		float scaleFromMinX = desiredFillPercentage * self.bounds.size.width / (2.0 * ABS(minX));
		float scaleFromMinY = desiredFillPercentage * self.bounds.size.height / (2.0 * ABS(minY));
		float scaleFromMaxX = desiredFillPercentage * self.bounds.size.width / (2.0 * ABS(maxX));
		float scaleFromMaxY = desiredFillPercentage * self.bounds.size.height / (2.0 * ABS(maxY));
		
		float finalScale = MIN(MIN(scaleFromMinX, scaleFromMinY), MIN(scaleFromMaxX, scaleFromMaxY));
		
		// Center the origin.
		CGContextTranslateCTM(_context, self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
		// Scale by the determined factor.
		CGContextScaleCTM(_context, finalScale, finalScale);
	}

	// Draw baseplate and axes, if requested.
	if (_drawBaseplate)
		[self drawTheBaseplate];
	
	if (_drawAxes)
		[self drawTheAxes];
	
	// Got any bricks to draw?
	if (!_bricksToDisplay || [_bricksToDisplay count] == 0)
		return;
	
	
	// Draw all the bricks in bricksToDisplay.
	
	// First, put them into drawing order.
		// Lowest z coordinate is first; if z == z then highest sum of x and y is first (b/c it's furthest).
	NSMutableArray *drawingOrder = [NSMutableArray arrayWithCapacity:[_bricksToDisplay count]];
	for (BKPPlacedBrick *brick in _bricksToDisplay) {
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
	
	// Draw bricks one at a time.
	for (BKPPlacedBrick *brick in drawingOrder) {
		[self drawPlacedBrick:brick];
	}
}


#pragma mark - Drawing helpers

- (void)drawPlacedBrick:(BKPPlacedBrick *)brick {
	UIColor *brickLineColor, *brickColor;
	if (brick.brick.color == BKPBrickColorBlack)
		brickLineColor = [UIColor grayColor];
	else
		brickLineColor = [UIColor blackColor];
	
	brickColor = [BKPBrickColorOptions colorForColor:brick.brick.color];
	
	[brickLineColor setStroke];
	[brickColor setFill];
	
	// By default, the long side of a brick is the xLength in our PlacedBrick coordinate system.
	// If the brick is rotated, we want to swap the short and long side lengths.
	int xLength = (brick.isRotated?brick.brick.shortSideLength:brick.brick.longSideLength);
	int yLength = (brick.isRotated?brick.brick.longSideLength:brick.brick.shortSideLength);
	int height = brick.brick.height;
	// These x, y, z are the coordinates of the "center" of the brick,
	//	defined as the center of the bottom plane of the brick.
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
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	// Draw the outline first.
	[path moveToPoint:topLeft];
	[path addLineToPoint:topBack];
	[path addLineToPoint:topRight];
	[path addLineToPoint:bottomRight];
	[path addLineToPoint:bottomFront];
	[path addLineToPoint:bottomLeft];
	[path closePath];
	[path stroke];
	[path fill];
	// Draw inner 3 lines.
	[path setLineWidth:0.5];
	[path removeAllPoints];
	[path moveToPoint:topLeft];
	[path addLineToPoint:topFront];
	[path addLineToPoint:bottomFront];
	[path moveToPoint:topRight];
	[path addLineToPoint:topFront];
	[path closePath];
	[path stroke];
	
	// Draw the studs on top of the brick.
	for (int xStud = 0; xStud < xLength; xStud++) {
		for (int yStud = 0; yStud < yLength; yStud++) {
			CGRect studRect = CGRectZero;
			
			double studSpacing = 1.5/7.8;
			double studDiameter = 4.8/7.8;
			
			CGPoint studOriginOffset = [self pointFrom3Dx:(xStud + 2.0*studSpacing) y:(yStud + 1 - studSpacing) andZ:0];
			studRect.origin = CGPointMake(topFront.x + studOriginOffset.x, topFront.y + studOriginOffset.y);
			
			CGPoint studSize = [self pointFrom3Dx:studDiameter y:studDiameter andZ:0];
			studRect.size = CGSizeMake(-studSize.y, studSize.x);
						
			[brickLineColor setFill];

			[[UIBezierPath bezierPathWithOvalInRect:studRect] stroke];
			[[UIBezierPath bezierPathWithOvalInRect:studRect] fill];
			
			studRect.origin.y -= studRect.size.height / 2.0;
			[[UIBezierPath bezierPathWithRect:studRect] stroke];
			[[UIBezierPath bezierPathWithRect:studRect] fill];
			
			[brickColor setFill];
			
			studRect.origin.y -= studRect.size.height / 2.0;
			[[UIBezierPath bezierPathWithOvalInRect:studRect] stroke];
			[[UIBezierPath bezierPathWithOvalInRect:studRect] fill];
		}
	}
}

- (void)drawTheBaseplate {
	// The baseplate is just a big brick with zero height.
	BKPPlacedBrick *baseplate = [[BKPPlacedBrick alloc] init];
	baseplate.brick = [BKPBrick brickWithColor:baseplateColor shortSide:baseplateSize longSide:baseplateSize andHeight:0];
	[baseplate setX:0 Y:0 andZ:0];
	[self drawPlacedBrick:baseplate];
}

- (void)drawTheAxes {
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
	
	// These adjustments are based on measurements I made of a real sheet of Lego instructions.
	// Each stud in the x, y, and z directions in the 3D model space correspond to
	//	x and y distances in the plane of the paper.
	// This is a decent, but imprecise way to transform 3D coordinates to 2D.
	newX += x * 24;
	newY += x * 9;

	newX += y * -13;
	newY += y * 15;

	newY += z * 34.0 / 3; // 3 = full height brick, 1 = plate.
	
	// Flip y.
	newY *= -1;
	
	return CGPointMake(newX, newY);
}

@end

//
//  BKPBrickSizeGuesser.m
//  Brickspace
//
//  Created by Anson Jablinski on 8/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//	The silliest spaghetti class you ever did see.
//

#import "BKPBrickSizeGuesser.h"

@implementation BKPBrickSizeGuesser

+ (int)brickLongSideLengthIfShortSideIs2AndDepthFrameContainsThisManyPixels:(int)pixelCount {
	int score2x1, score2x2, score2x3, score2x4;
	score2x1 = ABS(pixelCount - dfPix_avg2x1);
	score2x2 = ABS(pixelCount - dfPix_avg2x2);
	score2x3 = ABS(pixelCount - dfPix_avg2x3);
	score2x4 = ABS(pixelCount - dfPix_avg2x4);
	
	int bestScore = MIN(MIN(score2x1, score2x2), MIN(score2x3, score2x4));
	
	if (bestScore == score2x1)
		return 1;
	else if (bestScore == score2x2)
		return 2;
	else if (bestScore == score2x3)
		return 3;
	else // 2x4 will be the default case
		return 4;
}

+ (int)brickLongSideLengthIfShortSideIs2AndVolumeIs:(float)volume {
	double score2x1, score2x2, score2x3, score2x4;
	score2x1 = ABS(volume - vol_avg2x1);
	score2x2 = ABS(volume - vol_avg2x2);
	score2x3 = ABS(volume - vol_avg2x3);
	score2x4 = ABS(volume - vol_avg2x4);
	
	double bestScore = MIN(MIN(score2x1, score2x2), MIN(score2x3, score2x4));
	
	if (bestScore == score2x1)
		return 1;
	else if (bestScore == score2x2)
		return 2;
	else if (bestScore == score2x3)
		return 3;
	else // 2x4 will be the default case
		return 4;
}

#pragma mark - Generic helpers

+ (void)load {
	vol_avg2x1 = [self averageOfNSNumbersInArray:[self vol_data2x1]];
	vol_avg2x2 = [self averageOfNSNumbersInArray:[self vol_data2x2]];
	vol_avg2x3 = [self averageOfNSNumbersInArray:[self vol_data2x3]];
	vol_avg2x4 = [self averageOfNSNumbersInArray:[self vol_data2x4]];
	
	//	NSLog(@"Volume:\t2x1 %.0f\t2x2 %.0f\t2x3 %.0f\t2x4 %.0f", vol_avg2x1, vol_avg2x2, vol_avg2x3, vol_avg2x4);
	
	dfPix_avg2x1 = [self averageOfNSNumbersInArray:[self dfPix_data2x1]];
	dfPix_avg2x2 = [self averageOfNSNumbersInArray:[self dfPix_data2x2]];
	dfPix_avg2x3 = [self averageOfNSNumbersInArray:[self dfPix_data2x3]];
	dfPix_avg2x4 = [self averageOfNSNumbersInArray:[self dfPix_data2x4]];
	
//	NSLog(@"Depth:\t2x1 %.0f\t2x2 %.0f\t2x3 %.0f\t2x4 %.0f", dfPix_avg2x1, dfPix_avg2x2, dfPix_avg2x3, dfPix_avg2x4);
}

+ (double)averageOfNSNumbersInArray:(NSArray *)array {
	double result = 0;
	unsigned long count = [array count];
	
	for (id object in array) {
		if ([object isKindOfClass:[NSNumber class]]) {
			result += [object doubleValue];
		} else {
			count--;
		}
	}
	
	return result / count;
}

#pragma mark - Depth frame pixel count method

static BOOL useOldDepthData = NO;

static double dfPix_avg2x1;
static double dfPix_avg2x2;
static double dfPix_avg2x3;
static double dfPix_avg2x4;

+ (NSArray *)dfPix_data2x1 {
	if (useOldDepthData)
		return @[@223, @243, @284, @298, @284];
	else
		return @[@38, @42, @117, @160, @169, @201, @216, @220, @223, @226, @227, @228, @230, @230, @235, @244, @245, @247, @248, @249, @251, @257, @258, @259, @260, @264, @267, @269, @272, @274, @278, @280, @282, @283, @284, @285, @285, @299, @300, @302, @302, @304, @309, @313, @319, @323, @332, @336, @340, @559, @643, @1219, @1337, @1382, @1386, @1512, @1584, @1643, @1946, @2042, @2099, @2103, @2476, @2507, @2510, @2633, @2808, @2828, @2842, @2868, @2948, @2961, @2989, @3014, @3027, @3045, @3056, @3072, @3077, @3088, @3139, @3173, @3182, @3275, @3290, @3365, @3395, @3410, @3443, @3502, @3503, @3512, @3542, @3562, @3562, @3566, @3569, @3587, @3609, @3680, @3738, @3743, @3763, @3782, @3785, @3839, @3904, @3907, @3967, @3983, @3996, @3999, @4023, @4034, @4052, @4058, @4135, @4288, @4308, @4353, @4359, @4364, @4415, @4477, @4481, @4514, @4555, @4556, @4721, @4796, @4864, @4868, @4919, @4956, @4973, @5014, @5072, @5118, @5180, @5257, @5397, @5661, @5662, @5829, @5868, @5956, @6329, @6330];
}

+ (NSArray *)dfPix_data2x2 {
	if (useOldDepthData)
		return @[@338, @305, @467, @420];
	else
		return @[@262, @271, @288, @301, @307, @313, @318, @322, @326, @338, @345, @346, @353, @372, @381, @405, @437, @456, @508, @776, @1106, @1547, @1687, @1826, @2029, @2130, @2443, @2490, @2719, @2800, @2832, @3097, @3133, @3268, @3280, @3299, @3379, @3395, @3403, @3422, @3476, @3480, @3504, @3557, @3612, @3619, @3629, @3660, @3714, @3741, @3766, @3893, @3920, @3949, @3962, @3985, @4273, @4346, @4420, @4565, @4609, @4739, @4778, @4786, @4816, @4920, @5090, @5263, @5506, @5739, @6556, @6636, @6955, @7135];
}

+ (NSArray *)dfPix_data2x3 {
	if (useOldDepthData)
		return @[@794, @699, @700, @816, @783];
	else
		return @[@319, @425, @431, @463, @463, @488, @494, @496, @508, @511, @515, @515, @524, @525, @541, @544, @552, @560, @566, @567, @568, @570, @571, @580, @581, @591, @597, @597, @600, @602, @603, @604, @609, @609, @616, @617, @621, @621, @622, @627, @630, @631, @632, @638, @639, @643, @644, @644, @647, @647, @656, @659, @659, @663, @664, @665, @668, @669, @674, @675, @675, @680, @680, @681, @683, @686, @687, @688, @689, @690, @691, @692, @693, @699, @700, @703, @705, @705, @705, @707, @707, @719, @719, @720, @720, @721, @724, @725, @726, @726, @730, @732, @734, @741, @741, @743, @744, @746, @751, @753, @758, @761, @763, @764, @766, @776, @776, @779, @783, @783, @785, @785, @794, @802, @802, @809, @812, @814, @820, @821, @823, @826, @828, @838, @840, @840, @841, @851, @854, @860, @865, @876, @877, @879, @884, @885, @903, @906, @909, @910, @911, @915, @941, @1020, @1104, @1320, @1640, @8922];
}

+ (NSArray *)dfPix_data2x4 {
	if (useOldDepthData)
		return @[@937, @965, @828, @540, @983, @852, @989, @853, @846, @1030, @981, @882, @891, @877, @964];
	else
		return @[@267, @267, @287, @291, @291, @308, @324, @332, @332, @335, @351, @365, @391, @398, @410, @420, @422, @439, @447, @450, @457, @469, @477, @478, @484, @488, @489, @504, @506, @510, @511, @536, @539, @546, @548, @553, @561, @570, @574, @582, @586, @587, @588, @596, @600, @604, @608, @613, @618, @619, @632, @640, @642, @648, @650, @654, @655, @655, @666, @673, @679, @696, @701, @714, @717, @719, @729, @729, @736, @740, @740, @744, @748, @757, @758, @758, @764, @764, @767, @768, @768, @768, @776, @781, @784, @784, @786, @788, @789, @791, @793, @813, @826, @832, @843, @843, @849, @876, @884, @891, @921, @923, @944, @953, @997, @1009, @1325, @1597, @1872, @2467, @2566, @3333, @3495, @3631, @3766, @3799, @3802, @3883, @4549, @4794, @4861, @4866, @4884, @4908, @4919, @5051, @5067, @5157, @5232, @5233, @5239, @5458, @5473, @5495, @5630, @5681, @5691, @5844, @5861, @6084, @6166, @6246, @6856, @6929, @7518, @7614, @8265];
}

# pragma mark - Volume method

static BOOL useOldVolumeData = NO;

static double vol_avg2x1;
static double vol_avg2x2;
static double vol_avg2x3;
static double vol_avg2x4;

+ (NSArray *)vol_data2x1 {
	if (useOldVolumeData)
		return @[@1010.72, @1154.89, @1162.54, @1165.20, @1442.46];

	NSArray *r000 = @[@276.56, @350.46, @374.97, @771.76, @803.06, @905.46, @909.57, @958.43, @1024.49, @1039.35, @1091.29, @1100.84, @1144.66, @1187.98, @1219.34, @1331.67, @1455.71, @1716.98, @1723.91, @1729.26, @1812.48, @1895.45, @1935.24, @2202.46, @2468.71, @2576.1, @2596.29, @2635.37, @2669.37, @2890.23, @2913.18, @3113.21, @3652.06, @4345.85, @5480.84, @6806.45, @8115.58];
	NSArray *r090 = @[@27.03, @383.8, @387.71, @549.06, @754.94, @800.77, @858.87, @876.13, @936.37, @938.16, @982.13, @996.21, @1009.69, @1041.82, @1043.96, @1094.36, @1182.81, @1264.37, @1416.24, @1495.44, @1512.11, @1815.7, @1835.93, @1995.07, @2020.11, @2152.56, @2725.23, @2777.23, @3015.78, @3325.82, @3517.43, @3903.21, @3915.2, @4032.68, @4325.42, @4334.14, @7510.65];
	NSArray *r045 = @[@586.9, @660.65, @667.04, @699.91, @752.05, @767.16, @911.54, @1030.34, @1057.76, @1067.33, @1174.71, @1220.61, @1287.2, @1382.4, @1407.14, @1460.18, @1492.19, @1526.71, @1536.08, @1698.36, @1791.86, @2028.13, @2057.47, @2506.51, @2568.31, @2606.9, @2847.4, @2870.98, @3037.9, @3282.04, @3324.8, @3416.75, @3799.11, @3995.59, @4030.81, @4345.29, @4393.48];
	NSArray *r135 = @[@214.59, @362.17, @384.89, @453.19, @619.73, @721.77, @724.12, @908.65, @1023.87, @1030.31, @1057.28, @1057.73, @1065.18, @1314.33, @1412.71, @1436.69, @1483.68, @1521.35, @1654.15, @1655.05, @1732.89, @2207.27, @2230.93, @2257.92, @2427.78, @2605.57, @2705.74, @2815.97, @2855.03, @2896.53, @2905.51, @3186.16, @3449.71, @3603.48, @3843.26, @4981.24, @8996.73];
	
	NSMutableArray *allRotations = [NSMutableArray array];
	[allRotations addObjectsFromArray:r000];
	[allRotations addObjectsFromArray:r045];
	[allRotations addObjectsFromArray:r090];
	[allRotations addObjectsFromArray:r135];
	
	return [NSArray arrayWithArray:allRotations];
}

+ (NSArray *)vol_data2x2 {
	if (useOldVolumeData)
		return @[@1329.53, @1426.41, @1709.62, @1858.33];
	
	NSArray *r000 = @[@730.16, @760.63, @1311.9, @1354.15, @1363.33, @1422.68, @1424.19, @1432.21, @1455.61, @1528.29, @1573.07, @1673.62, @1741.15, @1835.05, @1844.59, @1876.32, @1895.42, @1924.73, @2061.49, @2266.40, @2272.71, @2325.53, @2368.16, @2374.61, @2425.57, @2652.52, @2845.56, @2862.87, @2964.16, @2983.16, @3004.37, @3119.27, @3132.81, @3203.94, @3362.19, @3465.01, @3479.2];
	NSArray *r045 = @[@380.69, @648.19, @827.72, @830.54, @917.44, @1454.44, @1613.1, @1643.49, @1702.32, @1706.27, @1741.13, @1742.48, @1767.97, @1909.77, @2126.4, @2171.2, @2218.69, @2392.09, @2402.49, @2689.24, @2778.37, @2841.34, @2962.29, @2985.58, @3059.49, @3119.92, @3416.76, @3530.26, @3549.86, @3682.03, @3722.76, @3975.77, @4225.65, @4618.89, @5084.8];
		
	NSMutableArray *allRotations = [NSMutableArray array];
	[allRotations addObjectsFromArray:r000];
	[allRotations addObjectsFromArray:r045];
	
	return [NSArray arrayWithArray:allRotations];}

+ (NSArray *)vol_data2x3 {
	if (useOldVolumeData)
		return @[@2724.99, @2980.98, @3095.13, @3165.68, @3228.99];
	
	NSArray *r000 = @[@569.54, @966.64, @1242.27, @1395.39, @1399.3, @1504.55, @1529.97, @1771.01, @1821.85, @2073.17, @2118.59, @2169.18, @2474.63, @2543.27, @2580.96, @2608.49, @2624.73, @2716.32, @2761.99, @2901.61, @3028.9, @3051.04, @3054.4, @3090.94, @3092.12, @3147.99, @3198.97, @3205.78, @3247.18, @3292.79, @3409.07, @3648.06, @3757.27, @4015.76, @4020.55, @4372.54];
	NSArray *r090 = @[@1022.04, @1141.69, @1473.65, @1691.21, @1897.47, @1912.66, @1978.95, @2136.96, @2290.12, @2347.2, @2373.74, @2384.0, @2454.41, @2481.2, @2489.65, @2517.77, @2524.5, @2647.37, @2685.73, @2715.85, @2726.88, @2783.95, @2849.5, @2849.59, @2860.9, @2877.59, @2917.55, @2961.29, @3006.9, @3036.85, @3067.86, @3142.95, @3271.46, @3312.65, @3340.03, @3456.54, @3604.06];
	NSArray *r045 = @[@1072.33, @1325.64, @1482.31, @1588.17, @1605.56, @1676.49, @1743.82, @1756.48, @1831.28, @1968.11, @2002.2, @2093.62, @2241.59, @2429.61, @2482.73, @2582.29, @2651.05, @2687.27, @2717.12, @2781.67, @2916.48, @2967.31, @3016.13, @3024.65, @3047.59, @3055.71, @3094.34, @3103.92, @3112.26, @3117.2, @3206.33, @3356.17, @3399.75, @3452.14, @3502.33, @3520.21, @3832.29];
	NSArray *r135 = @[@843.11, @1064.79, @1077.47, @1083.71, @1581.61, @1608.81, @1687.13, @1714.77, @1744.82, @1764.39, @1804.45, @1826.89, @1909.25, @1957.86, @1999.05, @2602.21, @2680.24, @2713.59, @2803.72, @2804.26, @2899.18, @2939.69, @2941.06, @2941.29, @2952.38, @2962.79, @2969.62, @2992.9, @3194.14, @3233.97, @3339.82, @3398.65, @3554.34, @3691.19, @3969.5, @4036.15];
	
	NSMutableArray *allRotations = [NSMutableArray array];
	[allRotations addObjectsFromArray:r000];
	[allRotations addObjectsFromArray:r045];
	[allRotations addObjectsFromArray:r090];
	[allRotations addObjectsFromArray:r135];
	
	return [NSArray arrayWithArray:allRotations];}

+ (NSArray *)vol_data2x4 {
	if (useOldVolumeData)
		return @[@2163.38, @3203.94, @3395.28, @3477.24, @3490.70, @3557.25, @3598.26, @3661.18, @3665.95, @3787.94, @3850.46, @4048.33, @4123.17, @4190.74, @4609.89];
	
	NSArray *r000 = @[@519.69, @565.56, @1451.7, @2225.84, @2332.3, @3047.01, @3151.06, @3204.0, @3575.13, @3609.83, @3719.68, @3792.74, @4051.87, @4067.97, @4085.7, @4131.03, @4177.63, @4245.24, @4248.16, @4267.91, @4279.48, @4288.73, @4314.03, @4344.37, @4367.46, @4394.99, @4405.21, @4420.65, @4439.18, @4452.71, @4599.1, @4663.2, @4741.44, @4815.44, @5011.9, @5747.26, @5814.07];
	NSArray *r090 = @[@626.08, @1139.81, @2597.98, @2615.12, @3040.69, @3263.1, @3488.59, @3603.93, @3738.67, @3772.83, @3785.96, @3831.24, @3896.39, @3899.55, @3913.82, @3977.98, @4045.62, @4057.6, @4070.6, @4090.98, @4128.02, @4154.55, @4234.06, @4271.97, @4308.51, @4332.52, @4372.44, @4449.17, @4468.26, @4470.79, @4507.73, @4521.8, @4766.56, @5110.7, @5443.51, @5635.83, @6848.4];
	NSArray *r045 = @[@729.02, @1117.35, @1121.36, @1694.06, @1877.36, @2682.97, @2808.59, @2837.49, @3110.85, @3112.7, @3389.88, @3418.9, @3437.4, @3463.3, @3706.5, @3754.86, @3787.92, @3879.54, @3900.28, @3960.08, @3975.43, @4020.56, @4102.43, @4166.51, @4190.58, @4218.54, @4258.62, @4374.92, @4399.94, @4438.04, @4447.84, @4481.28, @4602.24, @4689.29, @5049.39, @5410.54, @5430.65];
	NSArray *r135 = @[@706.8, @1229.11, @1326.17, @1417.07, @1578.84, @1878.25, @2172.21, @2176.23, @2398.97, @2543.82, @2611.83, @2611.95, @2867.62, @3108.56, @3174.09, @3292.72, @3325.31, @3521.67, @3636.05, @3778.47, @3848.65, @3925.0, @3925.84, @4006.72, @4108.37, @4146.52, @4306.62, @4367.26, @4429.2, @4500.17, @4501.62, @4833.69, @5099.75, @5168.27, @5241.12, @5863.07, @5961.68];
	
	NSMutableArray *allRotations = [NSMutableArray array];
	[allRotations addObjectsFromArray:r000];
	[allRotations addObjectsFromArray:r045];
	[allRotations addObjectsFromArray:r090];
	[allRotations addObjectsFromArray:r135];
	
	return [NSArray arrayWithArray:allRotations];
}

@end

//Scad file cleaned up by Durwin Pye, Thanks

use <parametric_involute_gear_v5.0.scad>; // Parametric Involute Bevel and Spur Gears by GregFrost
use <TextGenerator.scad>; // OpenSCAD 3D Text Generator by Phil Greenland, published Mar 10, 2013

/*//////////////////////templates//////////////////

Date - 03/01/2014
Project- 3 jaw chuck
Version -1.1 

Author - Bobwomble


/////////////////////////Parameters///////////////*/
////////////////////////////////////////////////////

N = 3;						//number of jaws (1, 2, 3, 4, 5, or 6) *works best at 3 and 4, 7 overlaps
chuck_outer_diam =100; 		//max 100
chuck_outer_thickness=8;	//max 8
chuck_center_hole=20;		//max 20
chuck_inner_thickness=8;	//max 8
clearance=(0.4);			//0.4
jaw_length=(40);			//40
dist_center=(12);			//12
res=20; 					//low (20) for testing, change to high (120) for printing
screw_res=20;				//lower resolution for small features
hex_res=6;					//6-sided for hex nuts and hex head bolts
pin_radius=(3+clearance);
function radiusAt(radius, angle, pitch) = radius - pitch * (angle/360);

//bevel_gear_pair parameters
gear1_teeth = 14;
gear2_teeth = 41;
gear2_diam = 77.9;
gear2_bore_diam = 36;
gear2_thickness = 12;
gear2_bevel = 2.2;
gear_axis_angle = 90;
gear_cone_distance = 42.4;
gear_outside_circular_pitch = 352;

/////////////////////////Module List////////////////
///////////////////////////////////////////////////

//////Primary Modules//////

	//drive_gears();
//	face_housing();
	//gear_ring();
//	housing_print_supports() ;
//	rear_housing();
	jaws();
//	scroll();
	
///////Secondary Modules//////
//	3mmscrew_cutouts();
//	backplate_screws();
//	backplate_screw_cutouts();
//	backplate_center_screws();
//	backplate_center_screw_cutouts();
//	base_plate();
//	centre_bore();
//	drive_gear();
//	drive_gear_cutouts();
//	gear_screws();
//	housing_print_support1();
//	housing_print_support2();
//	jaw(1);
//	jaw_base();	
//	jaw_cap();
//	jaw_complete();
//	jaw_cutaway();
//	jaw_number(number);
//	jaw_point();
//	jaw_point_notch();
//	jaw_spiral();
//	locking_pins();
//	outer_housing();
//	rnd_cnr();
//	rnd_cnr_chuck();
//	spiral();
//	spiral_thread();
//	torus();

///////////////////////Modules///////////////////////
/////////////////////////////////////////////////////

module 3mmscrew_cutouts(){
	cylinder (h=8,r=2.6/2);					//drill size
	cylinder (h=4.76,r=3.2/2);				//screw size
	translate ([0,0,-9])
		cylinder (h=2+8,r=5.5/2);			//head size	
}

module backplate_screws() {
	for ( i = [0 : (N+1)] )
	{
		rotate( i * 360 / N, [0, 0, 1])
		{
			translate ([0,-((chuck_outer_diam-chuck_outer_thickness))/2,-43])
				cylinder (h=38.5,r=3.7/2,$fn=screw_res);										//shaft
			translate ([0,-((chuck_outer_diam-chuck_outer_thickness))/2,1])
				cylinder (h=10,r=3.7/2,$fn=screw_res);											//shaft
			translate ([0,-((chuck_outer_diam-chuck_outer_thickness))/2,-43])
				cylinder (h=3+1.5,r=7.8/2,$fn=screw_res);										//head h=3+1.5,r=7.8/2,$fn=screw_res
			translate ([0,-((chuck_outer_diam-chuck_outer_thickness))/2,-4.25])
				cylinder (h=3.25,r=7.75/2,$fn=hex_res);										//hex nut
			translate ([-1,-((chuck_outer_diam-chuck_outer_thickness))/2,-4.25])
				cube ([2,10,3.25]);
			translate ([0,-((chuck_outer_diam-chuck_outer_thickness))/2,-0.75])
				cylinder (h=3.25,r=7.75/2,$fn=hex_res);										//hex nut
			translate ([-3.875,-((chuck_outer_diam-chuck_outer_thickness))/2,-0.75])
				cube ([7.75,10,3.25]);
		}
	}	
}

module backplate_screw_cutouts() {
	for ( i = [0 : (N+1)] )
	{
		rotate( i * 360 / N, [0, 0, 1])
		{
			translate ([0,-((chuck_outer_diam-chuck_outer_thickness))/2,0])
				cylinder (h=10,r=3.7/2,$fn=screw_res);		//shaft
			translate ([0,-((chuck_outer_diam-chuck_outer_thickness))/2,-4.25])
				cylinder (h=3+1.5,r=7.5/2,$fn=screw_res);	//head 
		}
	}	
}

module backplate_center_screws() {
  	for ( i = [0 : (N+1)] )
	{
		rotate( i * 360 / N, [0, 0, 1])
		{
		   translate ([0,-((29))/2,-63])
				 cylinder (h=38.5,r=3.7/2,$fn=screw_res);					//shaft
		   translate ([0,-((29))/2,-20.5])
				 cylinder (h=10,r=3.7/2,$fn=screw_res);					//shaft
		   translate ([0,-((29))/2,-63])
				 cylinder (h=3+1.5,r=7.8/2,$fn=screw_res);					//head h=3+1.5,r=7.8/2,$fn=screw_res
		   translate ([0,-((29))/2,-24.25])
				cylinder (h=3.25,r=7.75/2,$fn=hex_res);					//hex nut
			translate ([-2.5,-((49))/2,-24.25])
				cube ([5,10,3.25]);
		   translate ([0,-((29))/2,-20.5])
				cylinder (h=3.25,r=7.75/2,$fn=hex_res);					//hex nut
			translate ([-3.875,-((49))/2,-20.5])
				cube ([7.75,10,3.25]);
		}
	}	
}

module backplate_center_screw_cutouts() {
	for ( i = [0 : (N+1)] )
	{
		rotate( i * 360 / N, [0, 0, 1])
		{
		   translate ([0,-((chuck_center_hole+chuck_inner_thickness))/2,0])
				 cylinder (h=10,r=3.7/2,$fn=res);	//shaft
		   translate ([0,-((chuck_center_hole+chuck_inner_thickness))/2,-4.25])
				 cylinder (h=3+1.5,r=7.8/2,$fn=res);	//head 
		}
	}	
}

module base_plate() {
	difference ()
	{
		translate ([0,0,-3.99])
			cylinder (h=4,r=((chuck_outer_diam-chuck_outer_thickness*2)/2),$fn=res);
		translate ([0,0,-20])
			cylinder (h=24,r=((chuck_center_hole+chuck_inner_thickness*2)/2),$fn=res);
	}
}

module centre_bore() {
	difference ()
	{
		union ()
		{
			translate ([0,0,-5]) 
				cylinder (h=53,r=(((chuck_center_hole+chuck_inner_thickness*2)-clearance)/2),$fn=res);
			translate ([0,0,32.5]) 
				cylinder (h=8,r=(((chuck_center_hole+chuck_inner_thickness*3)-clearance)/2),$fn=res);	////DP: New feature
		}
		translate ([0,0,-7])
			cylinder (h=58,r=chuck_center_hole/2);			//(h=46,r=chuck_center_hole/2);
	}
}

module drive_gear(){
	difference ()
	{
		union()
		{
			difference ()
			{
				union ()
				{
					translate ([0,-14.1619,-23.44])			//([0,-16.1619,-23.44])
						rotate ([90,0,0])
							cylinder (h=7,r=8/2,$fn=res);	//(h=5,r=8/2,$fn=res)center pin***
					translate ([0,-40,-23.44])				//([0,-40,-23.44])
						rotate ([-90,0,0])
							bevel_gear (					//(14,42.4,352,0)
								number_of_teeth=gear1_teeth,
								cone_distance=gear_cone_distance,	
								outside_circular_pitch=gear_outside_circular_pitch,
								bore_diameter=0
								);
				}
				translate ([-25,-45,-54])					//([-25,-45,-54])
					cube ([50,6,60]);
			}
			translate ([0,-38.98,-23.44])					//([0,-38.98,-23.44])
				rotate ([90,0,0])
					cylinder (h=11,r=31/2,$fn=res);			// (h=9,r=31/2,$fn=res)outer pin
		}
		translate ([0,-40.5,-23.44])
			rotate ([90,0,0])
				cylinder (h=10,r=9.5/2,$fn=hex_res);				//8mm hex key socket r=9.4 is a tight fit
		translate ([0,-48,-23.44])							//([0,-46,-23.44])
			rotate ([90,0,0])
				cylinder (h=2,r1=7/2,r2=10/2,$fn=res);		//chamfer hex socket
		torus();
		translate ([0,3.8,0])								//([0,5.8,0])
			rnd_cnr();
	}
	//translate ([0,0,-49])									//FOR TESTING ONLY
	//	outer_housing();									//FOR TESTING ONLY
}

module drive_gear_cutouts() {	
	for ( i = [0 :(N+1)] )
	{
		rotate( i * 360 / N, [0, 0, 1])
		{
			translate ([0,-32.98,-23.44])
				rotate ([90,0,0])
					cylinder (h=24,r=31.15/2,$fn=res);// outer pin+tolerance
			translate ([0,-12,-23.44])
				rotate ([90,0,0])
					cylinder (h=50,r=8.15/2,$fn=res);// inner pin+tolerance
		}
	}	
}

module drive_gears() 	{
	////make and position 3 drive gears
	rotate ([0,0,29.5])
		for ( i = [0 :(N+1)] )
		{
		rotate( i * 360 / N, [0, 0, 1])
			translate ([0,-0.25,0]) // to give a bit of clearance
				drive_gear();
		}
	}

module face_housing() {
	difference () 
	{
		////BODY
		union() 
		{
			translate ([0,0,-37])
				centre_bore();
			translate ([0,0,-34])
				outer_housing();
			translate ([0,0,3.1])
				cylinder (h=8,r=((chuck_outer_diam+1)/2),$fn=res);
		}
		translate ([0,0,-50])
			cylinder (h=70,r=22/2,$fn=res);					//make center bore larger
		translate ([0,0,-14.5])
			cylinder (h=26,r=chuck_center_hole/2);
		////JAW SLOTS	
		for ( i = [0 : (N+1)] )
		{
			rotate( i * 360 / N, [0, 0, 1])
			{
				translate ([0,-4.25,6])
					cube ([55,8.5,6]);
				translate ([0,-8.25,0.1])
					cube ([55,16.5,6]);	
			}	
		}
		////CUTOUTS
		rotate([0,0,90/N])
			drive_gear_cutouts();	
		rotate([0,0,90/N+19.8])
			locking_pins();
		rotate([0,0,-90/N])
		{
			translate ([0,0,-6]) 
			{
				backplate_screws();
				backplate_center_screws();
				rnd_cnr_chuck();
			}
		}
	}
}

 module gear_ring(){
	translate([0,0,-8]) rotate([0,180,0]) difference() {
		union() {
			difference() {
				 bevel_gear (
					number_of_teeth=gear2_teeth,
					cone_distance=gear_cone_distance,
					axis_angle=gear_axis_angle,
					bore_diameter=gear2_bore_diam,
					outside_circular_pitch=gear_outside_circular_pitch); 
				translate ([0,0,-gear2_thickness]) cube([gear2_diam*3,gear2_diam*3,20],center=true);
			}
			translate([0,0,-4.2]) cylinder(r1=gear2_diam/2-0.75,r2=gear2_diam/2,h=gear2_bevel); 
		}
		translate([0,0,-50]) cylinder(r=gear2_bore_diam/2,h=100);
		rotate([0,0,-6.5]) translate([0,0,-1]) gear_screws_cutouts();  
		translate([0,0,-10]) difference() {
			cylinder(r=gear2_diam/2+10,h=20); 
			cylinder(r=gear2_diam/2,h=20); 
		}
	}
}
 
module gear_screws_cutouts() {
	for ( i = [0 : 6] )
		rotate( [180, 0, i * 360 / 7])
			translate([30, 0, 0])
				3mmscrew_cutouts();
}

module housing_print_support1() {
	for ( b = [0 : (N+1)] )
	{
		rotate( b * 360 / N, [0, 0, 1]) 
		{		
			difference()
			{
				 translate ([10,-2.5,0.1])
					 cube ([8,5,11]);		
				 translate ([10.4,-2.1,0])
					 cube ([7.2,4.2,10]);		
			}	
		}
	}
}

module housing_print_support2() {	
	for ( b = [0 : (N+1)] )
	{
		rotate( b * 360 / N, [0, 0, 1])
		{
			difference()
			{
			 translate ([41,-2.5,0.1])
				 cube ([10,5,10.9]);		
			 translate ([41.4,-2.1,0])
				 cube ([9.2,4.2,9.9]);		
			}	
		}
	}
}

module housing_print_supports() {
	translate ([0,0,11.3])
		rotate ([180,0,0])
		{
			housing_print_support1();
			housing_print_support2();
		}
}

module rear_housing() {
	difference ()
	{
		translate ([0,0,-39.25])
		{
			difference ()
			{
				union ()
				{
					translate ([0,0,-(2.75+6)])
						//cylinder (h=43.75,r=(83.5/2),$fn=res);
						cylinder (h=43.75,r=(((chuck_outer_diam-chuck_outer_thickness*2)-clearance)/2),$fn=res); 
					translate ([0,0,-8.75])
						cylinder (h=6,r=((chuck_outer_diam+1)/2),$fn=res);
				}
				translate ([0,0,-2.75])
					cylinder (h=62,r=(((chuck_outer_diam-chuck_outer_thickness*2)-5+clearance)/2),$fn=res);
				////gear cutouts
				rotate ([0,0,29.5])
					for ( i = [0 :(N+1)] )
					{
						rotate( i * 360 / N, [0, 0, 1])
							{
								translate ([0,-30,15])
									rotate ([90,0,0])
										cylinder (h=20,r=33/2,$fn=res);
								translate ([-16.5,-44,15])
									cube ([33,12,40]);
							}
					}
				translate ([0,0,-5.25])
					backplate_screw_cutouts();
				translate ([0,0,-5.25])
					backplate_center_screw_cutouts();
			}
		translate ([0,0,-4.75])//([0,0,-43])
			cylinder (h=7,r=21.65/2,$fn=res);//(h=12,r=21.75/2,$fn=res)center bore bit??
		}
		////M10 drive bolt
		translate ([0,0,-43.5])
			cylinder (r=18/2,h=8,$fn=hex_res);
		translate ([0,0,-50])
			cylinder (r=10/2,h=40,$fn=res); 
	}
}

module rear_housing_test(){ 			//for testing
	difference ()
	{
		translate ([0,0,-2.99])
			cylinder (h=34,r=((chuck_outer_diam-chuck_outer_thickness*2)/2),$fn=res);
		translate ([0,0,-3])
			cylinder (h=52,r=(((chuck_outer_diam-chuck_outer_thickness*2)-6)/2),$fn=res);
		translate ([0,-30,15])
			rotate ([90,0,0])
				cylinder (h=20,r=28/2,$fn=res);
	}
}

module jaw(number) {
	difference()
	{
		rotate ((360/N)*(number-1),[0,0,1])
			jaw_complete();
		translate ([0,0,0.2])
			jaw_spiral(9,125,2.3,3,3.8,100);////SPIRAL (_revolutions=4, _diameter=86, _thickness=2.3, _height=3, _gap=3.8, _resolution=100)
	}	
	rotate ((360/N)*(number-1),[0,0,1])
		jaw_number(number);
}

//------------
/*
module jaw(number); {
	difference()
	{
		rotate ((360/N)*(number-1),[0,0,1])
			jaw_complete();
		translate ([0,0,0.2])
			#jaw_spiral(4,86,2.3,3,3.8,100);////SPIRAL (_revolutions=4, _diameter=86, _thickness=2.3, _height=3, _gap=3.8, _resolution=100)
	}	
	rotate ((360/N)*(number-1),[0,0,1])
		jaw_number(number);
}
*/
//---------------------


module jaw_complete() {
	jaw_base();
	jaw_cap();
}

module jaw_base() {
	translate ([dist_center,0,0])
		difference()
		{
			union()
			{
				translate ([0,-4.125,5.1])						//([0,-4.125,5.1])
					cube ([jaw_length,8.25,6]);					//([jaw_length,8.25,6]);
				translate ([0,-8.125,-0.1])						//([0,-8.125,-0.1])
					cube ([jaw_length,16.25,5.9]);				//([jaw_length,16.25,6]);
			}
		translate ([2.5,0,0])
			jaw_point();
		translate ([jaw_length-17.75,0,-16])	 
			jaw_cutaway();										//cube ([jaw_length,18,20]);
	}
}

module jaw_cap() {
	translate ([dist_center,0,11.2])
		difference()
		{
			translate ([-1.5,-8.125,-0.1])			//([0,-8.125,-0.1])
				cube ([jaw_length+5,16.25,20]);		//([jaw_length,16.25,20]);
			jaw_cutaway();
			translate ([12,0,-6])	 
				jaw_cutaway();						//cube ([jaw_length,18,20]);
			translate ([jaw_length-17.75,0,-16])	 
				jaw_cutaway();						//cube ([jaw_length,18,20]);
			translate ([1,0,0])
				jaw_point();
			translate ([1,0,0])
				jaw_point_notch();
		}
}

module jaw_cutaway() {
	difference()
	{ 
		translate ([14,-9,14])
			cube ([jaw_length+2,18,20]);
		translate ([-3,0,13])
			cylinder (h=22,r=40/2,$fn=res);
	}
}

module jaw_number(number) {
////number jaws
	rotate ([90,0,180])
		translate ([-30,12,7.5])//-9.5
			drawtext (str(number));					// using TextGenerator.scad
}

module jaw_point() {
	difference()//make a point at center
	{
	translate ([-3,0,0])
		cube ([18,30,60],center=true);
	translate ([15-3,4,-1])
		rotate ([0,0,60])
			cube ([22,22,63],center=true);
	translate ([15-3,-4,-1])
		rotate ([0,0,-60])
			cube ([22,22,63],center=true);
	}
}

module jaw_point_notch() {
translate ([-8,0,-1.25])
	for (i=[0:4.25:22])
	{
	translate ([0,-3,i])
		cube ([6,6,1]);
	}
}
	
module jaw_spiral(_revolutions=4, _diameter=86, _thickness=2.3, _height=3, _gap=3.8, _resolution=100){
	union()
	{
	////SPIRAL (_revolutions=4, _diameter=86, _thickness=2.3, _height=3, _gap=3.8, _resolution=100);
	rotate ([0,0,-120])
		spiral(_revolutions, _diameter, _thickness, _height, _gap, _resolution);
	////LARGE BASE
	translate ([0,0,-3.99])
		cylinder (h=4,r=((124)/2),$fn=res);
	}
}

module jaws() {
	for ( i = [1 : N] )
		jaw(i);
}

module locking_pins() {
	////3mm
	for ( i = [0 : (N+1)] )
	{
		rotate( i * 360 / N, [0, 0, 1])
		{  
		   translate ([0,-((chuck_outer_diam-chuck_outer_thickness)+0.5)/2,-43])
				cylinder (h=48,r=3.5/2,$fn=screw_res);//shaft
		   translate ([0,-((chuck_outer_diam-chuck_outer_thickness)+0.5)/2,-43])
				cylinder (h=24,r=4/2,$fn=screw_res);//thread
		   translate ([0,-((chuck_outer_diam-chuck_outer_thickness)+0.5)/2,-43])
				cylinder (h=3.5+1,r=7.5/2,$fn=screw_res);//head
		}
	}	
}	
	
module outer_housing() {
difference ()
	{
	translate ([0,0,-8])
		cylinder (h=48,r=((chuck_outer_diam+1)/2),$fn=res);
	translate ([0,0,-9])
		cylinder (h=50,r=(((chuck_outer_diam-chuck_outer_thickness*2)+clearance)/2),$fn=res);
	}
}

module rnd_cnr(){
difference ()
{
translate ([0,-50,-23.44])
	rotate ([90,0,0])
	cylinder (h=8,r=40/2);

	translate([0,-50,-23.44])
	  rotate ([90,0,0])
		rotate_extrude(convexity = 10, $fn = 100)
			translate([25/2, 0, 0])//([21.8/2, 0, 0])
				circle(r = 8/2, $fn = 100);
	translate ([0,-46,-23.44])
		rotate ([90,0,0])
			cylinder (h=8,r=24/2);
}	
}

module rnd_cnr_chuck() {
//////round corner of chuck face
	difference()
	{
	translate ([0,0,11])
		cylinder (r=110/2,h=10);
	translate ([0,0,10])
	rotate ([0,0,0])
	rotate_extrude(convexity = 10, $fn = 100)
		translate([90/2, 0, 0])//([21.8/2, 0, 0])
			circle(r = 8, $fn = 40);
	translate ([0,0,10])
		cylinder (r=86/2,h=10);
	}
}

module scroll() {
	translate([0,0,-4]) difference() {
		intersection() {
			translate ([0,0,-5]) cylinder(r=42,h=15);
			union() {
				translate ([0,0,4]) jaw_spiral();
				cylinder(r=42,h=4);
			}
		}
		translate ([0,0,-1]) cylinder(r=18,h=10);
		rotate([0,0,-30]) translate ([10,-0.1,4]) cube([10.2,10,10]);
		rotate([0,180,-45]) translate ([0,0,4.8]) gear_screws_cutouts();
	}
}

module spiral(revolutions, diameter, thickness, height, gap, resolution) {
	eps = 0.2;
	radius = diameter/2;
	revolutions = min(revolutions, radius/(thickness+gap)-eps);
	pitch = thickness + gap;
	angleStep = 360/round(resolution);

	union()
	for (angle = [0:angleStep:360*revolutions-angleStep]) {
		assign(	r0 = radiusAt(radius, angle, pitch),
					r1 = radiusAt(radius, angle+angleStep, pitch),
					r2 = radiusAt(radius-thickness, angle+angleStep, pitch),
					r3 = radiusAt(radius-thickness, angle, pitch)
					) {
			linear_extrude(height = height, slices=1) {
					polygon(	points=[	[r0*sin(angle),r0*cos(angle)],
											[r1*sin(angle+angleStep),r1*cos(angle+angleStep)],
											[r2*sin(angle+angleStep+eps),r2*cos(angle+angleStep+eps)],
											[r3*sin(angle-eps),r3*cos(angle-eps)] ],
								paths=[[0,1,2,3]]);
			}			
		}
	
	}

}

module spiral_thread() {
	// number of revolutions around the circle
	_revolutions = 8.5; //4, for jaw 8

	// outside diameter of the spiral
	_diameter = 116; //86, for jaw 108

	// thickness of each ring of the spiral
	_thickness = 2.3;//2.3, for jaw....

	// height of the spiral
	_height = 3; //3

	// gap between rings of the spiral
	_gap = 3.8; //3.8, for jaw maybe make smaller
	// number of sections around the circle
	_resolution = 100;//100+ for printing  
	difference ()
	{
		union()
		{
			spiral(_revolutions, _diameter, _thickness, _height, _gap, _resolution);
				translate ([0,0,-3.99])
					cylinder (h=4,r=((chuck_outer_diam-chuck_outer_thickness*2)/2),$fn=res);
		}
			////REMOVE END OF SPIRAL
			translate ([-9,12,0])
				cube ([10,8,6]);
			translate ([0,0,-20])
				cylinder (h=24,r=((chuck_center_hole+chuck_inner_thickness*2)/2),$fn=res);
			translate ([0,0,-35])
				rear_housing();
			translate ([0,0,-25])
				outer_housing(); 
	}
	difference()
	{
		rotate ([0,0,13.65])
		locking_pins();
	}
	{
		for ( i = [0 : 6] )
		rotate( i * 360 / 7,[0,0,1])
		 translate([30, 0, -8.75])
				3mmscrew_cutouts();
	}
}

module torus(){
translate([0,-(chuck_outer_diam-chuck_outer_thickness)/2+2.71,-23.44])
	    //([0,-(chuck_outer_diam-chuck_outer_thickness)/2+1.3,-23.44])
rotate ([90,0,0])
rotate_extrude(convexity = 10, $fn = 100)
translate([31/2, 0, 0])//([21.8/2, 0, 0])
circle(r = (pin_radius), $fn = 100);
}


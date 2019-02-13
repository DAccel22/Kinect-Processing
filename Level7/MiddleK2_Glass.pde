/*
  The glass will break when you pounch the air with your right hand
  or move your right hand closer to the kinect
  Using the depth information
  Should refer to Kinect3D_empty
*/
import KinectPV2.*;
import java.util.*;

KinectPV2 kinect;
ArrayList<KSkeleton> skeletonArray;
float a,b,c,d;//varied with circumstance
float depth;
float pZ;
section[] sections;
color couleurEnCours;

void setup(){
  //background(0);
  sections = new section[0];
  couleurEnCours = color(random(255),random(255),random(255)); stroke(255);
  kinect=new KinectPV2(this);
  frameRate(200);
  kinect.enableSkeleton3DMap(true);
  
  kinect.init();
  size(500,500);
  a=250;
  b=250;
  c=-250;
  d=250;
  pZ=0;
}

void draw(){
  
  skeletonArray =kinect.getSkeleton3d();
  for(int i=0;i<skeletonArray.size();i++){
    KSkeleton skeleton =(KSkeleton) skeletonArray.get(i);
    
    if(skeleton.isTracked()){
      KJoint[] joints=skeleton.getJoints();
      
      KJoint handR=joints[KinectPV2.JointType_HandRight];
      //KJoint handL=joints[KinectPV2.JointType_HandLeft];
      depth=handR.getZ();
      //fill(255,0,0);
      //ellipse(handR.getX()*a+b,handR.getY()*c+d,100,100);//y is in opposite direction
      println("Depth: "+depth+" X:"+handR.getX()+" Y: "+handR.getY());//m
      glassBreak(handR);
      //glassBreak(handL);
    }
  }     
}

void glassBreak(KJoint hand){
  background(couleurEnCours);
  for(int a=sections.length-1;a>0;a--){
    sections[a].dessine();
  }
   section[] newsections = new section[0];
  for(int a=0;a<sections.length;a++){
    if(sections[a].tokill==false){
     newsections = (section[]) append(newsections, sections[a]); 
    }
  }
  sections = newsections;   
  if(hand.getZ()-pZ<-0.08){
    float[] centre = {hand.getX()*a+b, hand.getY()*c+d};
  float[] p1 = {0,0};float[] p2 = {width,0};float[] p3 = {width,height};float[] p4 = {0,height};
  decoupe(10,p1,p2,p3,p4,centre, couleurEnCours );
  couleurEnCours = color(random(255),random(255),random(255)); 
  }
  pZ=hand.getZ();
}


void  decoupe (int fois, float[] a,float[] b,float[] c,float[] d, float[] centre, color coul ){
  float t1=random(0.1,0.9);
  float t2=random(0.1,0.9); 
  float[] p1={
    a[0]+(b[0]-a[0])*t1, a[1]+(b[1]-a[1])*t1        };
  float[] p2={
    d[0]+(c[0]-d[0])*t2, d[1]+(c[1]-d[1])*t2        };  
  fois--;
  if(fois>0){
    decoupe(fois, p1, p2, d, a, centre, coul );
    decoupe(fois, b, c, p2, p1, centre, coul );
  } 
  else {
     sections = (section[]) append(sections, new section(a,b,c,d,centre,coul)); 
  }
} 

class section{
  float vx,vy,an,van;
  float[] pos =new float[2];
  boolean tokill=false;
  coord[] coords;
  color col;
  section(float[] _a, float[] _b, float[] _c, float[]  _d, float[] centre, color coul){ 
    col=coul;
    /// créer la vitesse en fonction du centre
    float ang = random(TWO_PI);
    an=0;
    //  col=color(random(255),random(255),random(255));
    float vitz = random(1,20);
    pos[0]= (_a[0]+_b[0]+_c[0]+_d[0])/4;
    pos[1]= (_a[1]+_b[1]+_c[1]+_d[1])/4; 
    float aaan = atan2(pos[1]-centre[1],pos[0]-(centre[0]));
    aaan+=radians(random(-5,5));
    vx=cos(aaan)*vitz;
    vy=sin(aaan)*vitz;
    van=radians(random(-10,10));
    coords = new coord[4];
    coords[0] = new coord(pos[0] ,pos[1], _a[0], _a[1]);
    coords[1] = new coord(pos[0] ,pos[1], _b[0], _b[1]);
    coords[2] = new coord(pos[0] ,pos[1], _c[0], _c[1]);
    coords[3] = new coord(pos[0] ,pos[1], _d[0], _d[1]);
  }
  void dessine(){
    if(!tokill){
      an+=van;
      vx*=1.035;
      vy*=1.0351; 
      vy+=0.01;
      pos[0]+=vx;
      pos[1]+=vy; 
      fill(col);
      beginShape(); // ,pos[1]
      float[] a=coords[0].affiche(an);
      vertex(pos[0]+a[0]  ,pos[1]+a[1]);
      float[] b=coords[1].affiche(an);
      vertex(pos[0]+b[0]  ,pos[1]+b[1]);
      float[] c=coords[2].affiche(an);
      vertex(pos[0]+c[0]  ,pos[1]+c[1]);
      float[] d=coords[3].affiche(an);
      vertex(pos[0]+d[0]  ,pos[1]+d[1]); 
      endShape(CLOSE);    
      if(vy>height+30 || vy<-30 || vx<-30 || vx> width+30){
        tokill=true;  
      }
    } 
  }
}

class coord{
  float an,ray;
  coord(float cx,float  cy,float  _x,float  _y){
    an= atan2(_y-cy, _x-cx); 
    ray=getDistance(cx,cy,_x,_y); 
  }
  float[] affiche(float _an){
    _an+=an;
    float[] toreturn=new float[2];
    toreturn[0]= cos(_an)*ray;
    toreturn[1]= sin(_an)*ray; 
    return toreturn;
  }
}

float getDistance(float x1, float y1, float x2, float y2){
  return sqrt(pow(x2-x1,2)+pow(y2-y1,2)); 
}

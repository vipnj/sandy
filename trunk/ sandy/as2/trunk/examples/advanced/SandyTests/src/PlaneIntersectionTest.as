/**
 * @author tom
 */

import com.bourre.commands.Delegate;

import sandy.core.data.Matrix4;
import sandy.core.data.Vector;
import sandy.core.group.Group;
import sandy.core.group.TransformGroup;
import sandy.core.transform.Transform3D;
import sandy.core.World3D;
import sandy.events.ObjectEvent;
import sandy.math.Matrix4Math;
import sandy.math.VectorMath;
import sandy.primitive.Box;
import sandy.primitive.Line3D;
import sandy.primitive.Plane3D;
import sandy.skin.MixedSkin;
import sandy.view.Camera3D;
import sandy.view.ClipScreen;

class PlaneIntersectionTest
{
	private var _mc:MovieClip;
	private var __screen:ClipScreen;
	private var __cam:Camera3D;
	private var __rootGrp:Group;
	private var __grille3D:Plane3D;
	private var __ligne3D:Line3D;
	private var __repereTg:TransformGroup;
	private var mc:MovieClip;
	private var incrementeur:Number=5;
	private var circlePos:Number=-180;

	public static function main( mc:MovieClip ):Void
	{
		if( !mc ) mc = _root;
		var p:PlaneIntersectionTest = new PlaneIntersectionTest( mc );
		p.init();
	}
	
	//Constructeur
	function PlaneIntersectionTest (mc:MovieClip)
	{
		_mc = mc;
	}

	//Methodes
	public function init():Void
	{
		//Initialisation de la vue
		//_mc = _root.createEmptyMovieClip('screen', 7);
		__screen = new ClipScreen( 600, 300 );
		World3D.getInstance().setContainer(_mc);
		//Initialisation de la camera
		__cam = new Camera3D(__screen);
		//__cam.setPerspectiveProjection(_fov,_ratio,1.0,1000.0);
		__cam.setPosition(0.0, 10.0, 35.0);
		__cam.lookAt(0,0,0);
		//__cam.setProjectionMatrixFovLH(90.0,1.0,1.0,100.0);
		World3D.getInstance().setCamera( __cam );
		//Initialisation du groupe root
		__rootGrp = new Group();
		World3D.getInstance().setRootGroup( __rootGrp );
		//Creation de la grille
		__repereTg = new TransformGroup();
		__rootGrp.addChild( __repereTg );
		var gridTGrp:TransformGroup = createGrille();
		__rootGrp.addChild(gridTGrp);
		__grille3D.addEventListener(ObjectEvent.onPressEVENT, this,grillePress);
		
		//Ecoute rotation
		var unEcouteur:Object = new Object();
		unEcouteur.onKeyDown = Delegate.create(this, worldRotate);
		unEcouteur.onKeyUp = Delegate.create(this, initWorldRotate);
		Key.addListener(unEcouteur);
		
		World3D.getInstance().render();
	}
	
	private function initWorldRotate():Void
	{
		incrementeur = 5;
	}
	
	private function worldRotate():Void
	{
		var distance:Number = 35;
		var pi:Number = Math.PI;
		if(Key.isDown(Key.LEFT))
		{
			var CamY:Number = World3D.getInstance().getCamera().getPosition().y;
			// On tourne vers la gauche
			circlePos -=incrementeur;
			incrementeur++;
			World3D.getInstance().getCamera().setPosition(Math.cos(circlePos*pi/360)*distance,CamY,Math.sin(circlePos*pi/360)*distance);
			World3D.getInstance().getCamera().lookAt(0,0,0);
		}
		if(Key.isDown(Key.SPACE))
		{
			//trace("toto");
			grillePress();
		}
		if(Key.isDown(Key.RIGHT))
		{
			var CamY:Number = World3D.getInstance().getCamera().getPosition().y;
			// On tourne vers la droite
			circlePos +=incrementeur;
			incrementeur++;
			World3D.getInstance().getCamera().setPosition(Math.cos(circlePos*pi/360)*distance,CamY,Math.sin(circlePos*pi/360)*distance);
			World3D.getInstance().getCamera().lookAt(0,0,0);
		}
	}
	
	private function createGrille():TransformGroup
	{
		var grilleSkin:MixedSkin = new MixedSkin(0x00FF00,20,0x00FF00,100,1);
		var grilleTGrp:TransformGroup = new TransformGroup ();

		__grille3D = new Plane3D(40,40,2,"quad");
		__grille3D.setSkin(grilleSkin);
		__grille3D.enableEvents(true);
		grilleTGrp.addChild(__grille3D);
		return grilleTGrp;
	}
	
	public function mouseCapture():Void
	{
		__grille3D.addEventListener(ObjectEvent.onPressEVENT, this,grillePress);
	}
	
	private function grillePress(e:ObjectEvent):Void
	{
		trace("Univers : grillePress !!! ");
		//for( var a:String in e.getTarget().aPoints )
		//	trace(e.getTarget().aPoints[a].toString() );
			
		var monX:Number =  ( __screen.getClip()._xmouse  - World3D.getInstance().getCamera().getXOffset() ) / World3D.getInstance().getCamera().getXOffset() ;
		var monY:Number = -( __screen.getClip()._ymouse  - World3D.getInstance().getCamera().getYOffset() ) / World3D.getInstance().getCamera().getYOffset() ;
		trace("Mouse : (" + monX + ";" + monY + ")");
		//récupération de la matrice de projection
		var c:Camera3D = World3D.getInstance().getCamera();
		//calcul de la projection inverse
		var maMatrice:Matrix4 = Matrix4Math.getInverse(c.getMatrix());
		//Creation du point 3D à partir du point 2D (0 en z correspond au plan de clipping proche)
		var mV:Vector = new Vector(monX,monY,1);
		trace("Vecteur 2D : "+mV );
		//projection inverse
		Matrix4Math.vectorMult(maMatrice,mV);
		trace("Point3D dans repere monde: " + mV.toString());
		//création d'un vecteur à partir du point calculé et de la position de la caméra
		var cP:Vector = World3D.getInstance().getCamera().getPosition();
		trace("Camera position: "+cP.toString() );
		var mV2:Vector = new Vector(mV.x - cP.x, mV.y - cP.y, mV.z - cP.z);
		//on normalise le vecteur car c'est lui qui sert de vecteur directeur du rayon qui part
		VectorMath.normalize(mV2);
		trace("Ray : " + mV2.toString());
		//intersection optimisée pour entre le rayon et un plan aligné sur x et z.
		//Normale du plan : y (0,1,0)
		var t:Number = -cP.y/mV2.y;
		trace("t = " + t.toString());
		var P:Vector = new Vector();

		P.x = cP.x + t*mV2.x;
		P.y = cP.y + t*mV2.y;
		P.z = cP.z + t*mV2.z;
		
		trace("intersection point = " + P.toString());
		__rootGrp.addChild( drawRepere(P.x,P.y,P.z) );
	}
	
	private function drawRepere(x:Number,y:Number,z:Number):TransformGroup
	{
		__repereTg.getChild(0).destroy();
		var maBox:Box = new Box(0.1,0.1,0.1,"quad");
		var deplacementSpSkin:MixedSkin  = new MixedSkin(0xFF0000,20,0xFF0000,100,1);
		maBox.setSkin(deplacementSpSkin);
		var boxTg:TransformGroup = new TransformGroup();
		var maTransformation:Transform3D = new Transform3D();
		maTransformation.translate(x,y,z);
		boxTg.addChild(maBox);
		boxTg.setTransform(maTransformation);

		__repereTg.addChild(boxTg);
		//Consommation
		//var distance:Number = Math.sqrt((__itemSource.X - posX )*(__itemSource.X - posX )+(__itemSource.Y - posY)*(__itemSource.Y - posY)+(__itemSource.Z - posZ)*(__itemSource.Z - posZ));
		//var nbAction:Number = Math.ceil(distance / __itemSource.PM);
		//
		return __repereTg;
	}
}
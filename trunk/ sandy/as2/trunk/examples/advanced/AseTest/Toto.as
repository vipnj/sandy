import sandy.core.Object3D;
import sandy.core.face.Face;
import sandy.core.face.TriFace3D;
import sandy.primitive.Primitive3D;

class Toto extends Object3D implements Primitive3D
{
	public function Toto( Void )
	{
		super();
		generate();
	}
	
	public function generate( Void ):Void
	{
#include "gun_content.as"
	}
}
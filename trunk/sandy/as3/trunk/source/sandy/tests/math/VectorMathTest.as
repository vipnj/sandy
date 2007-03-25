// ActionScript file
package sandy.tests.math
{
 	import flexunit.framework.TestCase;
 	import flexunit.framework.TestSuite;
 	
 	import sandy.core.data.*;
 	import sandy.math.VectorMath;
 	
 	public class VectorMathTest extends TestCase
 	{
  		
  	    public function VectorMathTest(methodName:String) 
  	    {
   			super(methodName);
        }
  	
  		public static function suite():TestSuite
  		{
   			var ts:TestSuite = new TestSuite();
   			
   			ts.addTest(new VectorMathTest('testAddVector'));
   			ts.addTest(new VectorMathTest('testSubVector'));
   			ts.addTest(new VectorMathTest('testCloneVector'));
   			
   			return ts;
   		}
  		
  		public function testAddVector():void
  		{
   			// Test add 2 vectors
   			var resultVector:Vector = VectorMath.addVector(new Vector(4,5,6), new Vector(1,2,3));
   			var resultBool:Boolean = (resultVector.x == 5 && resultVector.y == 7 && resultVector.z == 9);
   			
   			assertTrue("Expecting Vector(1,2,3) resultVector: " + resultVector, resultBool);
   		}
  		
  		public function testSubVector():void
  		{
   			// Test sub 2 vectors
   			var resultVector:Vector = VectorMath.sub( new Vector(4,5,6), new Vector(1,2,3) );
   			var resultBool:Boolean = (resultVector.x == 3 && resultVector.y == 3 && resultVector.z == 3);
   			
   			assertTrue("Expecting Vector(3,3,3) resultVector: " + resultVector, resultBool);
   		}
  		
  		public function testCloneVector():void
  		{
   			// Test clone vector
   			var resultVector:Vector = VectorMath.clone( new Vector(4,5,6) );
   			var resultBool:Boolean = (resultVector.x == 4 && resultVector.y == 5 && resultVector.z == 6);
   			
   			assertTrue("Expecting Vector(4,5,6) resultVector: " + resultVector, resultBool);
   		}
  		
  	}
}
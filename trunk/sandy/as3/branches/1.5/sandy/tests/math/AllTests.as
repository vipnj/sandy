package sandy.tests.math
{
	import flexunit.framework.TestSuite;

	public class AllTests extends TestSuite
	{
		
  		public static function suite():TestSuite
  		{
   			var ts:TestSuite = new TestSuite();
   			
   			ts.addTest(VectorMathTest.suite());
   			
   			return ts;
   		}
  		
	}
}
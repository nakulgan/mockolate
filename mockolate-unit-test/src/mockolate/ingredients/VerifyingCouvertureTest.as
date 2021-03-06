package mockolate.ingredients
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mockolate.errors.VerificationError;
	import mockolate.ingredients.faux.FauxInvocation;
	import mockolate.runner.MockolateRule;
	import mockolate.verify;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.core.throws;
	import org.hamcrest.object.equalTo;
	
	use namespace mockolate_ingredient;
	
	public class VerifyingCouvertureTest
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock]
		public var target:IEventDispatcher;
		
		public var instance:Mockolate;
		public var recorder:RecordingCouverture;
		public var verifier:VerifyingCouverture;
		
		[Before]
		public function create():void 
		{
			instance = MockolatierMaster.mockolatier.mockolateByTarget(target);
			recorder = instance.recorder;
			verifier = instance.verifier;
			
			recorder.invoked(invocation({ name: "method", arguments: [] }));
			recorder.invoked(invocation({ name: "method", arguments: [1, 2, 3] }));
			recorder.invoked(invocation({ name: "getter", invocationType: InvocationType.GETTER }));
			recorder.invoked(invocation({ name: "setter", invocationType: InvocationType.SETTER, arguments: [4] }));
		}
		
		protected function invocation(options:Object):Invocation 
		{
			return new FauxInvocation(options);
		}
		
		[Test]
		public function method():void 
		{
			verifier.method("method");
			verifier.method("method").twice();
		}
		
		[Test]
		public function method_withEmptyArgs():void
		{
			verifier.method("method").noArgs();
			verifier.method("method").noArgs().once();
		}
		
		[Test]
		public function method_withArgs():void
		{
			verifier.method("method").args(1, 2, 3);
			verifier.method("method").args(1, 2, 3).once();
		}
		
		//
		//	getter
		//
		
		[Test]
		public function getter():void 
		{
			verifier.getter("getter");
			verifier.getter("getter").once();
		}
		
		//
		//	setter
		//
		
		[Test]
		public function setter():void 
		{
			verifier.setter("setter");
			verifier.setter("setter").once();
			verifier.setter("setter").arg(4);
			verifier.setter("setter").arg(4).once();
		}
		
		//
		//	never
		//
		
		[Test(expected="mockolate.errors.VerificationError")]
		public function never_shouldFailIfInvokedAtLeastOnce():void 
		{
			verifier.method("method").never();
		}
		
		[Test]
		public function never_shouldPassIfNotInvoked():void 
		{
			// to use never() the default expected invocation count must be set to 0.
			//
			verifier.setDefaultExpectedInvocationCount(0);
			verifier.method("notCalled").never();
		}
		
		//
		//	atLeast
		//
		
		[Test]
		public function atLeast_shouldPassIfInvokedAtLeastTheGivenNumberOfTimes():void 
		{
			verifier.method("method").atLeast(1);
		}
		
		[Test(expected="mockolate.errors.VerificationError")]
		public function atLeast_shouldFailIfNotInvokedAtLeastTheGivenNumberOfTimes():void 
		{	
			verifier.method("notCalled").atLeast(1);
		}
		
		[Test]
		public function atLeast_shouldFailWithNiceErrorMessage():void 
		{
			try
			{
				verifier.method("notCalled").atLeast(1);	
			}
			catch (error:VerificationError)
			{
				assertThat(error.message, equalTo("Expected: at least <1> invocations of notCalled()\n\t\tbut: flash.events::IEventDispatcher(target).notCalled() invoked 0/1 (-1) times"));
			}
		}
		
		//
		//	atMost
		//
		
		[Test]
		public function atMost_shouldPassIfInvokedAtMostTheGivenNumberOfTimes():void 
		{
			verifier.method("method").atMost(2);
		}
		
		[Test(expected="mockolate.errors.VerificationError")]
		public function atMost_shouldFailIfInvokedMoreThanTheGivenNumberOfTimes():void 
		{
			verifier.method("method").atMost(1);
		}
		
		[Test]
		public function atMost_shouldFailWithNiceErrorMessage():void 
		{
			try
			{
				verifier.method("method").atMost(1);
			}
			catch (error:VerificationError)
			{
				assertThat(error.message, equalTo("Expected: at most <1> invocations of method()\n\t\tbut: flash.events::IEventDispatcher(target).method() invoked 2/1 (+1) times"));
			}
		}
	}
}
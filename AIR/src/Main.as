package 
{
	import com.myflashlab.air.extensions.billing.*;

	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.events.InvokeEvent;

	import com.myflashlab.air.extensions.dependency.OverrideAir;
	
	import com.doitflash.text.modules.MySprite;
	import com.doitflash.starling.utils.list.List;
	import com.doitflash.consts.Direction;
	import com.doitflash.consts.Orientation;
	import com.doitflash.mobileProject.commonCpuSrc.DeviceInfo;
	
	import com.luaye.console.C;

import flash.utils.setTimeout;

	/**
	 *
	 * ...
	 * @author Hadi Tavakoli - 5/4/2019 8:51 AM
	 */
	public class Main extends Sprite 
	{
		private var _tokens:Array = [];
		
		private const BTN_WIDTH:Number = 150;
		private const BTN_HEIGHT:Number = 60;
		private const BTN_SPACE:Number = 2;
		private var _txt:TextField;
		private var _body:Sprite;
		private var _list:List;
		private var _numRows:int = 1;
		
		public function Main():void 
		{
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivate);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
			
			stage.addEventListener(Event.RESIZE, onResize);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			C.startOnStage(this, "`");
			C.commandLine = false;
			C.commandLineAllowed = false;
			C.x = 20;
			C.width = 250;
			C.height = 150;
			C.strongRef = true;
			C.visible = true;
			C.scaleX = C.scaleY = DeviceInfo.dpiScaleMultiplier;
			
			_txt = new TextField();
			_txt.autoSize = TextFieldAutoSize.LEFT;
			_txt.antiAliasType = AntiAliasType.ADVANCED;
			_txt.multiline = true;
			_txt.wordWrap = true;
			_txt.embedFonts = false;
			_txt.htmlText = "<font face='Arimo' color='#333333' size='20'><b>Identical (iOS+Android) in-app-payments ANE V"+Billing.VERSION+"</b></font>";
			_txt.scaleX = _txt.scaleY = DeviceInfo.dpiScaleMultiplier;
			this.addChild(_txt);
			
			_body = new Sprite();
			this.addChild(_body);
			
			_list = new List();
			_list.holder = _body;
			_list.itemsHolder = new Sprite();
			_list.orientation = Orientation.VERTICAL;
			_list.hDirection = Direction.LEFT_TO_RIGHT;
			_list.vDirection = Direction.TOP_TO_BOTTOM;
			_list.space = BTN_SPACE;
			
			init();
		}
		
		private function handleActivate(e:Event):void
		{
			/*
				On Android, purchases will be read from GooglePlay app and it is recommended
				to always check it when app is activated. This way, if the user has redeemed
				a promotion code, your app will know about it.
				
				To know about promo-purchases on iOS, you must listen to the event
				BillingEvent.PROMO_PURCHASE_SUCCESS
			*/
			if(OverrideAir.os == OverrideAir.ANDROID && Billing.isInitialized)
				Billing.getPurchases(onGetPurchasesResult);
		}
		
		private function handleDeactivate(e:Event):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
		}
		
		private function handleKeys(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.BACK)
			{
				e.preventDefault();
				NativeApplication.nativeApplication.exit();
			}
		}
		
		private function onResize(e:*=null):void
		{
			if (_txt)
			{
				_txt.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
				
				C.x = 0;
				C.y = _txt.y + _txt.height + 0;
				C.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
				C.height = 600 * (1 / DeviceInfo.dpiScaleMultiplier);
			}
			
			if (_list)
			{
				_numRows = Math.floor(stage.stageWidth / (BTN_WIDTH * DeviceInfo.dpiScaleMultiplier + BTN_SPACE));
				_list.row = _numRows;
				_list.itemArrange();
			}
			
			if (_body)
			{
				_body.y = stage.stageHeight - _body.height;
			}
		}
		
		private function init(e:Event=null):void
		{
			// Remove OverrideAir debugger in production builds
			OverrideAir.enableDebugger(function ($ane:String, $class:String, $msg:String):void
			{
				trace($ane+" ("+$class+") "+$msg);
			});
			
			C.log("Please wait... \n");
			
			// set this to true only if your app targets kids. (iOS)
			Billing.PARENTAL_GATE = false;
			
			Billing.init(
					[	// Android in-app product IDs which you have already set in your Google Play console.
						"test01", // 1.00 managed product
						"test02", // $1.10 managed product
						"test05", // $47 expensive managed product
						"test06" // $10 managed product
					],
					[ // Android subscription IDs which you have already set in your Google Play console.
						"test03", // $1.10 monthly subscription
						"test04" // $1.31 Weekly subscription
					],
					[	// iOS in-app product IDs which you have already set in your iTunes Connect.
						"inappbilling_consumable_one",
						"inappbilling_managed_one",
						"inappbilling_managed_two",
						"inappbilling_managed_three",
						"inappbilling_managed_four",
						"inappbilling_managed_five",
						"promoConsumable1"
					],
					[ // iOS subscription IDs which you have already set in your iTunes Connect.
						"inappbilling_auto_renewable_one"
					],
					
					onInitResult);
			
			// listen to promo purchase on iOS 11+
			Billing.listener.addEventListener(BillingEvent.PROMO_PURCHASE_FAILED, onIosPromoPurchaseFailed);
			Billing.listener.addEventListener(BillingEvent.PROMO_PURCHASE_SUCCESS, onIosPromoPurchaseSuccess);
			
			// will be dispatched on iOS only if Billing.PARENTAL_GATE is set to true
			Billing.listener.addEventListener(BillingEvent.PARENT_PERMISSION_REQUIRED, onParentPermissionRequired);
			
			// will be dispatched on Android only in case when service is disconnected
			Billing.listener.addEventListener(BillingEvent.SERVICE_DISCONNECTED, function (e:BillingEvent):void
			{
				trace("BillingEvent.SERVICE_DISCONNECTED");
			});
			
		}
		
		private function onIosPromoPurchaseFailed(e:BillingEvent):void
		{
			trace("onPromoPurchaseFailed: " + e.msg);
		}
		
		private function onIosPromoPurchaseSuccess(e:BillingEvent):void
		{
			trace("onPromoPurchase status: " + e.status);
			trace("onPromoPurchase msg: " + e.msg);
			
			if (e.purchase)
			{
				C.log("----------------");
				// we cannot determine the "billingType" on promo purchases!
				// It's your job to name your productId in a way so you will know this.
				C.log("$data.orderId = " + 				e.purchase.orderId);
				C.log("$data.originalOrderId = " + 		e.purchase.originalOrderId);
				C.log("$data.productId = " +				e.purchase.productId);
				C.log("$data.purchaseState = " +			e.purchase.purchaseState);
				C.log("$data.purchaseTime = " +			e.purchase.purchaseTime);
				C.log("$data.purchaseToken = " +			e.purchase.purchaseToken);
				C.log("----------------");
			}
		}
		
		private function onParentPermissionRequired(e:BillingEvent):void
		{
			trace("onParentPermissionRequired: " + e.msg);
			
			// this will be called on iOS; ONLY if you have set Billing.PARENTAL_GATE = true;
			// When iOS 11+ iTunes promo purchase is used, the app starts and the purchase flow begins automatically.
			// This is normal for most apps but if your app is targeted for kids, your app will be rejected if the
			// purchase flow starts automatically. Apple requires you to do some parental-gate before any purchase flow
			// begins.
			
			// When you receive this event, you must do some parental-gate and if it was successful, you must tell the
			// ANE to continue the purchase flow. https://developer.apple.com/app-store/parental-gates/
			
			Billing.continueThePreventedPurchaseFlow();
		}
		
		private function onInitResult($status:int, $msg:String):void
		{
			/**
			 *	When developing, you may need to consume an already owned item. On the Android side, you may do as follow:
			 *	
			 *	Billing.forceConsume("purchaseToken", onResult);
			 *	function onResult($result:Boolean):void
			 *	{
			 *		if($result)
			 *		{
			 *			// your purchase has been consumed successfully
			 *		}
			 *		else
			 *		{
			 *			// something went wrong! You may try again.
			 *		}
			 *	}
			 * 
			 *	Unfortunately on the iOS side, you get "one shot" to buy your item because Apple remembers that your
			 *	account has purchased that item. If you need to test again, you need a different test account. There
			 *	is no way to reset these purchases like how we can in Android.
			 */
			
			
			C.log("init was successful: " + Boolean($status));
			C.log("init msg = " + $msg);
			
			if (!Boolean($status))
			{
				/*
					There's been a problem initializing or supporting in-app-purchases. Are you sure you have setup
					your project correctly? check the following probable causes:
					
					General reasons:
					1) Check your internet connection
					
					Android reasons:
					1) Your app must be in alpha, beta or release state on the Google console.
					2) Make sure your product IDs are matching the ones you entered in Google Play console?
					3) Sometimes it takes a few hours before Google can propagate your product IDs across all servers.
					4) Have you setup your bank information properly?
					5) Check this link: http://bfy.tw/3d26
					
					iOS reasons:
					1) Check your product IDs based on what you setup in iTunes Connect console
					2) Have you completed the bank information and billing contracts with Apple yet?
					3) Sometimes it takes a few hours before iTunes Connect can propagate your product IDs across all servers.
					4) read apple information here: https://developer.apple.com/in-app-purchase/
					5) Check this link: http://bfy.tw/3d1v
				*/
				
				return;
			}
			else
			{
				/*
					You may set the Android publicKey only if you want to do purchase verification on the app.
					Otherwise, you don't need to set it in your app at all and instead do the verification on server.
					for more details on this regard, read here:
					https://developer.android.com/google/play/billing/billing_library_overview#Verify-purchase
				 */
				Billing.publicKey = "Base64-encoded RSA public key found in your GooglePlay console > Development Tools > Services and APIs";
				
				C.log("Here's the list of available/online products which you can make purchases on them: \n");
				for (var i:int = 0; i < Billing.products.length; i++)
				{
					C.log("\t productId = " +		Billing.products[i].productId);
					C.log("\t title = " +			Billing.products[i].title);
					C.log("\t description = " +	Billing.products[i].description);
					C.log("\t price = " +			Billing.products[i].price);
					C.log("\t currency = " +		Billing.products[i].currency);
					C.log("---------------------------------------");
				}
			}
			
			//----------------------------------------------------------------------
			
			var btn2:MySprite = createBtn("getPurchases");
			btn2.addEventListener(MouseEvent.CLICK, getPurchases);
			_list.add(btn2);
			
			function getPurchases(e:MouseEvent):void
			{
				/*
					Checking what purchases this user has already made. This method will return only permanent and
					subscription payments. consumable purchases won't be saved on Google or Apple servers and you have
					to take care of them yourself if necessary based on your app logic.
					
					If thinking like apple, you can consider this method as the "restore" functionality on iOS
					in-app-purchases. And it does of course do the same thing on Android. which means that if a user
					has purchase on device A, you will be able to return her purchases on device B with using this
					method.
				*/
				
				C.log("\n Please wait for the list...");
				Billing.getPurchases(onGetPurchasesResult);
			}
			
			//----------------------------------------------------------------------
			
			var btn3:MySprite = createBtn("purchase Consumable!");
			btn3.addEventListener(MouseEvent.CLICK, purchaseConsumable);
			_list.add(btn3);
			
			function purchaseConsumable(e:MouseEvent):void
			{
				C.log("Please wait...");
				if(OverrideAir.os == OverrideAir.ANDROID)
				{
					Billing.doPayment(
							BillingType.CONSUMABLE,
							"test01",
							null,
							onPurchaseResult);
				}
				else
				{
					Billing.doPayment(
							BillingType.CONSUMABLE,
							"inappbilling_consumable_one",
							null,
							onPurchaseResult);
				}
				
			}
			
			//----------------------------------------------------------------------
			
			var btn03:MySprite = createBtn("purchase Permanent!");
			btn03.addEventListener(MouseEvent.CLICK, purchasePermanent);
			_list.add(btn03);
			
			function purchasePermanent(e:MouseEvent):void
			{
				C.log("Please wait...");
				if(OverrideAir.os == OverrideAir.ANDROID)
				{
					Billing.doPayment(
							BillingType.PERMANENT,
							"test05",
							null,
							onPurchaseResult);
				}
				else
				{
					Billing.doPayment(
							BillingType.PERMANENT,
							"inappbilling_managed_one",
							null,
							onPurchaseResult);
				}
				
			}
			
			//----------------------------------------------------------------------
			
			var btn003:MySprite = createBtn("force consume!");
			btn003.addEventListener(MouseEvent.CLICK, forceConsume);
			if(OverrideAir.os == OverrideAir.ANDROID) _list.add(btn003);
			
			function forceConsume(e:MouseEvent):void
			{
				C.log("There are " + _tokens.length + " purchases which are not consumed!");
				if(_tokens.length > 0)
				{
					Billing.forceConsume(_tokens.pop(), onForceConsumeResult)
				}
			}
			
			//----------------------------------------------------------------------
			
			var btn004:MySprite = createBtn("acknowledge purchase!");
			btn004.addEventListener(MouseEvent.CLICK, acknowledgePurchase);
			if(OverrideAir.os == OverrideAir.ANDROID) _list.add(btn004);
			
			function acknowledgePurchase(e:MouseEvent):void
			{
				Billing.acknowledgePurchase(_tokens[0], onAcknowledgePurchaseResult);
			}
			
			function onAcknowledgePurchaseResult($error:String):void
			{
				if($error)
				{
					C.log($error);
				}
				else
				{
					C.log("onAcknowledgePurchase success");
				}
			}
			
			//----------------------------------------------------------------------
			
			var btn4:MySprite = createBtn("purchase Subscription!");
			btn4.addEventListener(MouseEvent.CLICK, purchaseSubscription);
			_list.add(btn4);
			
			function purchaseSubscription(e:MouseEvent):void
			{
				C.log("Please wait...");
				if(OverrideAir.os == OverrideAir.ANDROID)
				{
					Billing.doPayment(
							BillingType.AUTO_RENEWAL,
							"test03",
							null,
							onPurchaseResult)
				}
				else
				{
					Billing.doPayment(
							BillingType.AUTO_RENEWAL,
							"inappbilling_auto_renewable_one",
							null,
							onPurchaseResult);
				}
			}
			
			//----------------------------------------------------------------------
			
			var btn7:MySprite = createBtn("Redeem");
			btn7.addEventListener(MouseEvent.CLICK, redeem);
			if(OverrideAir.os == OverrideAir.ANDROID) _list.add(btn7);
			
			
			function redeem(e:MouseEvent):void
			{
				Billing.redeem();
			}
			
			//----------------------------------------------------------------------
			
			var btn6:MySprite = createBtn("get iOS Receipt");
			btn6.addEventListener(MouseEvent.CLICK, getiOSReceipt);
			if(OverrideAir.os != OverrideAir.ANDROID) _list.add(btn6);
			
			function getiOSReceipt(e:MouseEvent):void
			{
				trace("iOSReceipt: " + Billing.iOSReceipt);
			}
			
			//----------------------------------------------------------------------
			
			onResize();
		}
		
		private function onGetPurchasesResult($purchases:Vector.<Purchase>):void
		{
			if ($purchases)
			{
				_tokens = [];
				
				if ($purchases.length > 0)
				{
					for (var i:int = 0; i < $purchases.length; i++)
					{
						C.log("----------------");
						C.log("purchaseData.orderId = " + 			$purchases[i].orderId);
						C.log("purchaseData.originalOrderId = " + 	$purchases[i].originalOrderId);
						C.log("purchaseData.productId = " +			$purchases[i].productId);
						C.log("purchaseData.purchaseState = " +		$purchases[i].purchaseState);
						C.log("purchaseData.purchaseTime = " +		$purchases[i].purchaseTime);
						C.log("purchaseData.purchaseToken = " +		$purchases[i].purchaseToken);
						
						_tokens.push($purchases[i].purchaseToken);
						
						if(OverrideAir.os == OverrideAir.ANDROID)
						{
							C.log("purchaseData.autoRenewing = " +		$purchases[i].autoRenewing);
							C.log("purchaseData.signature = " +			$purchases[i].signature);
							C.log("purchaseData.isAcknowledged = " +		$purchases[i].isAcknowledged);
							trace("verifyAndroidPurchaseLocally: " + Billing.verifyAndroidPurchaseLocally($purchases[i]));
						}
						C.log("----------------");
					}
				}
				else // if it's an empty Array, it means there are no purchase records for this user on the server.
				{
					C.log("\n There are no purchase records for this user on Google or Apple servers.");
				}
			}
			else
			{
				C.log("\n Error while trying to get the list of previously purchased records.")
			}
		}
		
		private function onPurchaseResult($status:int, $purchase:Purchase, $msg:String, $wasConsumed:Boolean):void
		{
			/*
				IMPORTANT:
				
				Unlike iOS which you could create consumable products inside iTunesConnect, in Android you
				can only create managed products. This means that native devs will always need to manually consume
				their products. To make your job easier and make sure the Android and iOS sides work similar to each
				other on this ANE, we are consuming the purchases on Android automatically (if you have set
				BillingType.CONSUMABLE in the doPayment method).
				
				However, it is possible, that due to internet connection or any other reason, the process fails. So
				your Android consumable item will be purchased but not consumed! When this happens, you must
				forceConsume the item yourself. To know if this problem has happened, all you have to do is to
				check if the $wasConsumed param is true or not. and if it's false, call forceConsume on it.
			*/
			
			
			C.log("\n purchase was successful? " + Boolean($status));
			
			if ($msg == Billing.ALREADY_OWNED_ITEM || $msg == Billing.NOT_FOUND_ITEM)
			{
				C.log($msg);
			}
			else
			{
				C.log("purchase result message = " + $msg);
			}
			
			if ($purchase)
			{
				if($purchase.billingType == BillingType.CONSUMABLE)
				{
					C.log("purchase was consumed? " + $wasConsumed);
					
					if(!$wasConsumed)
					{
						C.log("There's been a problem in consuming this Android product. mark it and consume it manually now...");
						Billing.forceConsume($purchase.purchaseToken, onForceConsumeResult);
					}
				}
				else
				{
					_tokens.push($purchase.purchaseToken);
				}
				
				C.log("----------------");
				C.log("$purchase.billingType = " +			$purchase.billingType);
				C.log("$purchase.orderId = " +				$purchase.orderId);
				C.log("$purchase.originalOrderId = " +		$purchase.originalOrderId);
				C.log("$purchase.productId = " +				$purchase.productId);
				C.log("$purchase.purchaseState = " +			$purchase.purchaseState);
				C.log("$purchase.purchaseTime = " +			$purchase.purchaseTime);
				C.log("$purchase.purchaseToken = " +			$purchase.purchaseToken);
				
				if(OverrideAir.os == OverrideAir.ANDROID)
				{
					C.log("$purchase.autoRenewing = " +		$purchase.autoRenewing);
					C.log("$purchase.signature = " +			$purchase.signature);
					C.log("$purchase.isAcknowledged = " +		$purchase.isAcknowledged);
					C.log("$purchase.rawData = " +			$purchase.rawData);
					trace("verifyAndroidPurchaseLocally: "+ Billing.verifyAndroidPurchaseLocally($purchase));
				}
				C.log("----------------");
			}
		}
		
		private function onForceConsumeResult($result:Boolean):void
		{
			if($result)
			{
				C.log("your purchase has been consumed successfully");
			}
			else
			{
				C.log("something went wrong! You may try again.");
			}
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		private function createBtn($str:String):MySprite
		{
			var sp:MySprite = new MySprite();
			sp.addEventListener(MouseEvent.MOUSE_OVER,  onOver);
			sp.addEventListener(MouseEvent.MOUSE_OUT,  onOut);
			sp.addEventListener(MouseEvent.CLICK,  onOut);
			sp.bgAlpha = 1;
			sp.bgColor = 0xDFE4FF;
			sp.drawBg();
			sp.width = BTN_WIDTH * DeviceInfo.dpiScaleMultiplier;
			sp.height = BTN_HEIGHT * DeviceInfo.dpiScaleMultiplier;
			
			function onOver(e:MouseEvent):void
			{
				sp.bgAlpha = 1;
				sp.bgColor = 0xFFDB48;
				sp.drawBg();
			}
			
			function onOut(e:MouseEvent):void
			{
				sp.bgAlpha = 1;
				sp.bgColor = 0xDFE4FF;
				sp.drawBg();
			}
			
			var format:TextFormat = new TextFormat("Arimo", 16, 0x666666, null, null, null, null, null, TextFormatAlign.CENTER);
			
			var txt:TextField = new TextField();
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.antiAliasType = AntiAliasType.ADVANCED;
			txt.mouseEnabled = false;
			txt.multiline = true;
			txt.wordWrap = true;
			txt.scaleX = txt.scaleY = DeviceInfo.dpiScaleMultiplier;
			txt.width = sp.width * (1 / DeviceInfo.dpiScaleMultiplier);
			txt.defaultTextFormat = format;
			txt.text = $str;
			
			txt.y = sp.height - txt.height >> 1;
			sp.addChild(txt);
			
			return sp;
		}
	}
	
}
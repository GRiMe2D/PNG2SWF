package {

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	public final class Main extends Sprite {

		private var swfLoader:Loader;
		private var button:Button;

		public function Main() {
			initStage();
			initUI();
		}

		private function initStage():void {
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
		}

		private function initUI():void {
			this.button = new Button("Hello world");

			this.addChild(this.button);

			this.stage.color = 0xEEEEEE;
			this.stage.addEventListener(Event.RESIZE, resizeHandler);
		}

		private function resizeHandler(event:Event):void {
			this.button.x = this.stage.stageWidth - this.button.width - 10;
			this.button.y = this.stage.stageHeight - this.button.height - 10;
		}
	}
}

import flash.display.Bitmap;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

final class Button extends SimpleButton {

	private var _label:String;
	public function get label():String {
		return this._label;
	}
	public function set label(newValue:String):void {
		this._label = newValue;
		this.validate();
	}


	public function Button(label:String = "") {
		super();
		this._label = label;
		this.validate();
	}

	private function validate():void {
		var sprite:Sprite = new Sprite();
		var bitmap:Bitmap = new Resource.RS_Button_UpState();
		var textField:TextField = this.getTextField();
		sprite.addChild(bitmap);
		sprite.addChild(textField);
		textField.x = (bitmap.width - textField.width) / 2;
		textField.y = (bitmap.height - 6 - textField.height) / 2;

		this.upState = sprite;
		this.hitTestState = sprite;
		this.overState = sprite;


		sprite = new Sprite();
		bitmap = new Resource.RS_Button_Pressed();
		textField = this.getTextField();
		sprite.addChild(bitmap);
		sprite.addChild(textField);
		textField.x = (bitmap.width - textField.width) / 2;
		textField.y = (bitmap.height - 6 - textField.height) / 2 + 6;

		this.downState = sprite;
	}

	private function getTextField():TextField {
		const textField:TextField = new TextField();
		textField.textColor = 0xFFFFFF;
		textField.selectable = false;
		textField.autoSize = TextFieldAutoSize.LEFT;
		textField.defaultTextFormat = new TextFormat("_sans", 13);
		textField.text = this.label;
		return textField;
	}
}
package {

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;

	public final class Main extends Sprite {

		private var swfLoader:Loader;
		private const controlGroup:Sprite = new Sprite();
		private const loadFileButton:Button = new Button("Load file");
		private const convertButton:Button = new Button("Convert");
		private const widthInput:TextInput = new TextInput();
		private const heightInput:TextInput = new TextInput();
		private const framesInput:TextInput = new TextInput();

		public function Main() {
			initStage();
			initUI();
		}

		private function initStage():void {
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
		}

		private function initUI():void {
			widthInput.label = "Width";
			widthInput.width = loadFileButton.width + 10 + convertButton.width;

			heightInput.label = "Height";
			heightInput.width = widthInput.width;
			heightInput.y = widthInput.height + 10;

			framesInput.label = "Frames";
			framesInput.width = widthInput.width;
			framesInput.y = widthInput.height + 10 + heightInput.height + 10;

			convertButton.y = widthInput.height + 10 + heightInput.height + 10 + framesInput.height + 10;

			loadFileButton.x = convertButton.width + 10;
			loadFileButton.y = convertButton.y;

			controlGroup.addChild(widthInput);
			controlGroup.addChild(heightInput);
			controlGroup.addChild(framesInput);
			controlGroup.addChild(loadFileButton);
			controlGroup.addChild(convertButton);
			this.addChild(controlGroup);

			convertButton.enabled = false;

			this.stage.color = 0xEEEEEE;
			this.stage.addEventListener(Event.RESIZE, resizeHandler);
		}

		private function resizeHandler(event:Event):void {
			const rect:Rectangle = controlGroup.getBounds(this);
			controlGroup.x += this.stage.stageWidth - 10 - rect.right;
			controlGroup.y += this.stage.stageHeight - 10 - rect.bottom;
		}
	}
}

import flash.display.Bitmap;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
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
		textField.defaultTextFormat = new TextFormat("Menlo", 13);
		textField.text = this.label;
		return textField;
	}


	override public function set enabled(value:Boolean):void {
		if (value) {
			this.alpha = 1.0;
		} else {
			this.alpha = 0.5;
		}
		super.enabled = value;
	}
}

final class TextInput extends Sprite {
	private const background:Bitmap = new Resource.RS_TEXT_EDIT();
	private const labelField:TextField = new TextField();
	private const valueField:TextField = new TextField();
	public function TextInput() {
		background.scale9Grid = new Rectangle(7, 2, 286, 30);

		labelField.textColor = 0xFFFFFF;
		labelField.selectable = false;
		labelField.autoSize = TextFieldAutoSize.LEFT;
		labelField.defaultTextFormat = new TextFormat("Menlo", 13);

		valueField.textColor = 0x333333;
		valueField.type = TextFieldType.INPUT;
		valueField.border = false;
		valueField.borderColor = 0x333333;
		valueField.defaultTextFormat = new TextFormat("Menlo", 13);
		valueField.height = background.height - background.scale9Grid.top - background.height + background.scale9Grid.height - 7;
		valueField.width = background.width - background.scale9Grid.left - background.width + background.scale9Grid.width - 75;
		valueField.x = background.scale9Grid.left + 100 * background.scaleX;
		valueField.y = (background.height - 6 - valueField.height) / 2;
		valueField.restrict = "[0-9]";

		this.addChild(background);
		this.addChild(labelField);
		this.addChild(valueField);
	}

	public function get label():String {
		return labelField.text;
	}

	public function set label(value:String):void {
		labelField.text = value;
		labelField.x = 10;
		labelField.y = (background.height - 6  - labelField.height) / 2;
	}

	public function get value():String {
		return valueField.text;
	}

	public function set value(value:String):void {
		valueField.text = value;
	}

	override public function set width(value:Number):void {
		background.width = value;
	}


	override public function get width():Number {
		return background.width;
	}

	override public function set height(value:Number):void {
		background.height = value;
	}

	override public function get height():Number {
		return background.height;
	}
}
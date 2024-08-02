from kivy.app import App
from kivy.uix.button import Button
from kivy.lang import Builder
import asyncio
from bleak import BleakScanner


#GUI = Builder.load_file("tela.kv")

class BLEScannerApp(App):
    def build(self):
        button = Button(text="Scan for BLE devices")
        button.bind(on_press=self.start_scan)
        return button

    def start_scan(self, instance):
        asyncio.run(self.scan())

    async def scan(self):
        devices = await BleakScanner.discover()
        for device in devices:
            print(device)

if __name__ == '__main__':
    BLEScannerApp().run()

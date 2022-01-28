# -------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for
# license information.
# --------------------------------------------------------------------------

import os
import time
import uuid
import asyncio
import datetime
import json 
from azure.iot.device.aio import IoTHubDeviceClient
from azure.iot.device import  Message
import Adafruit_DHT

async def main():
    # Fetch the connection string from an enviornment variable
    time.sleep(10)
    conn_str = os.getenv("IOTHUB_DEVICE_CONNECTION_STRING")
    # Create instance of the device client using the connection string
    device_client = IoTHubDeviceClient.create_from_connection_string(conn_str)
    # Connect the device client.
    await device_client.connect()
    
    while True:
        # Get temp , humid
        humidity, temperature = Adafruit_DHT.read_retry(22, 4)
        # t_delta = datetime.timedelta(hours=9)  # 9時間
        # JST = datetime.timezone(t_delta, 'JST')  # UTCから9時間差の「JST」タイムゾーン
        dt = datetime.datetime.today() # タイムゾーン付きでローカルな日付と時刻を取得
        # print(dt)
        if humidity is not None and temperature is not None:
            msg = Message('{{"temperature": {temperature:0.1f},"humidity": {humidity:0.1f},"timestamp_jst":"{timestamp}"}}'.format(temperature = temperature, humidity = humidity,timestamp = dt))
            msg.message_id = uuid.uuid4()
            msg.correlation_id = "correlation-1234"
            msg.content_encoding = "utf-8"
            msg.content_type = "application/json"

            # Send a single message
            print(msg)
            await device_client.send_message(msg)
            print("Message successfully sent!")

        else:
            print('Failed to get reading. Try again!')
            sys.exit(1)
            # Finally, shut down the client
            await device_client.shutdown()
        time.sleep(1)
    # Finally, shut down the client
    await device_client.shutdown()


if __name__ == "__main__":
    asyncio.run(main())

    # If using Python 3.6 or below, use the following code instead of asyncio.run(main()):
    # loop = asyncio.get_event_loop()
    # loop.run_until_complete(main())
    # loop.close()
